import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // SystemUiOverlayStyle için gerekli

/// Bu widget ile sarmalanan her ekran, telefonun veya uygulamanın
/// genel teması ne olursa olsun (Dark Mode olsa bile)
/// zorla AYDINLIK MOD (Light Mode) olarak görünür.
///
/// Ayrıca AppBar rengini kurumsal lacivert (0xFF0D47A1) olarak sabitler.
class ForceLightMode extends StatelessWidget {
  final Widget child;

  const ForceLightMode({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Mevcut aydınlık temayı alıp özelleştiriyoruz
    final lightTheme = ThemeData.light().copyWith(
      primaryColor: const Color(0xFF0D47A1), // Senin ana mavimsi rengin
      scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Senin açık gri arka planın

      // Renk şeması
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0D47A1),
        brightness: Brightness.light,
      ),

      // Input alanları (TextField) için varsayılan stil
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),

      // --- TÜM SAYFALAR İÇİN APPBAR AYARI ---
      appBarTheme: const AppBarTheme(
        // Arka planı senin istediğin Koyu Mavi yaptık
        backgroundColor: Color(0xFF0D47A1),
        // Üzerindeki yazıları ve geri butonunu BEYAZ yaptık
        foregroundColor: Colors.white,
        elevation: 0,

        // Material 3'te rengin bozulmaması (beyazlaşmaması) için bu ikisi önemli:
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,

        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),

        // Status Bar ikonlarını beyaz yapar (Koyu zemin olduğu için)
        systemOverlayStyle: SystemUiOverlayStyle.light,

        titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),
      ),
    );

    return Theme(
      data: lightTheme,
      child: child,
    );
  }
}