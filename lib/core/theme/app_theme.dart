import 'package:flutter/material.dart';

class AppColors {
  static const darkProfitGreen = Color(0xFF2ECC71);
  static const darkLossRed = Color(0xFFE74C3C);

  static const lightProfitGreen = Color(0xFF0B7A42);
  static const lightLossRed = Color(0xFFC62828);
}

class ThemeAwareColors {
  static Color profit(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkProfitGreen
        : AppColors.lightProfitGreen;
  }

  static Color loss(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkLossRed
        : AppColors.lightLossRed;
  }
}

class AppTheme {
  // DARK THEME
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0A0F24),
    cardColor: const Color(0xFF1E2639),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3D8BFF),
      secondary: Color(0xFF72A8FF),
    ),
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0F24),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
  );

  static final lightTheme = ThemeData(
    brightness: Brightness.light,

    scaffoldBackgroundColor: const Color(0xFFF2F2F7),

    cardColor: const Color(0xFFFFFFFF),

    // Yazı rengi
    textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black87)),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF0F0F5),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black87),
      titleTextStyle: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),

    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1A2E55),
      secondary: Color(0xFF425C8A),
    ),
  );
}
