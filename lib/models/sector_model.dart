class SectorModel {
  final String name;
  final double dailyChange;
  final double weeklyChange;
  final double monthlyChange;
  final double sixMonthChange;

  SectorModel({
    required this.name,
    required this.dailyChange,
    required this.weeklyChange,
    required this.monthlyChange,
    required this.sixMonthChange,
  });

  // JSON'dan nesne üretme için kullandım
  factory SectorModel.fromJson(Map<String, dynamic> json) {
    // Sayısal değerleri güvenli bir şekilde double'a çevirme
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
    );
  }
}