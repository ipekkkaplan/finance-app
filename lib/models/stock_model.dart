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

  // JSON'dan Model üretme fabrikası
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      sirketIsmi: json['SirketIsmi'] ?? '',
      sektor: json['Sektor'] ?? '',
      hisseKodu: json['HisseKodu'] ?? '',
      // JSON'dan sayıları güvenli çekmek için ufak kontroller:
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
}