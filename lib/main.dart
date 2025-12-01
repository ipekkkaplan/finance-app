import 'package:finance_app/screens/auth_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Status Bar kontrolü için eklendi
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:finance_app/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase hatası: $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'FinScope AI',
      debugShowCheckedModeBanner: false,

      // ----------- AÇIK TEMA (Light Mode) -----------
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Sayfa arka planı açık gri

        // Ana renk: Derin, "Fintech" laciverti
        primaryColor: const Color(0xFF102C57),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF102C57),
          brightness: Brightness.light,
        ),

        // TÜM SAYFALAR İÇİN VARSAYILAN APPBAR AYARI
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF102C57), // PROFESYONEL RENK: Derin Lacivert
          foregroundColor: Colors.white,      // Yazılar ve İkonlar BEYAZ (En iyi kontrast)

          // Hafif bir derinlik hissi
          elevation: 2,
          shadowColor: Colors.black12,

          // Material 3'te kaydırma yapınca rengin grileşmesini/bozulmasını engeller
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent, // Rengi korumak için kritik

          centerTitle: false,

          // Status Bar İkonlarını (Saat, Pil) Beyaz Yapar
          systemOverlayStyle: SystemUiOverlayStyle.light,

          iconTheme: IconThemeData(color: Colors.white, size: 24),
          actionsIconTheme: IconThemeData(color: Colors.white, size: 24),

          // Başlık Stili: Beyaz ve Okunaklı
          titleTextStyle: TextStyle(
            color: Colors.white, // Kesinlikle Beyaz
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5, // Harfler arası hafif boşluk (Premium hissi)
          ),
        ),

        // Text Temaları
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF102C57)), // Yazılarda da bu tonu kullandık
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),

      // ----------- KOYU TEMA (Dark Mode) -----------
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D193F), // Senin özel lacivertin
        cardColor: const Color(0xFF0F162C),
        primaryColor: const Color(0xFF3D8BFF),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D8BFF),
          brightness: Brightness.dark,
          surface: const Color(0xFF0F162C),
        ),

        // Dark Modda AppBar Ayarı
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0D193F), // Sayfa rengiyle bütünleşik
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: false,

          // Status Bar İkonlarını Beyaz Yapar
          systemOverlayStyle: SystemUiOverlayStyle.light,

          // Profesyonel Dokunuş: Başlık ile içeriği ayıran çok ince bir çizgi
          shape: Border(
            bottom: BorderSide(
              color: Colors.white.withOpacity(0.05), // Çok hafif şeffaf çizgi
              width: 1,
            ),
          ),

          titleTextStyle: const TextStyle(
            color: Colors.white, // Burada da Beyaz
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),

        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white60),
        ),
      ),

      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}