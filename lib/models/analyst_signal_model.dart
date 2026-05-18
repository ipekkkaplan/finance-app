import 'signal_model.dart';

/// Finscope veri setinden gelen analist yorumu + sinyali.
///
/// `assets/finscope_veri_seti.json` içindeki bir kaydı temsil eder.
/// Her hisse için: orijinal uzun yorum, AL/SAT/TUT sinyali ve gerekçe.
class AnalystSignalModel {
  final String hisseKodu;
  final String orijinalMetin; // Analistin uzun yorumu
  final String rawSinyal;     // "AL" / "SAT" / "TUT"
  final String gerekce;       // Sinyal için kısa gerekçe

  const AnalystSignalModel({
    required this.hisseKodu,
    required this.orijinalMetin,
    required this.rawSinyal,
    required this.gerekce,
  });

  factory AnalystSignalModel.fromJson(Map<String, dynamic> json) {
    return AnalystSignalModel(
      hisseKodu: (json['hisse_kodu'] ?? '').toString().trim().toUpperCase(),
      orijinalMetin: (json['orijinal_metin'] ?? '').toString().trim(),
      rawSinyal: (json['sinyal'] ?? '').toString().trim().toUpperCase(),
      gerekce: (json['gerekce'] ?? '').toString().trim(),
    );
  }

  /// AL/SAT/TUT'u uygulamanın SignalType enum'una çevirir.
  ///
  /// AL içinden "güçlü", "muazzam", "çok güçlü", "tavan" gibi vurgular
  /// içerenler `strongBuy`, diğerleri `buy` olarak işaretlenir.
  SignalType get signalType {
    switch (rawSinyal) {
      case 'AL':
        final combined = '$gerekce $orijinalMetin'.toLowerCase();
        const strongMarkers = [
          'güçlü al',
          'çok güçlü',
          'muazzam',
          'tavan',
          'tavan yap',
          'devasa',
        ];
        for (final m in strongMarkers) {
          if (combined.contains(m)) return SignalType.strongBuy;
        }
        return SignalType.buy;
      case 'SAT':
        return SignalType.sell;
      case 'TUT':
      default:
        return SignalType.hold;
    }
  }
}
