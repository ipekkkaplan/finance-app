// main.dart
import 'package:finance_app/screens/auth_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Status Bar kontrolü için eklendi
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:finance_app/theme_provider.dart';
import 'package:finance_app/providers/auth_provider.dart';
import 'package:finance_app/services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase hatası: $e');
  }

  // Algo trade icin Supabase baslatilir. Uzun vade yatirim akisi
  // Firebase ile devam eder, bu sadece algo trade icin eklenir.
  try {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  } catch (e) {
    debugPrint('Supabase hatası: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
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
        scaffoldBackgroundColor: const Color(
          0xFFF5F5F5,
        ),
        // Ana renk
        primaryColor: const Color(0xFF102C57),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF102C57),
          brightness: Brightness.light,
        ),

        // Tüm sayfalar için appbar ayarı
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(
            0xFF102C57,
          ),
          foregroundColor:
              Colors.white,

          elevation: 2,
          shadowColor: Colors.black12,

          // Material 3'te kaydırma yapınca rengin grileşmesini/bozulmasını engeller
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

        // Text Temaları
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: Color(0xFF102C57),
          ),
          bodyMedium: TextStyle(color: Colors.black54),
        ),
      ),

      // ----------- KOYU TEMA (Dark Mode) -----------
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(
          0xFF0D193F,
        ), // Senin özel lacivertin
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


          systemOverlayStyle: SystemUiOverlayStyle.light,


          shape: Border(
            bottom: BorderSide(
              color: Colors.white.withValues(
                alpha: 0.2,
              ), // Çok hafif şeffaf çizgi
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
