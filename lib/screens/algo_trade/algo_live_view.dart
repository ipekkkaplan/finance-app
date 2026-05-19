// Algo trade canli izleme ekrani.
//
// Gosterilenler: sistem/borsa durumu, portfoy ozeti ve equity grafigi,
// acik pozisyonlar, kapanan islemler ve durdurma dugmesi.

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/algo_trade_service.dart';

class AlgoLiveView extends StatefulWidget {
  final Map<String, dynamic> oturum;
  final VoidCallback onDegisti;
  const AlgoLiveView(
      {super.key, required this.oturum, required this.onDegisti});

  @override
  State<AlgoLiveView> createState() => _AlgoLiveViewState();
}

class _AlgoLiveViewState extends State<AlgoLiveView> {
  final _servis = AlgoTradeService.instance;
  Map<String, dynamic>? _durum;
  List<Map<String, dynamic>> _acik = [];
  List<Map<String, dynamic>> _kapanan = [];
  List<Map<String, dynamic>> _equity = [];

  int get _oturumId => widget.oturum['id'] as int;

  @override
  void initState() {
    super.initState();
    _veriCek();
  }

  Future<void> _veriCek() async {
    final d = await _servis.sistemDurumu();
    final a = await _servis.acikPozisyonlar(_oturumId);
    final k = await _servis.kapananIslemler(_oturumId);
    final e = await _servis.equityEgrisi(_oturumId);
    if (mounted) {
      setState(() {
        _durum = d;
        _acik = a;
        _kapanan = k;
        _equity = e;
      });
    }
  }

  Future<void> _durdurmaDialog() async {
    final secim = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Durdur ve Cek'),
        content: const Text(
          'Hizli cikis: tum pozisyonlar simdiki fiyattan hemen kapanir.\n\n'
          'Yumusak cikis: yeni pozisyon acilmaz, mevcutlar kendi '
          'stop/hedefine ulasinca kapanir.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Vazgec')),
          TextButton(
              onPressed: () => Navigator.pop(c, 'SOFT'),
              child: const Text('Yumusak cikis')),
          ElevatedButton(
              onPressed: () => Navigator.pop(c, 'HARD'),
              child: const Text('Hizli cikis')),
        ],
      ),
    );
    if (secim != null) {
      await _servis.oturumDurdur(_oturumId, secim);
      widget.onDegisti();
    }
  }

  double get _sermaye => (widget.oturum['capital'] as num).toDouble();

  double get _sonEquity => _equity.isEmpty
      ? _sermaye
      : (_equity.last['equity'] as num).toDouble();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final getiriYuzde = (_sonEquity / _sermaye - 1) * 100;
    final durdurmaBekliyor = widget.oturum['status'] == 'STOP_REQUESTED';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sistemBanner(theme),
        if (durdurmaBekliyor)
          Card(
            color: Colors.orange.withOpacity(0.15),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                  'Durdurma istendi. Pozisyonlar secilen moda gore '
                  'kapatiliyor...'),
            ),
          ),
        _ozetKart(theme, getiriYuzde),
        _equityKart(theme),
        _pozisyonKart(theme),
        _kapananKart(theme),
        const SizedBox(height: 8),
        if (!durdurmaBekliyor)
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600),
              onPressed: _durdurmaDialog,
              icon: const Icon(Icons.stop),
              label: const Text('Durdur ve Cek',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _sistemBanner(ThemeData t) {
    if (_durum == null) {
      return const SizedBox.shrink();
    }
    final calisiyor = _durum!['calisiyor'] == true;
    final borsaAcik = _durum!['borsaAcik'] == true;
    final renk = !calisiyor
        ? Colors.red
        : (borsaAcik ? Colors.green : Colors.blueGrey);
    final yazi = !calisiyor
        ? 'Sistem kapali (sunucu calismiyor)'
        : (borsaAcik
            ? 'Sistem calisiyor - Borsa acik'
            : 'Sistem calisiyor - Borsa kapali');
    return Card(
      color: renk.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.circle, size: 12, color: renk),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(yazi,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  Text(_durum!['mesaj'] ?? '',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ozetKart(ThemeData t, double getiriYuzde) {
    final pozitif = getiriYuzde >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ozetParca('Baslangic',
                '₺${_sermaye.toStringAsFixed(0)}', t),
            _ozetParca('Guncel',
                '₺${_sonEquity.toStringAsFixed(0)}', t),
            _ozetParca(
              'Getiri',
              '${pozitif ? '+' : ''}${getiriYuzde.toStringAsFixed(2)}%',
              t,
              renk: pozitif ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _ozetParca(String b, String d, ThemeData t, {Color? renk}) {
    return Column(
      children: [
        Text(b, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(d,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: renk ?? t.textTheme.titleLarge?.color)),
      ],
    );
  }

  Widget _equityKart(ThemeData t) {
    if (_equity.length < 2) {
      return _kartSarmal(
          'Portfoy Egrisi', const Text('Yeterli veri olusunca grafik gelir.'));
    }
    final noktalar = <FlSpot>[];
    for (var i = 0; i < _equity.length; i++) {
      noktalar.add(
          FlSpot(i.toDouble(), (_equity[i]['equity'] as num).toDouble()));
    }
    return _kartSarmal(
      'Portfoy Egrisi',
      SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: noktalar,
                isCurved: true,
                color: t.primaryColor,
                barWidth: 2,
                dotData: const FlDotData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pozisyonKart(ThemeData t) {
    return _kartSarmal(
      'Acik Pozisyonlar (${_acik.length})',
      _acik.isEmpty
          ? const Text('Su an acik pozisyon yok.')
          : Column(
              children: _acik.map((p) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p['symbol'] ?? '',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Adet: ${(p['qty'] as num).toStringAsFixed(1)}  '
                      'Giris: ₺${(p['entry_px'] as num).toStringAsFixed(2)}'),
                  trailing: Text(
                      'Stop ₺${(p['stop_px'] as num).toStringAsFixed(2)}\n'
                      'Hedef ₺${(p['tp_px'] as num).toStringAsFixed(2)}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 12)),
                );
              }).toList(),
            ),
    );
  }

  Widget _kapananKart(ThemeData t) {
    return _kartSarmal(
      'Son Kapanan Islemler',
      _kapanan.isEmpty
          ? const Text('Henuz kapanan islem yok.')
          : Column(
              children: _kapanan.take(10).map((k) {
                final pnl = (k['pnl'] as num?)?.toDouble() ?? 0;
                final pozitif = pnl >= 0;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(k['symbol'] ?? ''),
                  subtitle: Text('Neden: ${k['exit_reason'] ?? '-'}'),
                  trailing: Text(
                    '${pozitif ? '+' : ''}${pnl.toStringAsFixed(2)} ₺',
                    style: TextStyle(
                        color: pozitif ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _kartSarmal(String baslik, Widget icerik) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            icerik,
          ],
        ),
      ),
    );
  }
}
