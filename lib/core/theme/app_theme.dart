// core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_scheme.dart';

/// Uygulamanın açık ve koyu temaları tek yerden yönetilir.
///
/// Önceden `main.dart` içinde satır içi `ThemeData(...)` olarak tanımlıydı.
/// Tüm renkler artık [AppColors] token'larına bağlı; sihirli hex değeri
/// kalmadı. Değerler taşınırken birebir korundu (görsel değişiklik yok).
class AppTheme {
  AppTheme._();

  // ── AÇIK TEMA ─────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightScaffold,
        primaryColor: AppColors.primaryLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryLight,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: IconThemeData(color: Colors.white, size: 24),
          actionsIconTheme: IconThemeData(color: Colors.white, size: 24),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.primaryLight),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      );

  // ── KOYU TEMA (referans görsel: koyu lacivert + teal) ─────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        cardColor: AppColors.darkCard,
        primaryColor: AppColors.primaryDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryDark,
          brightness: Brightness.dark,
          surface: AppColors.darkCard,
          primary: AppColors.primaryDark,
          secondary: AppColors.gold, // altın/koin rengi
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          shape: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkNavBar,
          selectedItemColor: AppColors.primaryDark,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white60),
        ),
      );
}
