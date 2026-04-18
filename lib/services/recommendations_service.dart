import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/recommendation_model.dart';
import '../models/stock_model.dart';
import 'data_service.dart';
import 'risk_data_service.dart';

/// Hisse alım önerisi motoru. Değerleme + temel analiz + risk raporu birleştirir.
///
/// Kategoriler: Tümü / Değer Odaklı / Yüksek Temettü / Düşük Risk.
class RecommendationsService {
  final DataService _dataService = DataService();
  final RiskDataService _riskService = RiskDataService();

  List<RecommendationModel>? _cache;

  Future<List<RecommendationModel>> getTopRecommendations({
    int limit = 20,
    RecommendationCategory category = RecommendationCategory.all,
  }) async {
    final all = await _buildAll();

    // Kategoriye göre filtrele
    final filtered = all.where((r) {
      switch (category) {
        case RecommendationCategory.all:
          return true;
        case RecommendationCategory.value:
          return r.reasons.any((x) => x.toLowerCase().contains('ucuz'));
        case RecommendationCategory.highYield:
          return r.reasons.any((x) => x.contains('Temettü') && !x.contains('yok'));
        case RecommendationCategory.lowRisk:
          return r.reasons.any((x) => x.toLowerCase().contains('düşük risk'));
      }
    }).toList();

    return filtered.take(limit).toList();
  }

  Future<List<RecommendationModel>> _buildAll() async {
    if (_cache != null) return _cache!;

    final valuations = await _dataService.loadValuationData();
    final stockByKod = await _loadAllStocks();
    final riskByKod = await _riskService.loadAll();

    // Normalizasyon için max değerleri bul
    double maxRoa = 0, maxHacim = 0, maxTemettu = 0, maxReturn = 0;
    for (final v in valuations) {
      final s = stockByKod[v.hisseKodu];
      if (s == null) continue;
      if (s.roa > maxRoa) maxRoa = s.roa;
      if (s.hacim > maxHacim) maxHacim = s.hacim;
      final t = s.temettuVerimliligi ?? 0;
      if (t > maxTemettu) maxTemettu = t;
      final r = riskByKod[v.hisseKodu]?.potansiyelGetiriYuzde ?? 0;
      if (r > maxReturn) maxReturn = r;
    }
    if (maxRoa <= 0) maxRoa = 1;
    if (maxHacim <= 0) maxHacim = 1;
    if (maxTemettu <= 0) maxTemettu = 1;
    if (maxReturn <= 0) maxReturn = 1;

    final result = <RecommendationModel>[];
    for (final v in valuations) {
      final s = stockByKod[v.hisseKodu];
      if (s == null) continue;

      final risk = riskByKod[v.hisseKodu];
      final potReturn = risk?.potansiyelGetiriYuzde ?? 0;

      final roaNorm = (s.roa / maxRoa).clamp(0.0, 1.0);
      final hacimNorm = (s.hacim / maxHacim).clamp(0.0, 1.0);
      final temettuNorm =
          ((s.temettuVerimliligi ?? 0) / maxTemettu).clamp(0.0, 1.0);
      final returnNorm = (potReturn / maxReturn).clamp(0.0, 1.0);

      final score = v.finalSkor * 0.40 +
          roaNorm * 0.25 +
          hacimNorm * 0.15 +
          temettuNorm * 0.10 +
          returnNorm * 0.10;

      // Sebep cümleleri (UI'da 3 madde gösterilir)
      final reasons = <String>[];
      if (v.etiket == 'Ucuz') reasons.add('Sektör ortalamasından ucuz (skor ${v.finalSkor.toStringAsFixed(2)})');
      if (s.roa > 5) reasons.add('ROA yüksek (%${s.roa.toStringAsFixed(1)})');
      if ((s.temettuVerimliligi ?? 0) > 0.05) {
        reasons.add('Temettü verimi yüksek (%${((s.temettuVerimliligi ?? 0) * 100).toStringAsFixed(1)})');
      }
      if (risk != null && risk.nihaiRiskSkoru < 35) {
        reasons.add('Düşük risk skoru (${risk.nihaiRiskSkoru.toStringAsFixed(0)}/100)');
      }
      if (potReturn > 15) {
        reasons.add('Potansiyel getiri %${potReturn.toStringAsFixed(1)}');
      }
      if (reasons.isEmpty) {
        reasons.add('Genel performans: skor ${score.toStringAsFixed(2)}');
      }

      result.add(RecommendationModel(
        hisseKodu: s.hisseKodu,
        sirketIsmi: s.sirketIsmi,
        sektor: s.sektor,
        totalScore: score.clamp(0.0, 1.0),
        potentialReturn: risk?.potansiyelGetiriYuzde,
        reasons: reasons.take(3).toList(),
      ));
    }

    result.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    _cache = result;
    return result;
  }

  /// hisse_ayrinti.json'u bir kerede okur. (signals_service ile ortak olabilirdi,
  /// ama servisler birbirine bağımlı olmasın diye bilinçli duplicate.)
  Future<Map<String, StockModel>> _loadAllStocks() async {
    String jsonString = '';
    try {
      jsonString = await rootBundle.loadString('assets/hisse_ayrinti.json');
    } catch (_) {
      try {
        jsonString =
            await rootBundle.loadString('assets/json/hisse_ayrinti.json');
      } catch (e) {
        debugPrint('RecommendationsService: hisse_ayrinti.json okunamadı: $e');
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
      debugPrint('RecommendationsService JSON parse hatası: $e');
      return {};
    }
  }
}
