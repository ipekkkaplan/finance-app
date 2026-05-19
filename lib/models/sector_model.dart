class SectorModel {
  final String name;
  final double dailyChange;
  final double weeklyChange;
  final double monthlyChange;
  final double sixMonthChange;

  /// Sektördeki en iyi 3 hisseyi tutar.
  final List<Map<String, dynamic>> topCompanies;

  SectorModel({
    required this.name,
    required this.dailyChange,
    required this.weeklyChange,
    required this.monthlyChange,
    required this.sixMonthChange,
    required this.topCompanies,
  });

  /// JSON nesnesinden ve eşleşen şirket listesinden bir SectorModel üretir.
  factory SectorModel.fromJson(Map<String, dynamic> json, List<Map<String, dynamic>> companies) {

    // Sayısal değerleri güvenli şekilde double'a çevirir.
    double toDouble(dynamic val) {
      if (val is double) return val;
      if (val is int) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return SectorModel(
      name: json['Sektor'] ?? 'Bilinmiyor',
      dailyChange: toDouble(json['1 Gunluk Degisim (%)']),
      weeklyChange: toDouble(json['1 Haftalik Degisim (%)']),
      monthlyChange: toDouble(json['1 Aylik Degisim (%)']),
      sixMonthChange: toDouble(json['6 Aylik Degisim (%)']),
      topCompanies: companies,
    );
  }
}