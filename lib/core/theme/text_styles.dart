// core/theme/text_styles.dart
import 'package:flutter/material.dart';

/// Uygulamanın tipografi ölçeği — tek kaynaktan yönetilir.
///
/// Ekranlardaki satır içi `TextStyle(...)` tanımları yerine kademeli olarak
/// bu semantik stiller benimsenir. (Eklemeli; mevcut ekran görünümünü tek
/// başına değiştirmez — MaterialApp.textTheme'i ezmez.)
///
/// Renk vermeyiz; renk tema/AppColors üzerinden `.copyWith(color: ...)` ile
/// verilir, böylece aynı ölçek hem açık hem koyu temada çalışır.
class AppTextStyles {
  AppTextStyles._();

  /// Ekran / bölüm başlığı.
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  /// Kart başlığı.
  static const TextStyle cardTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Birincil sayısal değer (fiyat / yüzde). Tabular figürlerle hizalı.
  static const TextStyle numeric = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// İkincil etiket / üst-başlık metni.
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  /// Küçük açıklama / caption.
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
  );
}
