import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/signal_model.dart';
import '../models/stock_model.dart';
import '../models/valuation_model.dart';
import 'data_service.dart';

/// Değerleme + temel finansal veriden kural tabanlı al-sat sinyali üretir.
///
/// Not: Gerçek zamanlı fiyat geçmişi yok (OHLC/RSI/MACD mümkün değil).
/// Bu yüzden sinyaller temel analiz ağırlıklı — mock değil, ama sınırlı.
class SignalsService {
  final DataService _dataService = DataService();

  List<SignalModel>? _cache;

  /// Tüm hisseler için sinyal listesi döndürür. Veri bulunamayan hisseler atlanır.
  Future<List<SignalModel>> getAllSignals() async {
    if (_cache != null) return _cache!;

    final valuations = await _dataService.loadValuationData();
    final stockByKod = await _loadAllStocks();

    final List<SignalModel> result = [];
    for (final v in valuations) {
      final stock = stockByKod[v.hisseKodu];
      if (stock == null) continue; // Detay yoksa sinyal üretme
      final signal = _generateFor(stock, v);
      if (signal != null) result.add(signal);
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

  /// Belirli bir hisse için sinyal üret (company detail ekranında kullanılır).
  Future<SignalModel?> getSignalFor(String hisseKodu) async {
    final signals = await getAllSignals();
    try {
      return signals.firstWhere((s) => s.hisseKodu == hisseKodu);
    } catch (_) {
      return null;
    }
  }

  /// hisse_ayrinti.json'u bir kerede okuyup hisseKodu → StockModel map'i döndürür.
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

  // --- Kural motoru ---
  SignalModel? _generateFor(StockModel stock, ValuationModel v) {
    final double skor = v.finalSkor;
    final double roa = stock.roa;
    final double fk = stock.fk;

    SignalType type;
    if (skor > 0.6 && roa > 5 && fk < 3) {
      type = SignalType.strongBuy;
    } else if (skor > 0.5 && roa > 3) {
      type = SignalType.buy;
    } else if (skor > 0.3) {
      type = SignalType.hold;
    } else {
      type = SignalType.sell;
    }

    // Güven: final_skor'u sinyal türüne göre normalize et.
    double confidence;
    switch (type) {
      case SignalType.strongBuy:
      case SignalType.buy:
        confidence = (skor.clamp(0.5, 1.0) - 0.5) / 0.5;
        break;
      case SignalType.hold:
        confidence = 1 - (skor - 0.4).abs() / 0.1;
        break;
      case SignalType.sell:
        confidence = (0.3 - skor.clamp(0, 0.3)) / 0.3;
        break;
    }
    confidence = confidence.clamp(0.0, 1.0);

    final reason =
        'Değerleme: ${v.etiket}. ROA %${roa.toStringAsFixed(1)}, FK ${fk.toStringAsFixed(1)}.';

    return SignalModel(
      hisseKodu: stock.hisseKodu,
      sirketIsmi: stock.sirketIsmi,
      sektor: stock.sektor,
      type: type,
      confidence: confidence,
      reason: reason,
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
