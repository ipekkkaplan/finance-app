// screens/settings/update_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _auth = FirebaseAuth.instance;

  // Email Güncelleme Kontrolcüleri
  final _oldEmailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();

  // Şifre Güncelleme Kontrolcüleri
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  // Şifre gizleme/gösterme durumları
  bool _showEmailPassword = false;
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    // Kullanıcının mevcut emailini "Eski Email" alanına otomatik dolduralım
    // Böylece kullanıcı yazmakla uğraşmaz
    if (_auth.currentUser?.email != null) {
      _oldEmailController.text = _auth.currentUser!.email!;
    }
  }

  // ----------------- Email Güncelleme İşlemi -----------------
  Future<void> _updateEmail() async {
    setState(() => _loading = true);
    final user = _auth.currentUser;

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı oturumu bulunamadı.')),
      );
      setState(() => _loading = false);
      return;
    }

    // Basit doğrulama: Alanlar boş mu?
    if (_emailPasswordController.text.isEmpty ||
        _newEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen şifrenizi ve yeni email adresinizi girin.'),
        ),
      );
      setState(() => _loading = false);
      return;
    }

    try {
      // 1. ADIM: Güvenlik için kullanıcıyı yeniden doğruluyoruz (Re-authenticate)
      // Burada kullanıcının elle yazdığı email yerine (user.email) kullanmak daha güvenlidir.
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _emailPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);

      // 2. ADIM: Yeni email adresine doğrulama linki gönderiyoruz
      // Bu işlem sonrası Firebase veritabanında email hemen değişmez.
      // Kullanıcı linke tıkladığında değişir.
      await user.verifyBeforeUpdateEmail(_newEmailController.text.trim());

      if (!mounted) return;

      // 3. ADIM: Kullanıcıyı bilgilendir ve Çıkış Yap
      // Email değişeceği için oturumu kapatmak güvenlik standardıdır.
      await _auth.signOut();

      // Dialog göstermek için context kontrolü
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false, // Kullanıcı boşluğa basıp kapatamasın
        builder:
            (context) => AlertDialog(
              backgroundColor: const Color(0xFF0D1117),
              title: const Text(
                'Doğrulama Maili Gönderildi',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Güvenliğiniz için oturumunuz kapatıldı.\n\nLütfen yeni email adresinize gelen linke tıklayarak değişimi onaylayın, ardından yeni emailinizle giriş yapın.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Dialogu kapat
                    Navigator.of(
                      context,
                    ).pop(); // Profil sayfasından çık (Login'e döner)
                  },
                  child: const Text(
                    'Anladım, Giriş Yap',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Bir hata oluştu.';
      if (e.code == 'wrong-password') {
        message = 'Girdiğiniz şifre yanlış.';
      } else if (e.code == 'email-already-in-use') {
        message =
            'Bu email adresi zaten başka bir hesap tarafından kullanılıyor.';
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz email formatı.';
      } else if (e.code == 'requires-recent-login') {
        message =
            'Oturumunuz zaman aşımına uğradı, lütfen çıkış yapıp tekrar girin.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ----------------- Şifre Güncelleme İşlemi -----------------
  Future<void> _updatePassword() async {
    setState(() => _loading = true);
    final user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı bulunamadı. Lütfen tekrar giriş yapın.'),
        ),
      );
      setState(() => _loading = false);
      return;
    }

    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun.')),
      );
      setState(() => _loading = false);
      return;
    }

    try {
      // 1. Eski şifre ile yeniden doğrulama
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);

      // 2. Yeni şifre eşleşme kontrolü
      if (_newPasswordController.text != _confirmPasswordController.text) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni şifreler birbiriyle eşleşmiyor.')),
        );
        return;
      }

      // 3. Şifre Güçlülük Kontrolü (Regex)
      final password = _newPasswordController.text.trim();
      final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

      if (!passwordRegex.hasMatch(password)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Şifre en az 8 karakter, 1 büyük harf, 1 küçük harf ve 1 rakam içermelidir.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 4. Şifreyi Güncelle
      await user.updatePassword(password);

      if (!mounted) return;

      // Başarı Mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreniz başarıyla güncellendi!'),
          backgroundColor: Colors.green,
        ),
      );

      // Alanları temizle
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = 'Şifre güncellenemedi.';
      if (e.code == 'wrong-password') {
        message = 'Mevcut şifrenizi yanlış girdiniz.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Güvenlik nedeniyle yeniden giriş yapmanız gerekiyor.';
      } else if (e.code == 'weak-password') {
        message = 'Yeni şifreniz çok zayıf.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _oldEmailController.dispose();
    _emailPasswordController.dispose();
    _newEmailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ----------------- TextField Widget Yardımcısı -----------------
  Widget _textField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    VoidCallback? toggleObscure,
    bool showToggle = false,
    bool readOnly = false, // Sadece okunabilir alanlar için (örn: Eski email)
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      style: TextStyle(
        color:
            readOnly
                ? Colors.white54
                : Colors.white, // Okunabilirse gri, değilse beyaz
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        filled: true,
        fillColor: const Color(0xFF0D1117),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
            showToggle
                ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white70,
                  ),
                  onPressed: toggleObscure,
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Güncelle',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0D193F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0D193F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Başlıkları sola hizalar
          children: [
            // --- EMAIL GÜNCELLEME BÖLÜMÜ ---
            const Text(
              'Email Güncelleme',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Eski emaili sadece gösteriyoruz, değiştirtmiyoruz (readOnly: true)
            _textField('Mevcut Email', _oldEmailController, readOnly: true),

            const SizedBox(height: 10),

            _textField(
              'Mevcut Şifreniz (Onay için)',
              _emailPasswordController,
              obscure: !_showEmailPassword,
              showToggle: true,
              toggleObscure: () {
                setState(() => _showEmailPassword = !_showEmailPassword);
              },
            ),

            const SizedBox(height: 10),

            _textField('Yeni Email Adresi', _newEmailController),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _updateEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:
                    _loading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Emaili Güncelle',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
              ),
            ),

            const SizedBox(height: 40), // Bölümler arası boşluk
            const Divider(color: Colors.white24), // Çizgi ile ayırma
            const SizedBox(height: 20),

            // --- ŞİFRE GÜNCELLEME BÖLÜMÜ ---
            const Text(
              'Şifre Güncelleme',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _textField(
              'Eski Şifre',
              _oldPasswordController,
              obscure: !_showOldPassword,
              showToggle: true,
              toggleObscure: () {
                setState(() => _showOldPassword = !_showOldPassword);
              },
            ),
            const SizedBox(height: 10),
            _textField(
              'Yeni Şifre',
              _newPasswordController,
              obscure: !_showNewPassword,
              showToggle: true,
              toggleObscure: () {
                setState(() => _showNewPassword = !_showNewPassword);
              },
            ),
            const SizedBox(height: 10),
            _textField(
              'Yeni Şifre (Tekrar)',
              _confirmPasswordController,
              obscure: !_showConfirmPassword,
              showToggle: true,
              toggleObscure: () {
                setState(() => _showConfirmPassword = !_showConfirmPassword);
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:
                    _loading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Şifre Güncelle',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 30), // Alt boşluk
          ],
        ),
      ),
    );
  }
}
