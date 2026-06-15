// screens/algo_trade/algo_gecmis_view.dart
//
// Algo trade gecmis oturumlari + toplam kar/zarar gosteren ekran.
// AlgoTradeScreen'den ust koseye eklenen 'Gecmis' butonu ile acilir.

import 'package:flutter/material.dart';

import '../../core/di/locator.dart';
import '../../core/theme/color_scheme.dart';

const _kBgTop = AppColors.bgGradientTop;
const _kBgMid = AppColors.bgGradientMid;
const _kBgBot = AppColors.bgGradientBot;
const _kTeal = AppColors.accentTeal;
const _kGlass = AppColors.glassFill;
const _kGlassBorder = AppColors.glassBorder;
const _kInnerGlass = AppColors.glassFillInner;
const _kProfit = AppColors.profitDark;
const _kLoss = AppColors.lossDark;

class AlgoGecmisView extends StatefulWidget {
  const AlgoGecmisView({super.key});

  @override
  State<AlgoGecmisView> createState() => _AlgoGecmisViewState();
}

class _AlgoGecmisViewState extends State<AlgoGecmisView> {
  final _servis = locator.algoTrade;
  Map<String, dynamic>? _veri;
  bool _yukleniyor = true;

  @override
  void initState() {
    super.initState();
    _yukle();
  }

  Future<void> _yukle() async {
    setState(() => _yukleniyor = true);
    try {
      final v = await _servis.gecmisOzet();
      if (mounted) {
        setState(() {
          _veri = v;
          _yukleniyor = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? _kBgTop : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Geçmiş Oturumlar',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isDark
          ? Stack(children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [_kBgTop, _kBgMid, _kBgBot],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              _icerik(isDark),
            ])
          : _icerik(isDark),
    );
  }

  Widget _icerik(bool isDark) {
    if (_yukleniyor) {
      return const Center(
          child: CircularProgressIndicator(color: _kTeal, strokeWidth: 2));
    }
    final oturumlar =
        List<Map<String, dynamic>>.from(_veri?['oturumlar'] ?? []);
    final toplam =
        Map<String, dynamic>.from(_veri?['toplam'] ?? const {});

    return RefreshIndicator(
      color: _kTeal,
      onRefresh: _yukle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _toplamKart(isDark, toplam),
          const SizedBox(height: 14),
          if (oturumlar.isEmpty)
            _bosDurum(isDark)
          else
            ...oturumlar.map((s) => _oturumKart(isDark, s)),
        ],
      ),
    );
  }

  Widget _toplamKart(bool isDark, Map<String, dynamic> t) {
    final pnl = (t['pnl'] as num?)?.toDouble() ?? 0;
    final oturum = (t['oturum'] as num?)?.toInt() ?? 0;
    final islem = (t['islem'] as num?)?.toInt() ?? 0;
    final kazanma = (t['kazanma_orani'] as num?)?.toDouble() ?? 0;
    final pozitif = pnl >= 0;
    final renk = pozitif ? _kProfit : _kLoss;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? _kGlass : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark
            ? Border.all(color: _kGlassBorder, width: 1)
            : Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toplam Kâr / Zarar',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${pozitif ? '+' : ''}₺${pnl.toStringAsFixed(2)}',
            style: TextStyle(
              color: renk,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ozetParca(isDark, 'Oturum', '$oturum'),
              const SizedBox(width: 20),
              _ozetParca(isDark, 'İşlem', '$islem'),
              const SizedBox(width: 20),
              _ozetParca(isDark, 'Kazanma',
                  '${(kazanma * 100).toStringAsFixed(1)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ozetParca(bool isDark, String etiket, String deger) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiket,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.grey.shade500,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          deger,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _bosDurum(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? _kInnerGlass : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: _kGlassBorder, width: 1) : null,
      ),
      child: Column(
        children: [
          Icon(Icons.history,
              size: 42, color: isDark ? Colors.white24 : Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Henüz tamamlanmış oturum yok.',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _oturumKart(bool isDark, Map<String, dynamic> s) {
    final id = s['id'];
    final sermaye = (s['capital'] as num?)?.toDouble() ?? 0;
    final pnl = (s['pnl'] as num?)?.toDouble() ?? 0;
    final islem = (s['islem_sayisi'] as num?)?.toInt() ?? 0;
    final kazanan = (s['kazanan'] as num?)?.toInt() ?? 0;
    final mod = s['mode'] as String? ?? '—';
    final profil = s['risk_profile'] as String? ?? '—';
    final durum = s['status'] as String? ?? '—';
    final baslangic = _tarihFormat(s['started_at']);
    final bitis = _tarihFormat(s['stopped_at']);
    final yuzde = sermaye > 0 ? (pnl / sermaye) * 100 : 0;
    final pozitif = pnl >= 0;
    final renk = pozitif ? _kProfit : _kLoss;
    final muted = isDark ? Colors.white54 : Colors.grey.shade600;
    final govde = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? _kInnerGlass : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: _kGlassBorder, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Oturum #$id',
                  style: TextStyle(
                      color: govde,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _rozet(durum),
              const Spacer(),
              Text(
                '${pozitif ? '+' : ''}₺${pnl.toStringAsFixed(2)}',
                style: TextStyle(
                    color: renk,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            sermaye > 0
                ? 'Sermaye ₺${sermaye.toStringAsFixed(0)}  ·  '
                    '${pozitif ? '+' : ''}${yuzde.toStringAsFixed(2)}%'
                : '—',
            style: TextStyle(color: muted, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _bilgi(muted, govde, 'Tarih', '$baslangic → $bitis'),
          const SizedBox(height: 3),
          _bilgi(muted, govde, 'Mod', '$mod  ·  $profil'),
          const SizedBox(height: 3),
          _bilgi(muted, govde, 'İşlem',
              '$islem  ·  $kazanan kazanan'),
        ],
      ),
    );
  }

  Widget _bilgi(Color muted, Color govde, String etiket, String deger) {
    return Row(
      children: [
        SizedBox(
            width: 56,
            child: Text(etiket,
                style: TextStyle(color: muted, fontSize: 11))),
        Expanded(
          child: Text(deger,
              style: TextStyle(
                  color: govde,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _rozet(String durum) {
    Color renk;
    String yazi;
    switch (durum) {
      case 'RUNNING':
        renk = _kTeal;
        yazi = 'Aktif';
        break;
      case 'STOP_REQUESTED':
        renk = Colors.orange;
        yazi = 'Durduruluyor';
        break;
      default:
        renk = Colors.grey;
        yazi = 'Kapandı';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: renk.withValues(alpha: 0.4), width: 0.5),
      ),
      child: Text(
        yazi,
        style: TextStyle(
            color: renk, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _tarihFormat(dynamic ts) {
    if (ts == null) return '—';
    try {
      final t = ts is DateTime ? ts : DateTime.parse(ts.toString());
      final y = t.toLocal();
      final g = y.day.toString().padLeft(2, '0');
      final a = y.month.toString().padLeft(2, '0');
      final s = y.hour.toString().padLeft(2, '0');
      final d = y.minute.toString().padLeft(2, '0');
      return '$g.$a $s:$d';
    } catch (_) {
      return '—';
    }
  }
}
