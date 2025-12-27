import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // E-posta girişini almak için controller
  final TextEditingController _emailController = TextEditingController();

  // Yükleniyor durumu kontrolü
  bool _isLoading = false;

  // Firebase Şifre Sıfırlama Fonksiyonu
  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    // 1. E-posta alanı boş mu kontrol et
    if (email.isEmpty) {
      _showSnackBar("Lütfen e-posta adresinizi giriniz.", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Firebase'e sıfırlama maili gönderme isteği at
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // 3. Başarılı olursa kullanıcıya bilgi ver ve giriş sayfasına dön
      if (mounted) {
        _showSnackBar(
          "Sıfırlama bağlantısı e-posta adresinize gönderildi.",
          Colors.green,
        );
        Navigator.pop(context); // Giriş ekranına geri dön
      }
    } on FirebaseAuthException catch (e) {
      // 4. Hata olursa (örn: böyle bir kullanıcı yoksa)
      String errorMessage = "Bir hata oluştu.";
      if (e.code == 'user-not-found') {
        errorMessage = "Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Geçersiz bir e-posta adresi girdiniz.";
      }

      if (mounted) {
        _showSnackBar(errorMessage, Colors.red);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Beklenmedik bir hata: $e", Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Yardımcı Fonksiyon: Alt tarafta mesaj gösterme (SnackBar)
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tema renklerini alalım
    final primaryColor = const Color(0xFF3D8BFF); // Senin projendeki mavi tonu

    return Scaffold(
      appBar: AppBar(
        title: const Text("Şifremi Unuttum"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor:
            Theme.of(context).textTheme.bodyLarge?.color, // İkon rengi
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "Şifrenizi mi unuttunuz?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Kayıtlı e-posta adresinizi girin, size şifrenizi sıfırlamanız için bir bağlantı gönderelim.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),

            // E-posta Giriş Alanı
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "E-posta Adresi",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Gönder Butonu
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _resetPassword,
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
                          "Sıfırlama Bağlantısı Gönder",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
