// Algo trade veri servisi.
//
// Bu servis iki kaynakla konusur:
//   - Firebase: kullanicinin risk profili (mevcut anketten, tekrar
//     sorulmaz). Uzun vade yatirim akisina dokunulmaz.
//   - Supabase: oturum baslat/durdur, canli pozisyon, equity, sinyal
//     ve sistem kalp atisi.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AlgoTradeService {
  static final AlgoTradeService instance = AlgoTradeService._();
  AlgoTradeService._();

  SupabaseClient get _sb => Supabase.instance.client;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Kullanicinin risk profilini mevcut Firebase anketinden okur.
  // Sonuc: 'Defansif' | 'Dengeli' | 'Agresif'. Bulunamazsa 'Dengeli'.
  Future<String> riskProfiliGetir() async {
    final uid = _uid;
    if (uid == null) return 'Dengeli';
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('risk_profile')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return 'Dengeli';
    final segment = snap.docs.first.data()['segment'];
    if (segment == 'Defansif' || segment == 'Agresif') return segment;
    return 'Dengeli';
  }

  // Kullanicinin calisan veya durdurma bekleyen oturumu varsa dondurur.
  Future<Map<String, dynamic>?> aktifOturum() async {
    final uid = _uid;
    if (uid == null) return null;
    final liste = await _sb
        .from('portfolio_sessions')
        .select()
        .eq('user_id', uid)
        .inFilter('status', ['RUNNING', 'STOP_REQUESTED'])
        .order('started_at', ascending: false)
        .limit(1);
    if (liste.isEmpty) return null;
    return liste.first;
  }

  // Yeni oturum baslatir. mode: 'AUTO' | 'SECTOR' | 'WHITELIST'.
  Future<void> oturumBaslat({
    required double sermaye,
    required String riskProfili,
    required String mod,
    List<String> izinliSektorler = const [],
    List<String> beyazListe = const [],
    List<String> karaListe = const [],
  }) async {
    final uid = _uid;
    if (uid == null) return;
    await _sb.from('portfolio_sessions').insert({
      'user_id': uid,
      'capital': sermaye,
      'risk_profile': riskProfili,
      'mode': mod,
      'allowed_sectors': izinliSektorler,
      'whitelist': beyazListe,
      'blacklist': karaListe,
      'status': 'RUNNING',
    });
  }

  // Durdurma istegi. cikisModu: 'HARD' (hemen kapat) | 'SOFT' (kendi
  // stop/hedefine birak). Asil kapatmayi Mac'teki motor yapar.
  Future<void> oturumDurdur(int oturumId, String cikisModu) async {
    await _sb.from('portfolio_sessions').update({
      'status': 'STOP_REQUESTED',
      'stop_mode': cikisModu,
    }).eq('id', oturumId);
  }

  // Hizli cikiste (HARD) app pozisyonlari kendisi kapattigi icin
  // oturumu dogrudan STOPPED'a aliriz; motora bekleme kalmaz.
  Future<void> oturumTamamenDurdur(int oturumId, String cikisModu) async {
    await _sb.from('portfolio_sessions').update({
      'status': 'STOPPED',
      'stop_mode': cikisModu,
      'stopped_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', oturumId);
  }

  Future<List<Map<String, dynamic>>> acikPozisyonlar(int oturumId) async {
    final r = await _sb
        .from('paper_trades')
        .select()
        .eq('session_id', oturumId)
        .eq('status', 'OPEN')
        .order('entry_ts', ascending: false);
    return List<Map<String, dynamic>>.from(r);
  }

  Future<List<Map<String, dynamic>>> kapananIslemler(int oturumId) async {
    final r = await _sb
        .from('paper_trades')
        .select()
        .eq('session_id', oturumId)
        .eq('status', 'CLOSED')
        .order('exit_ts', ascending: false)
        .limit(50);
    return List<Map<String, dynamic>>.from(r);
  }

  // Verilen sembollerin en guncel piyasa fiyatini ve o fiyatin yazildigi
  // zamani dondurur. Her sembol icin {'fiyat': double, 'ts': iso-string}.
  Future<Map<String, Map<String, dynamic>>> guncelFiyatlar(
      List<String> semboller) async {
    if (semboller.isEmpty) return {};
    final r = await _sb
        .from('live_prices')
        .select('symbol, ts, close')
        .inFilter('symbol', semboller)
        .order('ts', ascending: false)
        .limit(semboller.length * 8);
    final son = <String, Map<String, dynamic>>{};
    for (final row in r) {
      final s = row['symbol'] as String;
      if (!son.containsKey(s) && row['close'] != null) {
        son[s] = {
          'fiyat': (row['close'] as num).toDouble(),
          'ts': row['ts'],
        };
      }
    }
    return son;
  }

  // Acik bir pozisyonun stop ve hedef fiyatlarini gunceller. Motor her
  // turda DB'den okudugu icin degisiklik anlik etkili olur.
  Future<void> pozisyonGuncelle(
      int tradeId, double stopPx, double tpPx) async {
    await _sb.from('paper_trades').update({
      'stop_px': stopPx,
      'tp_px': tpPx,
    }).eq('id', tradeId);
  }

  // Tek bir pozisyonu motoru beklemeden hemen kapatir. Cikis fiyati
  // su anki piyasa fiyati uzerinden komisyon ve slippage dusulerek
  // hesaplanir; motorun "satis_fiyati" kuraliyla birebir tutarli.
  Future<void> pozisyonAnindaKapat(
      int tradeId, double entryPx, double qty, double guncelFiyat) async {
    const komisyon = 0.0010;
    const slippage = 0.0005;
    final cikis = guncelFiyat * (1 - slippage - komisyon);
    final pnl = (cikis - entryPx) * qty;
    await _sb.from('paper_trades').update({
      'status': 'CLOSED',
      'exit_ts': DateTime.now().toUtc().toIso8601String(),
      'exit_px': cikis,
      'exit_reason': 'MANUAL_SELL',
      'pnl': pnl,
    }).eq('id', tradeId);
  }

  // Kullanicinin TUM gecmis oturumlarini ve genel kar/zarar ozetini
  // dondurur. Geçmiş Oturumlar ekrani bunu kullanir.
  // Donen yapi:
  //   { 'oturumlar': [ {...oturum, pnl, islem_sayisi, kazanan}, ... ],
  //     'toplam':    { pnl, oturum, islem, kazanma_orani } }
  Future<Map<String, dynamic>> gecmisOzet() async {
    final uid = _uid;
    if (uid == null) {
      return {'oturumlar': [], 'toplam': _bosToplam()};
    }
    final oturumlar = List<Map<String, dynamic>>.from(
      await _sb
          .from('portfolio_sessions')
          .select()
          .eq('user_id', uid)
          .order('started_at', ascending: false),
    );
    if (oturumlar.isEmpty) {
      return {'oturumlar': [], 'toplam': _bosToplam()};
    }
    final ids = oturumlar.map<int>((s) => s['id'] as int).toList();
    final trades = List<Map<String, dynamic>>.from(
      await _sb
          .from('paper_trades')
          .select('session_id, pnl')
          .inFilter('session_id', ids)
          .eq('status', 'CLOSED'),
    );

    final pnlSession = <int, double>{};
    final cntSession = <int, int>{};
    final winSession = <int, int>{};
    double toplamPnl = 0;
    int toplamIslem = 0;
    int toplamKazanan = 0;
    for (final t in trades) {
      final sid = t['session_id'] as int;
      final pnl = (t['pnl'] as num?)?.toDouble() ?? 0;
      pnlSession[sid] = (pnlSession[sid] ?? 0) + pnl;
      cntSession[sid] = (cntSession[sid] ?? 0) + 1;
      if (pnl > 0) winSession[sid] = (winSession[sid] ?? 0) + 1;
      toplamPnl += pnl;
      toplamIslem += 1;
      if (pnl > 0) toplamKazanan += 1;
    }

    final zenginlestirilmis = oturumlar.map<Map<String, dynamic>>((s) {
      final sid = s['id'] as int;
      return {
        ...s,
        'pnl': pnlSession[sid] ?? 0.0,
        'islem_sayisi': cntSession[sid] ?? 0,
        'kazanan': winSession[sid] ?? 0,
      };
    }).toList();

    return {
      'oturumlar': zenginlestirilmis,
      'toplam': {
        'pnl': toplamPnl,
        'oturum': oturumlar.length,
        'islem': toplamIslem,
        'kazanma_orani':
            toplamIslem > 0 ? toplamKazanan / toplamIslem : 0.0,
      },
    };
  }

  Map<String, dynamic> _bosToplam() => {
        'pnl': 0.0,
        'oturum': 0,
        'islem': 0,
        'kazanma_orani': 0.0,
      };

  Future<List<Map<String, dynamic>>> equityEgrisi(int oturumId) async {
    final r = await _sb
        .from('equity_curve')
        .select('ts, equity')
        .eq('session_id', oturumId)
        .order('ts', ascending: true)
        .limit(500);
    return List<Map<String, dynamic>>.from(r);
  }

  // Sistem kalp atisini okur. Donen:
  //   {calisiyor: bool, borsaAcik: bool, mesaj: String}
  // calisiyor: son kalp atisi 180 sn'den yeni mi (Mac'te isci acik mi).
  Future<Map<String, dynamic>> sistemDurumu() async {
    final liste = await _sb
        .from('system_heartbeat')
        .select()
        .eq('id', 1)
        .limit(1);
    if (liste.isEmpty) {
      return {
        'calisiyor': false,
        'borsaAcik': false,
        'mesaj': 'Sistem hic calismadi.'
      };
    }
    final h = liste.first;
    final son = DateTime.parse(h['heartbeat']).toUtc();
    final fark = DateTime.now().toUtc().difference(son).inSeconds;
    return {
      'calisiyor': fark <= 180,
      'borsaAcik': h['borsa_acik'] == true,
      'mesaj': h['mesaj'] ?? '',
      'gecenSaniye': fark,
    };
  }
}
