class ValuationModel {
  final String hisseKodu;
  final String sektor;
  final double hisseSkor;
  final double sektorSkor;
  final double finalSkor;
  final String etiket;

  ValuationModel({
    required this.hisseKodu,
    required this.sektor,
    required this.hisseSkor,
    required this.sektorSkor,
    required this.finalSkor,
    required this.etiket,
  });

  factory ValuationModel.fromJson(Map<String, dynamic> json) {
    return ValuationModel(
      hisseKodu: json['HisseKodu'] ?? '',
      sektor: json['Sektor'] ?? '',
      hisseSkor: (json['Hisse_Skor'] ?? 0.0).toDouble(),
      sektorSkor: (json['Sektor_Skor'] ?? 0.0).toDouble(),
      finalSkor: (json['Final_Skor'] ?? 0.0).toDouble(),
      etiket: json['Etiket'] ?? 'Bilinmiyor',
    );
  }
}