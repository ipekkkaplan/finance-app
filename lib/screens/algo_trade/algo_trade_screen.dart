// screens/algo_trade/algo_trade_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/di/locator.dart';
import 'algo_setup_view.dart';
import 'algo_live_view.dart';

// ── Tema sabitleri (home_screen ile aynı) ────────────────────────
const _kBgTop = AppColors.bgGradientTop;
const _kBgMid = AppColors.bgGradientMid;
const _kBgBot = AppColors.bgGradientBot;
const _kTeal = AppColors.accentTeal;

class AlgoTradeScreen extends StatefulWidget {
  const AlgoTradeScreen({super.key});

  @override
  State<AlgoTradeScreen> createState() => _AlgoTradeScreenState();
}

class _AlgoTradeScreenState extends State<AlgoTradeScreen> {
  final _servis = locator.algoTrade;
  Map<String, dynamic>? _oturum;
  bool _yukleniyor = true;
  Timer? _zamanlayici;

  @override
  void initState() {
    super.initState();
    _durumuYenile();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _kBgTop : const Color(0xFFF5F5F5),
      body:
          isDark
              ? Stack(
                children: [
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
                  _body(isDark),
                ],
              )
              : _body(isDark),
    );
  }

  Widget _body(bool isDark) {
    if (_yukleniyor) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? _kTeal : null,
          strokeWidth: 2,
        ),
      );
    }
    return RefreshIndicator(
      color: _kTeal,
      onRefresh: _durumuYenile,
      child:
          _oturum == null
              ? AlgoSetupView(onBasladi: _durumuYenile)
              : AlgoLiveView(oturum: _oturum!, onDegisti: _durumuYenile),
    );
  }
}
