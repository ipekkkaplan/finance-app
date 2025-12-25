import 'package:finance_app/screens/auth_screen/login_screen.dart';
import 'package:finance_app/screens/auth_screen/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:finance_app/widgets/force_light_mode.dart'; // Dark mode'dan etkilenmesin diye widget

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  Widget build(BuildContext context) {
    // Scaffold'ı ForceLightMode ile sarmalıyoruz
    return ForceLightMode(
      child: Scaffold(
        // Arka plan rengini ve gradient'i burada yönetiyoruz
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE6E9F0), // Fintech Trust: Metalik/Gri-Mavi
                Color(0xFFEEF1F5), // Fintech Trust: Açık Baza Geçiş
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Üst kısımdaki boşluğu esnek bırakıyoruz (Logo yukarıda kalsın)
                  const Spacer(flex: 2),

                  // --- LOGO ALANI ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1), // Hafif gölge
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.show_chart,
                      size: 80,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- BAŞLIK ---
                  const Text(
                    "FinScope AI",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900, // Kalın, güçlü font
                      color: Colors.black,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // --- ALT METİN ---
                  Text(
                    "Akıllı yatırımcılar için\nyapay zeka destekli analiz.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black.withOpacity(0.7), // Hafif grileştirilmiş siyah
                    ),
                  ),

                  // İçeriği yukarı, butonları aşağı iten esnek boşluk
                  const Spacer(flex: 3),

                  // --- BUTONLAR ---
                  Column(
                    children: [
                      // Giriş Yap Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 56, // Modern buton yüksekliği
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 8, // Buton gölgesi
                            shadowColor: Colors.black.withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Giriş Yap",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Üye Ol Butonu
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.6), // Hafif transparan beyaz zemin
                            foregroundColor: Colors.black,
                            side: const BorderSide(color: Colors.black, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Üye Ol",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // En alttan güvenli boşluk
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}