import 'package:finance_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:finance_app/screens/auth_screen/signup_screen.dart';
import 'package:finance_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_app/services/two_factor_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();

  bool _sifreGizli = true;
  bool _beniHatirla = false;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.signInUser(
      email: _emailController.text.trim(),
      password: _sifreController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result["success"] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Hata oluştu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2FA KONTROL
    final prefs = await SharedPreferences.getInstance();
    final twoFA = prefs.getBool("twoFactor") ?? false;

    if (!twoFA) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }

    // 2FA AKTİFSE KOD ÜRET & POPUP AÇ
    final twoFactor = TwoFactorService();
    final code = await twoFactor.generateCode();

    await twoFactor.sendCode(_emailController.text.trim(), code);

    String enteredCode = "";

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Doğrulama Kodu"),
          content: TextField(
            onChanged: (v) => enteredCode = v,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "6 haneli kodu gir"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () async {
                final response = await twoFactor.verifyCode(enteredCode);

                if (response["ok"] != true) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(response["error"])));
                  return;
                }

                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: const Text("Onayla"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyMedium!.color!;
    final cardColor = theme.cardColor;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // ÜST HEADER
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  "Hoşgeldiniz",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // LOGIN KARTI
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.22,
            ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow:
                          theme.brightness == Brightness.light
                              ? [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, 6),
                                ),
                              ]
                              : [],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // EMAIL
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: textColor.withOpacity(.8),
                              ),
                              filled: true,
                              fillColor:
                                  theme.brightness == Brightness.dark
                                      ? Colors.white.withOpacity(.05)
                                      : Colors.black.withOpacity(.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(color: textColor),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? "Email giriniz"
                                        : null,
                          ),

                          const SizedBox(height: 20),

                          // ŞİFRE
                          TextFormField(
                            controller: _sifreController,
                            obscureText: _sifreGizli,
                            decoration: InputDecoration(
                              labelText: "Şifre",
                              prefixIcon: Icon(
                                Icons.lock_outlined,
                                color: textColor.withOpacity(.8),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _sifreGizli
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: textColor.withOpacity(.6),
                                ),
                                onPressed: () {
                                  setState(() => _sifreGizli = !_sifreGizli);
                                },
                              ),
                              filled: true,
                              fillColor:
                                  theme.brightness == Brightness.dark
                                      ? Colors.white.withOpacity(.05)
                                      : Colors.black.withOpacity(.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(color: textColor),
                            validator:
                                (value) =>
                                    value == null || value.isEmpty
                                        ? "Şifre giriniz"
                                        : null,
                          ),

                          const SizedBox(height: 12),

                          // BENİ HATIRLA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _beniHatirla,
                                    onChanged: (v) {
                                      setState(() => _beniHatirla = v ?? false);
                                    },
                                    activeColor: primary,
                                  ),
                                  Text(
                                    "Beni Hatırla",
                                    style: TextStyle(color: textColor),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  "Şifremi Unuttum",
                                  style: TextStyle(color: primary),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // GİRİŞ BUTONU
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        "Giriş Yap",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                        ),
                                      ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ÜYE OL
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Hesabınız yok mu?",
                                style: TextStyle(color: textColor),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Üye Olun",
                                  style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
