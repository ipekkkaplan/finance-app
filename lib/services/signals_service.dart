import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/analyst_signal_model.dart';
import '../models/signal_model.dart';
import '../models/stock_model.dart';
import '../models/valuation_model.dart';
import 'analyst_signals_service.dart';
import 'data_service.dart';

/// Hisseler için al-sat sinyali üretir.
///
/// Tek kaynak: `assets/finscope_veri_seti.json` (analist yorumları).
/// Tüm sinyaller insan yargılı analiz çıktısıdır. Şirket ismi/sektör
/// `hisse_ayrinti.json` veya `hisse_degerleme_sonuclari.json`'dan zenginleştirilir;
/// bulunamazsa kart sadece hisse kodu + sinyal + gerekçe ile gösterilir.
class SignalsService {
  final DataService _dataService = DataService();
  final AnalystSignalsService _analystService = AnalystSignalsService.instance;

  List<SignalModel>? _cache;

  /// Analist veri setindeki tüm hisseler için sinyal listesi döndürür.
  Future<List<SignalModel>> getAllSignals() async {
    if (_cache != null) return _cache!;

    final analystByKod = await _analystService.loadAll();
    final stockByKod = await _loadAllStocks();
    final valuationByKod = await _loadValuationLookup();

    final List<SignalModel> result = [];
    for (final entry in analystByKod.entries) {
      final code = entry.key;
      final analyst = entry.value;

      String sirketIsmi = '';
      String sektor = '';

      final stock = stockByKod[code];
      if (stock != null) {
        sirketIsmi = stock.sirketIsmi;
        sektor = stock.sektor;
      } else {
        final v = valuationByKod[code];
        if (v != null) sektor = v.sektor;
      }

      result.add(_fromAnalyst(
        hisseKodu: code,
        sirketIsmi: sirketIsmi,
        sektor: sektor,
        analyst: analyst,
      ));
    }

    // Güçlü al → al → bekle → sat; aynı türde güven yüksekten düşüğe
    result.sort((a, b) {
      final rankA = _rank(a.type);
      final rankB = _rank(b.type);
      if (rankA != rankB) return rankA.compareTo(rankB);
      return b.confidence.compareTo(a.confidence);
    });
    _cache = result;
    return result;
  }

  /// Belirli bir hisse için sinyal döndürür (company detail rozeti için).
  Future<SignalModel?> getSignalFor(String hisseKodu) async {
    final signals = await getAllSignals();
    try {
      return signals.firstWhere((s) => s.hisseKodu == hisseKodu);
    } catch (_) {
      return null;
    }
  }

  /// hisse_ayrinti.json'u okuyup hisseKodu → StockModel map'i döndürür.
  /// Sadece şirket ismi/sektör zenginleştirmesi için kullanılır.
  Future<Map<String, StockModel>> _loadAllStocks() async {
    String jsonString = '';
    try {
      jsonString = await rootBundle.loadString('assets/hisse_ayrinti.json');
    } catch (_) {
      try {
        jsonString =
            await rootBundle.loadString('assets/json/hisse_ayrinti.json');
      } catch (e) {
        debugPrint('SignalsService: hisse_ayrinti.json okunamadı: $e');
        return {};
      }
    }

    try {
      final List<dynamic> data = json.decode(jsonString);
      final map = <String, StockModel>{};
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final stock = StockModel.fromJson(item);
        if (stock.hisseKodu.isNotEmpty) map[stock.hisseKodu] = stock;
      }
      return map;
    } catch (e) {
      debugPrint('SignalsService JSON parse hatası: $e');
      return {};
    }
  }

  /// hisse_degerleme_sonuclari.json'dan hisseKodu → ValuationModel map'i.
  /// Sadece sektör zenginleştirmesi için kullanılır (ayrinti'da olmayan hisseler).
  Future<Map<String, ValuationModel>> _loadValuationLookup() async {
    final valuations = await _dataService.loadValuationData();
    final map = <String, ValuationModel>{};
    for (final v in valuations) {
      if (v.hisseKodu.isNotEmpty) map[v.hisseKodu] = v;
    }
    return map;
  }

  // --- Analist datasından sinyal kartı ---
  SignalModel _fromAnalyst({
    required String hisseKodu,
    required String sirketIsmi,
    required String sektor,
    required AnalystSignalModel analyst,
  }) {
    // Analist yorumu insan-yargılı olduğu için güveni yüksek tutuyoruz.
    final type = analyst.signalType;
    final double confidence;
    switch (type) {
      case SignalType.strongBuy:
        confidence = 0.92;
        break;
      case SignalType.buy:
      case SignalType.sell:
        confidence = 0.85;
        break;
      case SignalType.hold:
        confidence = 0.70;
        break;
    }

    return SignalModel(
      hisseKodu: hisseKodu,
      sirketIsmi: sirketIsmi,
      sektor: sektor,
      type: type,
      confidence: confidence,
      reason: analyst.gerekce.isNotEmpty
          ? analyst.gerekce
          : 'Analist görüşüne göre sinyal üretildi.',
    );
  }

  int _rank(SignalType t) {
    switch (t) {
      case SignalType.strongBuy:
        return 0;
      case SignalType.buy:
        return 1;
      case SignalType.hold:
        return 2;
      case SignalType.sell:
        return 3;
    }
  }
}
