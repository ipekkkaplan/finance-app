import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Modeller
import '../models/sector_model.dart';
import '../models/valuation_model.dart';

class DataService {

  // --- MEVCUT SEKTÖR VERİLERİ  ---
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
        return SectorModel.fromJson(sJson, matchingCompanies);
      }).toList();

    } catch (e) {
      debugPrint("DataService (Sector) HATA: $e");
      return [];
    }
  }

  // Değerleme verileri(En yeni Eklenen)
  Future<List<ValuationModel>> loadValuationData() async {
    try {

      final String jsonString = await rootBundle.loadString('assets/hisse_degerleme_sonuclari.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      // JSON listesini ValuationModel listesine çevir
      return jsonList.map((jsonItem) => ValuationModel.fromJson(jsonItem)).toList();
    } catch (e) {
      debugPrint("DataService (Valuation) HATA: $e");
      return [];
    }
  }
}