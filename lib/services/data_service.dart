import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/sector_model.dart';

class DataService {
  Future<List<SectorModel>> loadSectorData() async {
    try {
      // 1. Ana Sektör Verilerini Oku (sektor_analiz.json)
      final String sectorString = await rootBundle.loadString('assets/sektor_analiz.json');
      final List<dynamic> sectorJsonList = json.decode(sectorString);

      // 2. Top 3 Şirket Verilerini Oku (sector_top3_6m.json)
      final String companyString = await rootBundle.loadString('assets/sector_top3_6m.json');
      final List<dynamic> companyJsonList = json.decode(companyString);

      // 3. Verileri Birleştir
      return sectorJsonList.map((sJson) {
        // Ana dosyadaki sektör adını al ('Sektor' key'i ile)
        String sectorName = sJson['Sektor'] ?? '';

        // Diğer listeden bu sektöre ait olan şirketleri bul
        List<Map<String, dynamic>> matchingCompanies = companyJsonList
            .where((c) => c['sector'] == sectorName)
            .map((c) => c as Map<String, dynamic>)
            .toList();

        // Modeli oluştururken eşleşen şirketleri de gönderiyoruz
        // NOT: SectorModel.fromJson metodunu 2 parametre alacak şekilde güncellemiştik.
        return SectorModel.fromJson(sJson, matchingCompanies);
      }).toList();

    } catch (e) {
      debugPrint("DataService HATA: $e");
      return [];
    }
  }
}