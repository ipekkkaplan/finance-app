// main.dart
import 'package:finance_app/screens/auth_screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:finance_app/theme_provider.dart';
import 'package:finance_app/providers/auth_provider.dart';
import 'package:finance_app/services/supabase_config.dart';
import 'package:finance_app/core/theme/app_theme.dart';

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
      // Tema tanımları core/theme/app_theme.dart içine taşındı (AppTheme).
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}
