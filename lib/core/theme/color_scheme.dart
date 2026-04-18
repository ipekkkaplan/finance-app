import 'package:flutter/material.dart';

/// Uygulamadaki tüm renk sabitleri tek bir yerden yönetilir.
///
/// Kullanım: `AppColors.accentBlue`, `AppColors.profitColor(isDark)` vb.
class AppColors {
  AppColors._(); // instantiate edilmesini engelle

  // ── PRIMARY ──────────────────────────────────────────────
  /// Light mode primary (main.dart ThemeData ile eşleşir).
  static const Color primaryLight = Color(0xFF102C57);

  /// Dark mode primary.
  static const Color primaryDark = Color(0xFF3D8BFF);

  /// Tema-uyumlu primary. build() içindeki `isDark` ile çağırılır.
  static Color primary(bool isDark) => isDark ? primaryDark : primaryLight;

  // ── ACCENT MAVİ ──────────────────────────────────────────
  /// Her modda aynı mavi ton (butonlar, vurgu, filtre chip'leri).
  static const Color accentBlue = Color(0xFF3D8BFF);

  // ── KÂR / ZARAR ─────────────────────────────────────────
  static const Color profit = Color(0xFF00D27B);
  static const Color loss = Color(0xFFFF5252);
  static const Color neutral = Color(0xFF3D8BFF);

  static const Color profitLight = Color(0xFF00C853);
  static const Color profitDark = Color(0xFF00E676);
  static const Color lossLight = Color(0xFFFF5252);
  static const Color lossDark = Color(0xFFEF5350);

  static Color profitColor(bool isDark) => isDark ? profitDark : profitLight;
  static Color lossColor(bool isDark) => isDark ? lossDark : lossLight;

  /// getProfitColor eski uyumluluk (zaten aynı davranış).
  static Color getProfitColor(bool isDark) => profitColor(isDark);

  // ── DARK MODE YÜZEYLER ──────────────────────────────────
  /// İç kart arka planı (tüm ekranlarda tutarlı).
  static const Color darkCardInner = Color(0xFF1A2038);

  /// Input alanı arka planı (dark mode).
  static const Color darkInputBg = Color(0xFF0D1117);

  // ── SEKTÖR RENKLERİ ─────────────────────────────────────
  static const Map<String, Color> sectorColors = {
    'Teknoloji': Color(0xFF9D46FF),
    'Sağlık': Color(0xFF00C853),
    'Gayrimenkul': Color(0xFFFF9100),
    'Enerji': Color(0xFF448AFF),
    'Bankacılık': Color(0xFFEF5350),
    'Sanayi': Color(0xFF00BCD4),
    'Turizm': Color(0xFFFF4081),
    'Kimya': Color(0xFF7C4DFF),
    'Holding': Color(0xFF00897B),
    'Perakende': Color(0xFFFF6D00),
    'Ulaşım': Color(0xFF1E88E5),
    'Tüketim': Color(0xFFFFC107),
    'Gıda': Color(0xFF8D6E63),
    'Otomotiv': Color(0xFF546E7A),
    'Kağıt': Color(0xFFAB47BC),
  };

  static Color sectorColor(String sector) =>
      sectorColors[sector] ?? accentBlue;

  // ── PIE CHART PALETİ ────────────────────────────────────
  static const List<Color> chartPalette = [
    accentBlue,
    profitLight,
    Color(0xFFFFC107),
    Color(0xFF9C27B0),
    Color(0xFFFF9100),
    Color(0xFFEF5350),
    Color(0xFF00897B),
    Color(0xFF1E88E5),
    Color(0xFFFF4081),
    Color(0xFF00BCD4),
  ];
}
