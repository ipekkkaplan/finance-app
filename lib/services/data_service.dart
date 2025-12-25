import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Modeller
import '../models/sector_model.dart';
import '../models/valuation_model.dart';
import '../models/stock_model.dart'; // <--- 1. YENİ MODELİ IMPORT ETTİK

class DataService {

  // --- 1. MEVCUT SEKTÖR VERİLERİ ---
  Future<List<SectorModel>> loadSectorData() async {
    try {
      final String sectorString = await rootBundle.loadString('assets/sektor_analiz.json');
      final List<dynamic> sectorJsonList = json.decode(sectorString);

      final String companyString = await rootBundle.loadString('assets/sector_top3_6m.json');
      final List<dynamic> companyJsonList = json.decode(companyString);

      return sectorJsonList.map((sJson) {
        String sectorName = sJson['Sektor'] ?? '';
        List<Map<String, dynamic>> matchingCompanies = companyJsonList
            .where((c) => c['sector'] == sectorName)
            .map((c) => c as Map<String, dynamic>)
            .toList();
        return SectorModel.fromJson(sJson, matchingCompanies);
      }).toList();

    } catch (e) {
      debugPrint("DataService (Sector) HATA: $e");
      return [];
    }
  }

  // --- 2. DEĞERLEME VERİLERİ ---
  Future<List<ValuationModel>> loadValuationData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/hisse_degerleme_sonuclari.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((jsonItem) => ValuationModel.fromJson(jsonItem)).toList();
    } catch (e) {
      debugPrint("DataService (Valuation) HATA: $e");
      return [];
    }
  }

  // --- GÜÇLENDİRİLMİŞ VERİ ÇEKME FONKSİYONU ---
  Future<List<StockModel>> getStocksBySector(String sectorName) async {
    String jsonString = "";

    try {
      // 1. Önce 'assets/json/' klasörünü dene
      jsonString = await rootBundle.loadString('assets/json/hisse_ayrinti.json');
      debugPrint("Dosya 'assets/json/' klasöründen okundu.");
    } catch (e) {
      debugPrint("assets/json/ içinde bulunamadı. Alternatif yol deneniyor...");
      try {
        // 2. Bulamazsa direkt 'assets/' klasörünü dene
        jsonString = await rootBundle.loadString('assets/hisse_ayrinti.json');
        debugPrint("Dosya 'assets/' klasöründen okundu.");
      } catch (e2) {
        debugPrint("KRİTİK HATA: JSON dosyası okunamadı! Pubspec.yaml'ı kontrol et.");
        debugPrint("Hata 1: $e");
        debugPrint("Hata 2: $e2");
        return []; // Dosya yoksa boş dön
      }
    }

    try {
      final List<dynamic> data = json.decode(jsonString);

      // Türkçe karakter sorunu yaşamamak için özel karşılaştırma
      final results = data.map((json) => StockModel.fromJson(json)).where((stock) {
        return _normalize(stock.sektor) == _normalize(sectorName);
      }).toList();

      debugPrint("$sectorName için ${results.length} şirket bulundu.");
      return results;
    } catch (e) {
      debugPrint("JSON Ayrıştırma Hatası: $e");
      return [];
    }
  }

  // Türkçe karakterleri İngilizceye çeviren yardımcı fonksiyon
  // (Örn: "Sağlık" -> "saglik", "ENERJİ" -> "enerji")
  String _normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }
}