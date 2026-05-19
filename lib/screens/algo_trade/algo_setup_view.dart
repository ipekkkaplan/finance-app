// Algo trade kurulum ekrani.
//
// Kullanici sanal sermayesini girer, kontrol modunu secer ve baslatir.
// Risk profili tekrar SORULMAZ; mevcut anketten okunup gosterilir.

import 'package:flutter/material.dart';

import '../../services/algo_trade_service.dart';

// config.py icindeki SECTORS listesiyle ayni 17 sektor.
const _sektorler = [
  'Araci Kurum', 'Bankacilik', 'Cimento', 'Dayanikli Tuketim', 'Enerji',
  'GYO', 'Gida', 'Holding', 'Metal Ana Sanayi', 'Otomotiv', 'Perakende',
  'Sanayi', 'Savunma', 'Teknoloji', 'Tekstil', 'Telekom', 'Ulastirma',
];

class AlgoSetupView extends StatefulWidget {
  final VoidCallback onBasladi;
  const AlgoSetupView({super.key, required this.onBasladi});

  @override
  State<AlgoSetupView> createState() => _AlgoSetupViewState();
}

class _AlgoSetupViewState extends State<AlgoSetupView> {
  final _servis = AlgoTradeService.instance;
  final _sermayeCtrl = TextEditingController(text: '100000');
  final _beyazCtrl = TextEditingController();
  final _karaCtrl = TextEditingController();

  String _riskProfili = 'Dengeli';
  String _mod = 'AUTO';
  final Set<String> _secilenSektorler = {};
  bool _gonderiliyor = false;

  @override
  void initState() {
    super.initState();
    _servis.riskProfiliGetir().then((p) {
      if (mounted) setState(() => _riskProfili = p);
    });
  }

  @override
  void dispose() {
    _sermayeCtrl.dispose();
    _beyazCtrl.dispose();
    _karaCtrl.dispose();
    super.dispose();
  }

  List<String> _virgulluListe(String s) => s
      .split(',')
      .map((e) => e.trim().toUpperCase())
      .where((e) => e.isNotEmpty)
      .toList();

  Future<void> _baslat() async {
    final sermaye = double.tryParse(_sermayeCtrl.text.trim());
    if (sermaye == null || sermaye <= 0) {
      _uyari('Gecerli bir sermaye girin.');
      return;
    }
    if (_mod == 'SECTOR' && _secilenSektorler.isEmpty) {
      _uyari('Sektor modunda en az bir sektor secin.');
      return;
    }
    if (_mod == 'WHITELIST' && _virgulluListe(_beyazCtrl.text).isEmpty) {
      _uyari('Hisse modunda en az bir hisse girin.');
      return;
    }
    setState(() => _gonderiliyor = true);
    try {
      await _servis.oturumBaslat(
        sermaye: sermaye,
        riskProfili: _riskProfili,
        mod: _mod,
        izinliSektorler: _secilenSektorler.toList(),
        beyazListe: _virgulluListe(_beyazCtrl.text),
        karaListe: _virgulluListe(_karaCtrl.text),
      );
      widget.onBasladi();
    } catch (e) {
      _uyari('Baslatilamadi: $e');
    } finally {
      if (mounted) setState(() => _gonderiliyor = false);
    }
  }

  void _uyari(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _kart(
          theme,
          'Sanal Sermaye',
          'Gercek para degil. Sistem bu tutarla kagit uzerinde islem yapar.',
          TextField(
            controller: _sermayeCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: '₺ ',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        _kart(
          theme,
          'Risk Profili',
          'Mevcut risk anketinden alindi, tekrar sorulmaz.',
          Row(
            children: [
              Icon(Icons.shield_outlined, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(_riskProfili,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        _kart(
          theme,
          'Kontrol Modu',
          'Algoritmanin hangi hisselerde islem yapacagini sen belirlersin.',
          Column(
            children: [
              _modSecenek('AUTO', 'Tam otomatik',
                  'Algoritma BIST icinden kendi secer.'),
              _modSecenek('SECTOR', 'Sektor tercihi',
                  'Sadece sectigin sektorlerde islem yapar.'),
              _modSecenek('WHITELIST', 'Hisse listesi',
                  'Sadece beyaz listedeki hisselerde islem yapar.'),
            ],
          ),
        ),
        if (_mod == 'SECTOR')
          _kart(
            theme,
            'Izinli Sektorler',
            'Birden fazla secebilirsin.',
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _sektorler.map((s) {
                final secili = _secilenSektorler.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: secili,
                  onSelected: (v) => setState(() {
                    v ? _secilenSektorler.add(s) : _secilenSektorler.remove(s);
                  }),
                );
              }).toList(),
            ),
          ),
        if (_mod == 'WHITELIST')
          _kart(
            theme,
            'Beyaz Liste (al)',
            'Hisse kodlarini virgulle ayir. Ornek: THYAO, ASELS, GARAN',
            TextField(
              controller: _beyazCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        _kart(
          theme,
          'Kara Liste (dokunma) - istege bagli',
          'Bu hisselerde her modda islem yapilmaz. Ornek: SASA, KRDMD',
          TextField(
            controller: _karaCtrl,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _gonderiliyor ? null : _baslat,
            icon: _gonderiliyor
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow),
            label: const Text('Sistemi Baslat',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _modSecenek(String deger, String baslik, String aciklama) {
    return RadioListTile<String>(
      value: deger,
      groupValue: _mod,
      onChanged: (v) => setState(() => _mod = v!),
      title: Text(baslik),
      subtitle: Text(aciklama),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _kart(ThemeData t, String baslik, String alt, Widget icerik) {
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
            const SizedBox(height: 4),
            Text(alt, style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            icerik,
          ],
        ),
      ),
    );
  }
}
