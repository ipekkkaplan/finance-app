class StockModel {
  final String sirketIsmi;
  final String sektor;
  final String hisseKodu;
  final double hacim;
  final double? temettuVerimliligi;
  final double pdDd;
  final double fdFavok;
  final double fdSatislar;
  final double fk;
  final double favok;
  final double roa;
  final double pd;

  StockModel({
    required this.sirketIsmi,
    required this.sektor,
    required this.hisseKodu,
    required this.hacim,
    this.temettuVerimliligi,
    required this.pdDd,
    required this.fdFavok,
    required this.fdSatislar,
    required this.fk,
    required this.favok,
    required this.roa,
    required this.pd,
  });

  // JSON'dan Model üretme
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      sirketIsmi: json['SirketIsmi'] ?? '',
      sektor: json['Sektor'] ?? '',
      hisseKodu: json['HisseKodu'] ?? '',
      // JSON'dan sayıları güvenli çekmek için yaptığımız kontroller:
      hacim: (json['Hacim'] ?? 0).toDouble(),
      temettuVerimliligi: json['Temettü Verimliliği'] != null
          ? (json['Temettü Verimliliği'] as num).toDouble()
          : null,
      pdDd: (json['PD_DD'] ?? 0).toDouble(),
      fdFavok: (json['FD_FAVOK'] ?? 0).toDouble(),
      fdSatislar: (json['FD_Satislar'] ?? 0).toDouble(),
      fk: (json['FK'] ?? 0).toDouble(),
      favok: (json['FAVOK'] ?? 0).toDouble(),
      roa: (json['ROA'] ?? 0).toDouble(),
      pd: (json['PD'] ?? 0).toDouble(),
    );
  }

  StockModel copyWith({
    String? sirketIsmi,
    String? sektor,
    String? hisseKodu,
    double? hacim,
    double? temettuVerimliligi,
    double? pdDd,
    double? fdFavok,
    double? fdSatislar,
    double? fk,
    double? favok,
    double? roa,
    double? pd,
  }) =>
      StockModel(
        sirketIsmi: sirketIsmi ?? this.sirketIsmi,
        sektor: sektor ?? this.sektor,
        hisseKodu: hisseKodu ?? this.hisseKodu,
        hacim: hacim ?? this.hacim,
        temettuVerimliligi: temettuVerimliligi ?? this.temettuVerimliligi,
        pdDd: pdDd ?? this.pdDd,
        fdFavok: fdFavok ?? this.fdFavok,
        fdSatislar: fdSatislar ?? this.fdSatislar,
        fk: fk ?? this.fk,
        favok: favok ?? this.favok,
        roa: roa ?? this.roa,
        pd: pd ?? this.pd,
      );

  /// fromJson ile aynı anahtarları üretir (round-trip).
  Map<String, dynamic> toJson() => {
        'SirketIsmi': sirketIsmi,
        'Sektor': sektor,
        'HisseKodu': hisseKodu,
        'Hacim': hacim,
        'Temettü Verimliliği': temettuVerimliligi,
        'PD_DD': pdDd,
        'FD_FAVOK': fdFavok,
        'FD_Satislar': fdSatislar,
        'FK': fk,
        'FAVOK': favok,
        'ROA': roa,
        'PD': pd,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StockModel &&
          other.sirketIsmi == sirketIsmi &&
          other.sektor == sektor &&
          other.hisseKodu == hisseKodu &&
          other.hacim == hacim &&
          other.temettuVerimliligi == temettuVerimliligi &&
          other.pdDd == pdDd &&
          other.fdFavok == fdFavok &&
          other.fdSatislar == fdSatislar &&
          other.fk == fk &&
          other.favok == favok &&
          other.roa == roa &&
          other.pd == pd;

  @override
  int get hashCode => Object.hashAll([
        sirketIsmi,
        sektor,
        hisseKodu,
        hacim,
        temettuVerimliligi,
        pdDd,
        fdFavok,
        fdSatislar,
        fk,
        favok,
        roa,
        pd,
      ]);
}