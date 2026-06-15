// screens/algo_trade/algo_live_view.dart
import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/di/locator.dart';

const _kTeal = AppColors.accentTeal;
const _kGlass = AppColors.glassFill;
const _kGlassBorder = AppColors.glassBorder;
const _kInnerGlass = AppColors.glassFillInner;
const _kProfit = AppColors.profitDark;
const _kLoss = AppColors.lossDark;

class AlgoLiveView extends StatefulWidget {
  final Map<String, dynamic> oturum;
  final VoidCallback onDegisti;
  const AlgoLiveView({
    super.key,
    required this.oturum,
    required this.onDegisti,
  });

  @override
  State<AlgoLiveView> createState() => _AlgoLiveViewState();
}

class _AlgoLiveViewState extends State<AlgoLiveView> {
  final _servis = locator.algoTrade;
  Map<String, dynamic>? _durum;
  List<Map<String, dynamic>> _acik = [];
  List<Map<String, dynamic>> _kapanan = [];
  List<Map<String, dynamic>> _equity = [];
  // Acik pozisyonlardaki hisselerin en guncel piyasa fiyati (anlik
  // kar/zarar ve "Hemen Sat" icin kullanilir).
  Map<String, Map<String, dynamic>> _guncelFiyatlar = {};
  Timer? _yenileyici;

  int get _oturumId => widget.oturum['id'] as int;

  @override
  void initState() {
    super.initState();
    _veriCek();
    _yenileyici = Timer.periodic(const Duration(seconds: 5), (_) => _veriCek());
  }

  @override
  void dispose() {
    _yenileyici?.cancel();
    super.dispose();
  }

  Future<void> _veriCek() async {
    final d = await _servis.sistemDurumu();
    final a = await _servis.acikPozisyonlar(_oturumId);
    final k = await _servis.kapananIslemler(_oturumId);
    final e = await _servis.equityEgrisi(_oturumId);
    final semboller =
        a.map((p) => p['symbol'] as String).toSet().toList();
    final f = await _servis.guncelFiyatlar(semboller);
    if (mounted) {
      setState(() {
        _durum = d;
        _acik = a;
        _kapanan = k;
        _equity = e;
        _guncelFiyatlar = f;
      });
    }
  }

  Future<void> _durdurmaDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secim = await showDialog<String>(
      context: context,
      builder:
          (c) => AlertDialog(
            backgroundColor: isDark ? const Color(0xFF0C1B31) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.stop_circle_outlined, color: _kLoss, size: 22),
                const SizedBox(width: 8),
                const Text('Sistemi Durdur'),
              ],
            ),
            content: Text(
              'Hızlı çıkış: tüm pozisyonlar şimdiki fiyattan hemen kapanır.\n\n'
              'Yumuşak çıkış: yeni pozisyon açılmaz, mevcutlar kendi stop/hedefine ulaşınca kapanır.',
              style: TextStyle(
                color: isDark ? Colors.white60 : null,
                fontSize: 13,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Vazgeç'),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange,
                  side: const BorderSide(color: Colors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(c, 'SOFT'),
                child: const Text('Yumuşak'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kLoss,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(c, 'HARD'),
                child: const Text('Hızlı Çıkış'),
              ),
            ],
          ),
    );
    if (secim == null) return;
    if (secim == 'HARD') {
      // Hizli cikis: motoru beklemeden tum acik pozisyonlari hemen
      // guncel piyasa fiyatindan kapat, sonra oturumu DOGRUDAN STOPPED'a
      // al. Motoru beklemeyiz; bilgisayar kapali olsa bile cikis anlik.
      final semboller =
          _acik.map((p) => p['symbol'] as String).toSet().toList();
      final fiyatlar = await _servis.guncelFiyatlar(semboller);
      // Acik pozisyonlari paralelde kapat (her biri tek update sorgusu).
      await Future.wait(_acik.map((p) async {
        final sem = p['symbol'] as String;
        final g = (fiyatlar[sem]?['fiyat'] as num?)?.toDouble() ??
            (p['entry_px'] as num).toDouble();
        try {
          await _servis.pozisyonAnindaKapat(
            p['id'] as int,
            (p['entry_px'] as num).toDouble(),
            (p['qty'] as num).toDouble(),
            g,
          );
        } catch (_) {
          // Tek pozisyonda hata cikarsa digerleri kapanmaya devam etsin.
        }
      }));
      // Oturumu hemen STOPPED'a al (STOP_REQUESTED'ta donup kalmasin).
      await _servis.oturumTamamenDurdur(_oturumId, 'HARD');
    } else {
      // SOFT: pozisyonlar kendi stop/hedefine birakilir, motora bildir.
      await _servis.oturumDurdur(_oturumId, secim);
    }
    widget.onDegisti();
  }

  double get _sermaye => (widget.oturum['capital'] as num).toDouble();
  double get _sonEquity =>
      _equity.isEmpty ? _sermaye : (_equity.last['equity'] as num).toDouble();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final getiriYuzde = (_sonEquity / _sermaye - 1) * 100;
    final durdurmaBekliyor = widget.oturum['status'] == 'STOP_REQUESTED';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // ── Başlık ───────────────────────────────────────────────
        if (isDark) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _kTeal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kTeal.withValues(alpha: 0.25)),
                    ),
                    child: const Icon(
                      Icons.auto_graph_rounded,
                      color: _kTeal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Algo Trade',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Canlı İzleme',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Canlı göstergesi
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _kTeal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kTeal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _kTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'CANLI',
                      style: TextStyle(
                        color: _kTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],

        // ── Sistem Durumu Banner ─────────────────────────────────
        _sistemBanner(isDark),

        // ── Durdurma bekleniyor ──────────────────────────────────
        if (durdurmaBekliyor)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.hourglass_top_rounded,
                  color: Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Durdurma istendi. Pozisyonlar seçilen moda göre kapatılıyor...',
                    style: TextStyle(color: Colors.orange, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

        // ── Özet Kartı ───────────────────────────────────────────
        _ozetKart(isDark, getiriYuzde),

        // ── Equity Grafiği ───────────────────────────────────────
        _equityKart(isDark),

        // ── Açık Pozisyonlar ─────────────────────────────────────
        _pozisyonKart(isDark),

        // ── Kapanan İşlemler ─────────────────────────────────────
        _kapananKart(isDark),

        const SizedBox(height: 8),

        // ── Durdur Butonu ────────────────────────────────────────
        if (!durdurmaBekliyor)
          Container(
            height: 54,
            decoration: BoxDecoration(
              color: _kLoss.withValues(alpha: isDark ? 0.15 : 1.0),
              borderRadius: BorderRadius.circular(14),
              border:
                  isDark
                      ? Border.all(
                        color: _kLoss.withValues(alpha: 0.35),
                        width: 1,
                      )
                      : null,
              boxShadow:
                  isDark
                      ? [
                        BoxShadow(
                          color: _kLoss.withValues(alpha: 0.20),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                      : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: _durdurmaDialog,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.stop_circle_outlined,
                      color: isDark ? _kLoss : Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Durdur ve Çek',
                      style: TextStyle(
                        color: isDark ? _kLoss : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Sistem Banner ───────────────────────────────────────────────
  Widget _sistemBanner(bool isDark) {
    if (_durum == null) return const SizedBox.shrink();
    final calisiyor = _durum!['calisiyor'] == true;
    final borsaAcik = _durum!['borsaAcik'] == true;
    final Color renk =
        !calisiyor ? _kLoss : (borsaAcik ? _kProfit : Colors.blueGrey);
    final yazi =
        !calisiyor
            ? 'Sistem kapalı'
            : (borsaAcik
                ? 'Sistem çalışıyor · Borsa açık'
                : 'Sistem çalışıyor · Borsa kapalı');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration:
          isDark
              ? BoxDecoration(
                color: const Color(0xFF132040),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: renk.withValues(alpha: 0.45),
                  width: 1,
                ),
              )
              : BoxDecoration(
                color: renk.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  yazi,
                  style: TextStyle(
                    color: renk,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if ((_durum!['mesaj'] ?? '').isNotEmpty) ...[
                  Text(
                    (_durum!['mesaj'] ?? '').toString(),
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Özet Kartı ──────────────────────────────────────────────────
  Widget _ozetKart(bool isDark, double getiriYuzde) {
    final pozitif = getiriYuzde >= 0;
    final getiriRenk = pozitif ? _kProfit : _kLoss;

    return _glassContainer(
      isDark,
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kartBaslik(isDark, 'Portföy Özeti', Icons.pie_chart_outline_rounded),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ozetParca(
                isDark,
                'Başlangıç',
                '₺${_sermaye.toStringAsFixed(0)}',
                null,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _ozetParca(
                isDark,
                'Güncel',
                '₺${_sonEquity.toStringAsFixed(0)}',
                null,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              _ozetParca(
                isDark,
                'Getiri',
                '${pozitif ? '+' : ''}${getiriYuzde.toStringAsFixed(2)}%',
                getiriRenk,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ozetParca(bool isDark, String baslik, String deger, Color? renk) {
    return Column(
      children: [
        Text(
          baslik,
          style: TextStyle(
            color: isDark ? Colors.white38 : Colors.grey,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          deger,
          style: TextStyle(
            color: renk ?? (isDark ? Colors.white : Colors.black87),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ── Equity Grafiği ───────────────────────────────────────────────
  Widget _equityKart(bool isDark) {
    if (_equity.length < 2) {
      return _glassContainer(
        isDark,
        margin: const EdgeInsets.only(bottom: 14),
        child: Column(
          children: [
            _kartBaslik(isDark, 'Portföy Eğrisi', Icons.show_chart_rounded),
            const SizedBox(height: 20),
            Icon(
              Icons.bar_chart_rounded,
              color: isDark ? Colors.white12 : Colors.grey.shade300,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              'Yeterli veri oluşunca grafik gelir.',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    final noktalar = <FlSpot>[];
    for (var i = 0; i < _equity.length; i++) {
      noktalar.add(
        FlSpot(i.toDouble(), (_equity[i]['equity'] as num).toDouble()),
      );
    }
    final min = noktalar.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    final max = noktalar.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final isProfit = noktalar.last.y >= noktalar.first.y;
    final lineColor = isProfit ? _kTeal : _kLoss;
    // Equity henuz oynamadiysa (max == min) interval 0 olur ve fl_chart
    // assertion atar. Bu durumda kucuk bir mutlak dolgu ekleyip grafik
    // duzgun cizilir.
    final yRange = max - min;
    final yPad = yRange > 0 ? yRange * 0.005 : (max.abs() * 0.002 + 1);
    final minY = min - yPad;
    final maxY = max + yPad;
    final hAralik = (maxY - minY) / 4;

    return _glassContainer(
      isDark,
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kartBaslik(isDark, 'Portföy Eğrisi', Icons.show_chart_rounded),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: hAralik,
                  getDrawingHorizontalLine:
                      (_) => FlLine(
                        color: Colors.white.withValues(alpha: 0.05),
                        strokeWidth: 1,
                      ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 52,
                      getTitlesWidget:
                          (val, _) => Text(
                            '₺${(val / 1000).toStringAsFixed(0)}K',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 10,
                            ),
                          ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: noktalar,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: lineColor,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withValues(alpha: 0.20),
                          lineColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Açık Pozisyonlar ─────────────────────────────────────────────
  Widget _pozisyonKart(bool isDark) {
    return _glassContainer(
      isDark,
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kartBaslik(
            isDark,
            'Açık Pozisyonlar',
            Icons.trending_up_rounded,
            badge: _acik.length,
          ),
          const SizedBox(height: 12),
          if (_acik.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Şu an açık pozisyon yok.',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...(_acik.map((p) => _pozisyonItem(isDark, p))),
        ],
      ),
    );
  }

  // Zaman damgasini bicimlendirir. Bugune aitse 'HH:mm', degilse
  // 'g Ay HH:mm' (orn '13 Haz 18:00') olarak gosterilir. Boylece
  // verinin ne kadar eski oldugu net anlasilir.
  String _saatFormat(dynamic ts) {
    if (ts == null) return '—';
    const aylar = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    try {
      final t = ts is DateTime ? ts : DateTime.parse(ts.toString());
      final y = t.toLocal();
      final simdi = DateTime.now();
      final saat =
          '${y.hour.toString().padLeft(2, '0')}:${y.minute.toString().padLeft(2, '0')}';
      final ayniGun = y.year == simdi.year &&
          y.month == simdi.month &&
          y.day == simdi.day;
      if (ayniGun) return saat;
      return '${y.day} ${aylar[y.month - 1]} $saat';
    } catch (_) {
      return '—';
    }
  }

  Widget _pozisyonItem(bool isDark, Map<String, dynamic> p) {
    final sembol = p['symbol'] as String? ?? '?';
    final giris = (p['entry_px'] as num).toDouble();
    final adet = (p['qty'] as num).toDouble();
    final stop = (p['stop_px'] as num).toDouble();
    final hedef = (p['tp_px'] as num).toDouble();
    final girisSaat = _saatFormat(p['entry_ts']);

    final guncelMap = _guncelFiyatlar[sembol];
    final guncel =
        (guncelMap?['fiyat'] as num?)?.toDouble();
    final guncelSaat =
        guncelMap == null ? '—' : _saatFormat(guncelMap['ts']);
    final kzYuzde = (guncel != null && giris > 0)
        ? ((guncel - giris) / giris) * 100
        : null;
    final pozitif = (kzYuzde ?? 0) >= 0;
    final kzRengi = pozitif ? _kProfit : _kLoss;

    final mutedRengi = isDark ? Colors.white54 : Colors.grey.shade600;
    final govde = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? _kInnerGlass : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: _kGlassBorder, width: 1) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _stopTpDuzenle(p),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baslik: avatar + sembol + duzenle + ⚡
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _kTeal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: _kTeal.withValues(alpha: 0.25)),
                    ),
                    child: Center(
                      child: Text(
                        sembol.substring(
                            0, sembol.length >= 2 ? 2 : 1),
                        style: const TextStyle(
                          color: _kTeal,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          sembol,
                          style: TextStyle(
                            color: govde,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.edit_outlined,
                            size: 14, color: mutedRengi),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.flash_on,
                        color: _kLoss, size: 24),
                    tooltip: 'Hemen Sat',
                    onPressed: guncel == null
                        ? null
                        : () => _anlikSat(p, guncel),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Bilgi satirlari
              _pozBilgiSatir(mutedRengi, govde, 'Adet',
                  adet.toStringAsFixed(1)),
              const SizedBox(height: 6),
              _pozBilgiSatir(mutedRengi, govde, 'Giriş',
                  '₺${giris.toStringAsFixed(2)}  ·  $girisSaat'),
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    width: 64,
                    child: Text(
                      'Güncel',
                      style: TextStyle(
                          color: mutedRengi, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      guncel == null
                          ? '—'
                          : '₺${guncel.toStringAsFixed(2)}  ·  $guncelSaat',
                      style: TextStyle(
                        color: govde,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (kzYuzde != null)
                    Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: kzRengi.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: kzRengi.withValues(alpha: 0.4),
                            width: 0.5),
                      ),
                      child: Text(
                        '${pozitif ? '+' : ''}'
                        '${kzYuzde.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: kzRengi,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 1,
                color: mutedRengi.withValues(alpha: 0.18),
              ),
              const SizedBox(height: 10),
              // Stop ve Hedef alt sira
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Stop',
                              style: TextStyle(
                                  color: mutedRengi, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '₺${stop.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: _kLoss,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Hedef',
                              style: TextStyle(
                                  color: mutedRengi, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            '₺${hedef.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: _kProfit,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pozBilgiSatir(
      Color etiketRengi, Color degerRengi, String etiket, String deger) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(etiket,
              style: TextStyle(color: etiketRengi, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            deger,
            style: TextStyle(
              color: degerRengi,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Stop ve hedef fiyatini duzenleme diyalogu. Kaydedince Supabase'deki
  // satir guncellenir; motor sonraki turda bu degerleri kullanir.
  Future<void> _stopTpDuzenle(Map<String, dynamic> p) async {
    final stopCtrl = TextEditingController(
        text: (p['stop_px'] as num).toStringAsFixed(2));
    final tpCtrl = TextEditingController(
        text: (p['tp_px'] as num).toStringAsFixed(2));
    final giris = (p['entry_px'] as num).toDouble();
    final sonuc = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('${p['symbol']} - Stop ve Hedef'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Giriş fiyatı: ₺${giris.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: stopCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Stop fiyatı (₺)',
                  border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: tpCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Hedef fiyatı (₺)',
                  border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Vazgeç')),
          ElevatedButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Kaydet')),
        ],
      ),
    );
    if (sonuc != true) return;
    final yeniStop = double.tryParse(stopCtrl.text.replaceAll(',', '.'));
    final yeniTp = double.tryParse(tpCtrl.text.replaceAll(',', '.'));
    if (yeniStop == null || yeniTp == null) {
      _uyari('Geçerli sayı girin.');
      return;
    }
    if (yeniStop >= giris || yeniTp <= giris) {
      _uyari('Stop giriş altında, Hedef giriş üstünde olmalı.');
      return;
    }
    try {
      await _servis.pozisyonGuncelle(p['id'] as int, yeniStop, yeniTp);
      _veriCek();
    } catch (e) {
      _uyari('Güncellenemedi: $e');
    }
  }

  // Tek pozisyonu motoru beklemeden satar. Komisyon ve slippage motorla
  // aynı kuralla uygulanır.
  Future<void> _anlikSat(Map<String, dynamic> p, double guncelFiyat) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('${p['symbol']} - Hemen Sat'),
        content: Text(
          'Bu pozisyon su anki piyasa fiyatından (₺${guncelFiyat.toStringAsFixed(2)}) '
          'anında kapatılacak. Motor beklenmez.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Vazgeç')),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kLoss),
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Sat')),
        ],
      ),
    );
    if (onay != true) return;
    try {
      await _servis.pozisyonAnindaKapat(
        p['id'] as int,
        (p['entry_px'] as num).toDouble(),
        (p['qty'] as num).toDouble(),
        guncelFiyat,
      );
      _veriCek();
    } catch (e) {
      _uyari('Satış başarısız: $e');
    }
  }

  void _uyari(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mesaj)));
  }

  // ── Kapanan İşlemler ─────────────────────────────────────────────
  Widget _kapananKart(bool isDark) {
    return _glassContainer(
      isDark,
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _kartBaslik(isDark, 'Son Kapanan İşlemler', Icons.history_rounded),
          const SizedBox(height: 12),
          if (_kapanan.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'Henüz kapanan işlem yok.',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ),
            )
          else
            ...(_kapanan.take(10).map((k) => _kapananItem(isDark, k))),
        ],
      ),
    );
  }

  Widget _kapananItem(bool isDark, Map<String, dynamic> k) {
    final pnl = (k['pnl'] as num?)?.toDouble() ?? 0;
    final pozitif = pnl >= 0;
    final renk = pozitif ? _kProfit : _kLoss;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? renk.withValues(alpha: 0.06) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border:
            isDark
                ? Border.all(color: renk.withValues(alpha: 0.15), width: 1)
                : null,
      ),
      child: Row(
        children: [
          Icon(
            pozitif ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: renk,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  k['symbol'] ?? '',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Neden: ${k['exit_reason'] ?? '-'}',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${pozitif ? '+' : ''}${pnl.toStringAsFixed(2)} ₺',
            style: TextStyle(
              color: renk,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ── Yardımcı widget'lar ──────────────────────────────────────────
  Widget _glassContainer(
    bool isDark, {
    required Widget child,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      decoration:
          isDark
              ? BoxDecoration(
                color: _kGlass,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _kGlassBorder, width: 1),
              )
              : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
      child: child,
    );
  }

  Widget _kartBaslik(bool isDark, String baslik, IconData icon, {int? badge}) {
    return Row(
      children: [
        Icon(icon, color: isDark ? _kTeal : const Color(0xFF102C57), size: 18),
        const SizedBox(width: 8),
        Text(
          baslik,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (badge != null && badge > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _kTeal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kTeal.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$badge',
              style: const TextStyle(
                color: _kTeal,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
