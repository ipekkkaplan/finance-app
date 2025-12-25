// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // --- FİNANSAL RENKLER ---


  static const Color profit = Color(0xFF00D27B);

  // Ana Düşüş Rengi (Modern Mercan Kırmızısı)
  // Cırtlak kırmızı yerine biraz daha yumuşak ama net bir kırmızı.
  static const Color loss = Color(0xFFFF5252);

  // Nötr/Durağan Durum
  static const Color neutral = Color(0xFF3D8BFF);

  // --- ARKA PLAN VARYASYONLARI (Opaklık Yerine) ---

  // Etiketlerin arkasına koyacağın hafif yeşil (Dark Mode uyumlu düşünürsek)
  // .withValues(alpha: 0.1) yapmak yerine sabit renk atamak performansı artırır
  // ama şimdilik dinamik kullanım için ana rengi kullanacağız.

  // --- YARDIMCI METODLAR ---

  // Dark Mode'da yeşil bazen çok parlar, bu metodla kontrol edebilirsin.
  static Color getProfitColor(bool isDark) {
    return isDark ? const Color(0xFF00E676) : const Color(0xFF00C853);
    // Veya tek renk kullanmak istiyorsan direkt:
    // return profit;
  }
}