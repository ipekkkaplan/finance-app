// lib/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color profit = Color(0xFF00D27B);

  // Ana Düşüş Rengi
  static const Color loss = Color(0xFFFF5252);

  // Nötr/Durağan Durum
  static const Color neutral = Color(0xFF3D8BFF);

  // --- ARKA PLAN VARYASYONLARI ---


  // --- YARDIMCI METODLAR ---
  static Color getProfitColor(bool isDark) {
    return isDark ? const Color(0xFF00E676) : const Color(0xFF00C853);

  }
}