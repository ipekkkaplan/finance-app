import 'dart:convert';

import 'package:flutter/services.dart';
import '../core/utils/app_logger.dart';

/// assets/Nihai_Risk_Raporu.json dosyasını okur.
/// Hisse kodu → risk skoru + potansiyel getiri + detay sözlüğü döndürür.
class RiskDataService {
  Map<String, RiskReport>? _cache;

  Future<Map<String, RiskReport>> loadAll() async {
    if (_cache != null) return _cache!;

    try {
      final jsonString =
          await rootBundle.loadString('assets/Nihai_Risk_Raporu.json');
      final List<dynamic> list = json.decode(jsonString);

      final map = <String, RiskReport>{};
      for (final raw in list) {
        if (raw is! Map) continue;
        final kod = (raw['HisseKodu'] ?? '').toString();
        if (kod.isEmpty) continue;
        map[kod] = RiskReport(
          hisseKodu: kod,
          nihaiRiskSkoru: (raw['Nihai_Risk_Skoru'] ?? 0).toDouble(),
          potansiyelGetiriYuzde:
              (raw['Potansiyel_Getiri_Yuzde'] ?? 0).toDouble(),
        );
      }
      _cache = map;
      return map;
    } catch (e) {
      AppLogger.error('RiskDataService', e);
      _cache = {};
      return _cache!;
    }
  }
}

class RiskReport {
  final String hisseKodu;
  final double nihaiRiskSkoru; // 0 (düşük risk) - 100 (yüksek risk)
  final double potansiyelGetiriYuzde;

  const RiskReport({
    required this.hisseKodu,
    required this.nihaiRiskSkoru,
    required this.potansiyelGetiriYuzde,
  });
}
