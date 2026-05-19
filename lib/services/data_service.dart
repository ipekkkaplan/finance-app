import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// Modeller
import '../models/sector_model.dart';
import '../models/valuation_model.dart';
import '../models/stock_model.dart';
import '../models/sector_trend_model.dart'; // Yeni eklenen model importu

class DataService {
  // In-memory cache'ler. JSON dosyaları büyük olduğu için her ekran
  // açılışında yeniden yüklemek yerine ilk çağrıda yüklenip saklanır.
  static List<SectorModel>? _sectorCache;
  static List<ValuationModel>? _valuationCache;
  static List<SectorTrendModel>? _trendsCache;
  static List<StockModel>? _stocksCache;

  /// Test veya kullanıcı çıkışı sonrası cache'i sıfırlamak için.
  static void clearCache() {
    _sectorCache = null;
    _valuationCache = null;
    _trendsCache = null;
    _stocksCache = null;
  }

  // --- 1. MEVCUT SEKTÖR VERİLERİ ---
  Future<List<SectorModel>> loadSectorData() async {
    if (_sectorCache != null) return _sectorCache!;
    try {
      final String sectorString = await rootBundle.loadString('assets/sektor_analiz.json');
      final List<dynamic> sectorJsonList = json.decode(sectorString);

      final String companyString = await rootBundle.loadString('assets/sector_top3_6m.json');
      final List<dynamic> companyJsonList = json.decode(companyString);

      _sectorCache = sectorJsonList.map((sJson) {
        String sectorName = sJson['Sektor'] ?? '';
        List<Map<String, dynamic>> matchingCompanies = companyJsonList
            .where((c) => c['sector'] == sectorName)
            .map((c) => c as Map<String, dynamic>)
            .toList();
        return SectorModel.fromJson(sJson, matchingCompanies);
      }).toList();

      return _sectorCache!;
    } catch (e) {
      debugPrint("DataService (Sector) HATA: $e");
      return [];
    }
  }

  // --- 2. DEĞERLEME VERİLERİ ---
  Future<List<ValuationModel>> loadValuationData() async {
    if (_valuationCache != null) return _valuationCache!;
    try {
      final String jsonString = await rootBundle.loadString('assets/hisse_degerleme_sonuclari.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _valuationCache = jsonList.map((jsonItem) => ValuationModel.fromJson(jsonItem)).toList();
      return _valuationCache!;
    } catch (e) {
      debugPrint("DataService (Valuation) HATA: $e");
      return [];
    }
  }

  // --- 3. SEKTÖR TREND VERİLERİ ---
  Future<List<SectorTrendModel>> getSectorTrends() async {
    if (_trendsCache != null) return _trendsCache!;
    try {
      // Dosya isminin doğru olduğundan emin ol (pubspec.yaml'da tanımlı olmalı)
      final String jsonString = await rootBundle.loadString('assets/sector_yearly_returns_2020_2025.json');
      final List<dynamic> rawList = json.decode(jsonString);

      // 1. ADIM: Verileri Sektör adına göre grupla
      // Örn: { "Enerji": [ {2020 verisi}, {2021 verisi}... ], "Teknoloji": [...] }
      Map<String, List<Map<String, dynamic>>> groupedData = {};

      for (var item in rawList) {
        String sector = item['sector'];
        // Eğer map'te bu sektör yoksa listesini oluştur
        if (!groupedData.containsKey(sector)) {
          groupedData[sector] = [];
        }
        // Veriyi listeye ekle
        groupedData[sector]!.add(item as Map<String, dynamic>);
      }

      // 2. ADIM: Gruplanmış veriyi Modele çevir
      List<SectorTrendModel> trends = [];

      groupedData.forEach((sectorName, dataList) {
        // Yılları küçükten büyüğe sıraladık
        dataList.sort((a, b) => a['year'].compareTo(b['year']));

        // Sadece 'annual_return_pct' değerlerini alıp double listesi yap
        List<double> points = dataList
            .map((e) => (e['annual_return_pct'] as num).toDouble())
            .toList();

        trends.add(SectorTrendModel(
          sectorName: sectorName,
          yearlyPoints: points,
        ));
      });

      _trendsCache = trends;
      return trends;

    } catch (e) {
      debugPrint("DataService (Trend Parse) HATA: $e");
      return [];
    }
  }

  // --- 4. SEKTÖRE GÖRE HİSSE LİSTESİ ---
  Future<List<StockModel>> getStocksBySector(String sectorName) async {
    // Tüm hisseleri bir kez yükle, sonraki çağrılarda cache'den filtrele.
    if (_stocksCache == null) {
      String jsonString = "";
      try {
        jsonString = await rootBundle.loadString('assets/json/hisse_ayrinti.json');
      } catch (e) {
        try {
          jsonString = await rootBundle.loadString('assets/hisse_ayrinti.json');
        } catch (e2) {
          debugPrint("KRİTİK HATA: JSON dosyası okunamadı! Pubspec.yaml'ı kontrol et.");
          return [];
        }
      }

      try {
        final List<dynamic> data = json.decode(jsonString);
        _stocksCache = data.map((json) => StockModel.fromJson(json)).toList();
      } catch (e) {
        debugPrint("JSON Ayrıştırma Hatası: $e");
        return [];
      }
    }

    // Türkçe karakter sorunu yaşamamak için özel karşılaştırma
    final results = _stocksCache!
        .where((stock) => _normalize(stock.sektor) == _normalize(sectorName))
        .toList();
    debugPrint("$sectorName için ${results.length} şirket bulundu.");
    return results;
  }

  // Türkçe karakterleri İngilizceye çeviren yardımcı fonksiyon
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