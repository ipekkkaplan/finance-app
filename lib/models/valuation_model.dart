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

  ValuationModel copyWith({
    String? hisseKodu,
    String? sektor,
    double? hisseSkor,
    double? sektorSkor,
    double? finalSkor,
    String? etiket,
  }) =>
      ValuationModel(
        hisseKodu: hisseKodu ?? this.hisseKodu,
        sektor: sektor ?? this.sektor,
        hisseSkor: hisseSkor ?? this.hisseSkor,
        sektorSkor: sektorSkor ?? this.sektorSkor,
        finalSkor: finalSkor ?? this.finalSkor,
        etiket: etiket ?? this.etiket,
      );

  /// fromJson ile aynı anahtarları üretir (round-trip).
  Map<String, dynamic> toJson() => {
        'HisseKodu': hisseKodu,
        'Sektor': sektor,
        'Hisse_Skor': hisseSkor,
        'Sektor_Skor': sektorSkor,
        'Final_Skor': finalSkor,
        'Etiket': etiket,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValuationModel &&
          other.hisseKodu == hisseKodu &&
          other.sektor == sektor &&
          other.hisseSkor == hisseSkor &&
          other.sektorSkor == sektorSkor &&
          other.finalSkor == finalSkor &&
          other.etiket == etiket;

  @override
  int get hashCode =>
      Object.hash(hisseKodu, sektor, hisseSkor, sektorSkor, finalSkor, etiket);
}