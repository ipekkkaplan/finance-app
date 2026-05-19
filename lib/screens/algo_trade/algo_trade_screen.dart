// Algo Trade ana ekrani.
//
// Akis: kullanicinin acik oturumu yoksa kurulum ekrani gosterilir
// (sermaye, mod, baslat). Acik oturum varsa canli izleme gosterilir
// (sistem/borsa durumu, equity, pozisyonlar, durdur).

import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/algo_trade_service.dart';
import 'algo_setup_view.dart';
import 'algo_live_view.dart';

class AlgoTradeScreen extends StatefulWidget {
  const AlgoTradeScreen({super.key});

  @override
  State<AlgoTradeScreen> createState() => _AlgoTradeScreenState();
}

class _AlgoTradeScreenState extends State<AlgoTradeScreen> {
  final _servis = AlgoTradeService.instance;
  Map<String, dynamic>? _oturum;
  bool _yukleniyor = true;
  Timer? _zamanlayici;

  @override
  void initState() {
    super.initState();
    _durumuYenile();
    // Veriler dakikalik guncellendigi icin 20 saniyede bir tazelenir.
    _zamanlayici = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _durumuYenile(sessiz: true),
    );
  }

  @override
  void dispose() {
    _zamanlayici?.cancel();
    super.dispose();
  }

  Future<void> _durumuYenile({bool sessiz = false}) async {
    if (!sessiz) setState(() => _yukleniyor = true);
    try {
      final o = await _servis.aktifOturum();
      if (mounted) {
        setState(() {
          _oturum = o;
          _yukleniyor = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: const Text('Algo Trade',
            style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _durumuYenile,
              child: _oturum == null
                  ? AlgoSetupView(onBasladi: _durumuYenile)
                  : AlgoLiveView(
                      oturum: _oturum!,
                      onDegisti: _durumuYenile,
                    ),
            ),
    );
  }
}
