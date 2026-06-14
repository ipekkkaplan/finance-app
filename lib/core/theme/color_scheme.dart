// core/theme/color_scheme.dart
import 'package:flutter/material.dart';

/// Uygulamadaki tüm renk sabitleri tek bir yerden yönetilir.
///
/// Kullanım: `AppColors.accentTeal`, `AppColors.profitColor(isDark)` vb.
class AppColors {
  AppColors._(); // instantiate edilmesini engelle

  // ── PRIMARY ──────────────────────────────────────────────
  /// Light mode primary.
  static const Color primaryLight = Color(0xFF102C57);

  /// Dark mode primary – teal/cyan (referans görsele göre güncellendi).
  static const Color primaryDark = Color(0xFF00C9A7);

  /// Tema-uyumlu primary. build() içindeki `isDark` ile çağırılır.
  static Color primary(bool isDark) => isDark ? primaryDark : primaryLight;

  // ── ACCENT TEAL (dark mode vurgusu) ──────────────────────
  static const Color accentTeal = Color(0xFF00C9A7);

  /// Geriye dönük uyumluluk için alias.
  static const Color accentBlue = Color(0xFF00C9A7);

  // ── ALTIN / KOİN ─────────────────────────────────────────
  static const Color gold = Color(0xFFF5C518);

  // ── KÂR / ZARAR ─────────────────────────────────────────
  static const Color profit = Color(0xFF00D27B);
  static const Color loss = Color(0xFFFF5252);
  static const Color neutral = Color(0xFF00C9A7);

  static const Color profitLight = Color(0xFF00C853);
  static const Color profitDark = Color(0xFF00E676);
  static const Color lossLight = Color(0xFFFF5252);
  static const Color lossDark = Color(0xFFEF5350);

  static Color profitColor(bool isDark) => isDark ? profitDark : profitLight;
  static Color lossColor(bool isDark) => isDark ? lossDark : lossLight;

  /// getProfitColor eski uyumluluk.
  static Color getProfitColor(bool isDark) => profitColor(isDark);

  // ── DARK MODE YÜZEYLER ──────────────────────────────────
  /// Ana arka plan (en koyu katman).
  static const Color darkBackground = Color(0xFF0A1528);

  /// Kart arka planı.
  static const Color darkCard = Color(0xFF132040);

  /// İç kart / input arka planı.
  static const Color darkCardInner = Color(0xFF0C1A30);

  /// Input alanı arka planı (dark mode).
  static const Color darkInputBg = Color(0xFF0A1220);

  // ── DARK MODE EKRAN GRADYANI ────────────────────────────
  /// Ekran arka plan gradyanının üç durağı. Daha önce her ekranda
  /// `_kBgTop/_kBgMid/_kBgBot` olarak kopyalanmıştı; tek kaynak burası.
  static const Color bgGradientTop = Color(0xFF07111F);
  static const Color bgGradientMid = Color(0xFF0C1B31);
  static const Color bgGradientBot = Color(0xFF0F2040);

  /// Koyu tema ekran arka planı (üstten alta).
  static const List<Color> backgroundGradientDark = [
    bgGradientTop,
    bgGradientMid,
    bgGradientBot,
  ];

  /// Açık tema düz ekran arka planı.
  static const Color lightScaffold = Color(0xFFF5F5F5);

  /// Koyu tema alt navigasyon barı.
  static const Color darkNavBar = Color(0xFF0E1E35);

  // ── CAM (GLASS) EFEKTİ OVERLAY'LERİ ─────────────────────
  /// Kart üstü çok hafif beyaz dolgu (%5).
  static const Color glassFill = Color(0x0DFFFFFF);

  /// İç kart dolgusu (%3).
  static const Color glassFillInner = Color(0x08FFFFFF);

  /// Cam kart ince border (%9 beyaz).
  static const Color glassBorder = Color(0x18FFFFFF);

  /// Teal vurgunun koyu tonu (gradyan/aktif durum).
  static const Color tealDark = Color(0xFF00A88A);

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

  static Color sectorColor(String sector) => sectorColors[sector] ?? accentTeal;

  // ── PIE CHART PALETİ ────────────────────────────────────
  static const List<Color> chartPalette = [
    accentTeal,
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
