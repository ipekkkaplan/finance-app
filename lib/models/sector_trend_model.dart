class SectorTrendModel {
  final String sectorName;
  final List<double> yearlyPoints; // [2020 verisi, 2021 verisi, ... sıralı]

  SectorTrendModel({
    required this.sectorName,
    required this.yearlyPoints,
  });
}