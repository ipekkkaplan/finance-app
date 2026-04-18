/// Hisse alım önerisi kategorileri.
enum RecommendationCategory {
  all,         // Tümü
  value,       // Değer Odaklı (Ucuz)
  highYield,   // Yüksek Temettü
  lowRisk,     // Düşük Risk
}

extension RecommendationCategoryX on RecommendationCategory {
  String get label {
    switch (this) {
      case RecommendationCategory.all:
        return 'Tümü';
      case RecommendationCategory.value:
        return 'Değer Odaklı';
      case RecommendationCategory.highYield:
        return 'Yüksek Temettü';
      case RecommendationCategory.lowRisk:
        return 'Düşük Risk';
    }
  }
}

/// Bir hisse için üretilmiş yatırım önerisi.
class RecommendationModel {
  final String hisseKodu;
  final String sirketIsmi;
  final String sektor;
  final double totalScore;   // 0.0 - 1.0
  final double? potentialReturn; // % potansiyel getiri (varsa)
  final List<String> reasons;    // Neden önerildiği (kısa maddeler)

  const RecommendationModel({
    required this.hisseKodu,
    required this.sirketIsmi,
    required this.sektor,
    required this.totalScore,
    this.potentialReturn,
    required this.reasons,
  });

  /// 0-100 arası görsel skor.
  int get scorePercent => (totalScore * 100).round().clamp(0, 100);
}
