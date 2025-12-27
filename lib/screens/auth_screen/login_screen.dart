import 'package:finance_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:finance_app/screens/auth_screen/signup_screen.dart';
import 'package:finance_app/services/auth_service.dart';
import 'package:finance_app/widgets/force_light_mode.dart';
import 'package:finance_app/screens/auth_screen/reset_password_screen.dart'; // Reset ekranı importu

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form controller'ları
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();

  // Şifre görünürlük kontrolü
  bool _sifreGizli = true;

  // Beni hatırla
  bool _beniHatirla = false;

  // Firebase Auth servisi
  final AuthService _authService = AuthService();

  // Loading durumu
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.signInUser(
          email: _emailController.text.trim(),
          password: _sifreController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Giriş başarılı!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          // Hata durumu
          if (result['emailNotVerified'] == true) {
            if (mounted) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Email Doğrulanmamış'),
                      content: const Text(
                        'Email adresiniz henüz doğrulanmamış. Lütfen email adresinizi kontrol edip doğrulama linkine tıklayın. Veya doğrulama mailini yeniden göndermek ister misiniz?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('İptal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.pop(context);
                            final resendResult =
                                await _authService.resendVerificationEmail();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  resendResult['message'] ?? 'İşlem tamamlandı',
                                ),
                                backgroundColor:
                                    resendResult['success'] == true
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            );
                          },
                          child: const Text('Yeniden Gönder'),
                        ),
                      ],
                    ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Bir hata oluştu'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Beklenmeyen bir hata oluştu: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Klavye açıldığında tasarımın bozulmaması için ForceLightMode içinde Scaffold
    return ForceLightMode(
      child: Scaffold(
        // Arka plan rengi yerine Container gradient kullanacağımız için burası şeffaf olabilir veya koyu renk
        backgroundColor: const Color(0xFF000428),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // --- SPLASH SCREEN İLE AYNI GRADIENT ---
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF000428), Color(0xFF001535), Color(0xFF002650)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Geri Butonu
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30), // Hafif şeffaf
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Başlık ve Logo Alanı
                  const Center(
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        Text(
                          " Hoşgeldiniz",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Yatırımlarınızı yönetmek için giriş yapın",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- BEYAZ KART TASARIMI ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: "Email Adresi",
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF002650),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen email giriniz';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Geçerli bir email giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Şifre
                          TextFormField(
                            controller: _sifreController,
                            obscureText: _sifreGizli,
                            style: const TextStyle(color: Colors.black87),
                            decoration: InputDecoration(
                              labelText: "Şifre",
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _sifreGizli
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sifreGizli = !_sifreGizli;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF002650),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Şifre giriniz';
                              }
                              if (value.length < 6) {
                                return 'En az 6 karakter';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Beni Hatırla ve Şifremi Unuttum Satırı
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _beniHatirla,
                                      activeColor: const Color(0xFF002650),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (val) {
                                        setState(
                                          () => _beniHatirla = val ?? false,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Beni Hatırla",
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const ResetPasswordScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Şifremi Unuttum",
                                  style: TextStyle(
                                    color: Color(0xFF002650),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Giriş Yap Butonu
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF002650,
                                ), // Lacivert Buton
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                shadowColor: const Color(
                                  0xFF002650,
                                ).withAlpha(100),
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        "Giriş Yap",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Kayıt Ol Linki
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Hesabınız yok mu? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Hemen Kayıt Olun",
                            style: TextStyle(
                              color:
                                  Colors
                                      .white, // Koyu zemin üzerinde beyaz text daha okunaklı
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
