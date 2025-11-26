import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = true; // varsayılan tema

  ThemeProvider() {
    loadTheme(); // app açılırken kayıtlı temayı yükler
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    saveTheme(); // kaydet
    notifyListeners(); // tüm app'i yenile
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool("darkMode") ?? true;
    notifyListeners();
  }

  Future<void> saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("darkMode", isDarkMode);
  }
}
