import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- 1. IMPORT EKLENDİ

// Model (Aynen kaldı)
class FavoriteItem {
  final String symbol;
  final double changeRate;

  FavoriteItem({required this.symbol, required this.changeRate});

  Map<String, dynamic> toJson() => {
    'symbol': symbol,
    'changeRate': changeRate,
  };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      symbol: json['symbol'],
      changeRate: (json['changeRate'] as num).toDouble(),
    );
  }
}

class FavoritesService {
  static final FavoritesService instance = FavoritesService._init();

  // Singleton başlatıldığında değil, her çağrıldığında çalışır
  FavoritesService._init() {
    loadFavorites();
  }

  final List<FavoriteItem> _favorites = [];
  final ValueNotifier<List<FavoriteItem>> favoritesNotifier = ValueNotifier([]);

  // --- YARDIMCI: KULLANICIYA ÖZEL ANAHTAR OLUŞTURMA ---
  String _getStorageKey() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Kullanıcı giriş yapmışsa: "saved_favorites_KULLANICIID"
      return 'saved_favorites_${user.uid}';
    } else {
      // Misafir modundaysa genel bir anahtar
      return 'saved_favorites_guest';
    }
  }

  // --- 1. KAYITLARI YÜKLEME ---
  // (Metodu public yaptım ki Home Screen'den çağırabilelim: _load -> load)
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    // O anki kullanıcıya ait anahtarı al
    final String key = _getStorageKey();

    final String? data = prefs.getString(key);

    // Listeyi temizle (Önceki kullanıcının verisi kalmasın)
    _favorites.clear();

    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      _favorites.addAll(jsonList.map((e) => FavoriteItem.fromJson(e)).toList());
    }

    // Arayüzü güncelle
    favoritesNotifier.value = List.from(_favorites);
  }

  // --- 2. EKLEME / ÇIKARMA VE KAYDETME ---
  Future<void> toggleFavorite(String symbol, double changeRate) async {
    final index = _favorites.indexWhere((item) => item.symbol == symbol);

    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(FavoriteItem(symbol: symbol, changeRate: changeRate));
    }

    favoritesNotifier.value = List.from(_favorites);

    // TELEFONA KAYDET
    final prefs = await SharedPreferences.getInstance();

    // Yine o anki kullanıcıya ait anahtarı alıp oraya kaydediyoruz
    final String key = _getStorageKey();

    final String encodedData = jsonEncode(_favorites.map((e) => e.toJson()).toList());
    await prefs.setString(key, encodedData);
  }

  bool isFavorite(String symbol) {
    return _favorites.any((item) => item.symbol == symbol);
  }
}