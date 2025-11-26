import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PortfolioItem {
  final String companyName;
  final String ticker;
  final String sector;

  const PortfolioItem({
    required this.companyName,
    required this.ticker,
    required this.sector,
  });

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'ticker': ticker,
    'sector': sector,
  };

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      companyName: json['companyName'],
      ticker: json['ticker'],
      sector: json['sector'],
    );
  }
}

class PortfolioProvider extends ChangeNotifier {
  final Map<String, PortfolioItem> _items = {};

  PortfolioProvider() {
    debugPrint("⚪ PortfolioProvider constructor çalıştı");
    Future.microtask(() async {
      debugPrint("⚪ microtask → _loadFromPrefs çağırılıyor");
      await _loadFromPrefs();
    });
  }

  List<PortfolioItem> get items => _items.values.toList();
  bool isInPortfolio(String ticker) => _items.containsKey(ticker);

  // ---- price change (UI ÇÖKMEMESİ İÇİN DUMMY) ----
  String changeForTicker(String ticker) {
    return "+0.0%";
  }

  Future<void> toggle(PortfolioItem item) async {
    debugPrint("🟡 toggle çağırıldı → ${item.ticker}");

    if (_items.containsKey(item.ticker)) {
      debugPrint("🔴 portföyden kaldırılıyor");
      _items.remove(item.ticker);
    } else {
      debugPrint("🟢 portföye ekleniyor");
      _items[item.ticker] = item;
    }

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _items.map((key, value) => MapEntry(key, value.toJson())),
    );

    debugPrint("💾 Kaydediliyor: $encoded");

    await prefs.setString("portfolio", encoded);

    debugPrint("💾 Kaydedildi.");
  }

  Future<void> _loadFromPrefs() async {
    debugPrint("📂 _loadFromPrefs başladı");

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("portfolio");

    debugPrint("📂 Prefs içeriği: $saved");

    if (saved == null) {
      debugPrint("⚠ pref içinde veri YOK");
      return;
    }

    final decoded = jsonDecode(saved) as Map<String, dynamic>;
    debugPrint("📂 decode: $decoded");

    decoded.forEach((key, value) {
      _items[key] = PortfolioItem.fromJson(value);
    });

    debugPrint("🟢 yükleme bitti → item sayısı: ${_items.length}");

    notifyListeners();
  }
}
