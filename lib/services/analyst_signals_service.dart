import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/analyst_signal_model.dart';

/// `assets/finscope_veri_seti.json` dosyasından analist yorumlarını yükler.
///
/// Bu, hisse başına gerçek (analist tarafından yazılmış) sinyal + uzun
/// yorum + gerekçe sağlar. Diğer servisler bu veriyi birincil kaynak
/// olarak kullanır; veri yoksa kural-bazlı motorlara düşer.
class AnalystSignalsService {
  AnalystSignalsService._();
  static final AnalystSignalsService instance = AnalystSignalsService._();

  Map<String, AnalystSignalModel>? _cache;

  /// Tüm analist sinyallerini hisse koduna göre map olarak döndürür.
  Future<Map<String, AnalystSignalModel>> loadAll() async {
    if (_cache != null) return _cache!;

    try {
      final raw = await rootBundle.loadString('assets/finscope_veri_seti.json');
      final List<dynamic> data = json.decode(raw);
      final map = <String, AnalystSignalModel>{};
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        final model = AnalystSignalModel.fromJson(item);
        if (model.hisseKodu.isEmpty) continue;
        map[model.hisseKodu] = model;
      }
      _cache = map;
      return map;
    } catch (e) {
      debugPrint('AnalystSignalsService: finscope_veri_seti.json okunamadı: $e');
      _cache = {};
      return _cache!;
    }
  }

  /// Tek bir hisse için analist yorumunu döndürür (yoksa null).
  Future<AnalystSignalModel?> getFor(String hisseKodu) async {
    final all = await loadAll();
    return all[hisseKodu.toUpperCase()];
  }
}
