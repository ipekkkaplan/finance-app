import 'package:flutter/material.dart';

class AppColors {
  static const darkProfitGreen = Color(0xFF46D878);
  static const darkLossRed = Color(0xFFFF6B6B);

  static const lightProfitGreen = Color(0xFF0A8F4A);
  static const lightLossRed = Color(0xFFD62828);
}

class ThemeAwareColors {
  static Color profit(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkProfitGreen : AppColors.lightProfitGreen;
  }

  static Color loss(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppColors.darkLossRed : AppColors.lightLossRed;
  }
}
