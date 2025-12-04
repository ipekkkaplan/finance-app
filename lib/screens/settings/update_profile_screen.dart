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

  // Marka Rengi (Butonlar için sabit kalabilir veya temadan çekilebilir)
  final Color successColor = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
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
      // 1. ADIM: Güvenlik için kullanıcıyı yeniden doğruluyoruz
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _emailPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);

      // 2. ADIM: Yeni email adresine doğrulama linki gönderiyoruz
      await user.verifyBeforeUpdateEmail(_newEmailController.text.trim());

      if (!mounted) return;

      // 3. ADIM: Kullanıcıyı bilgilendir ve Çıkış Yap
      await _auth.signOut();

      if (!mounted) return;

      // Dialog renklerini de temaya uygun hale getirmek için context'ten alıyoruz
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final dialogBg = isDark ? const Color(0xFF0D1117) : Colors.white;
      final titleColor = isDark ? Colors.white : Colors.black;
      final contentColor = isDark ? Colors.white70 : Colors.black87;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
          backgroundColor: dialogBg,
          title: Text(
            'Doğrulama Maili Gönderildi',
            style: TextStyle(color: titleColor),
          ),
          content: Text(
            'Güvenliğiniz için oturumunuz kapatıldı.\n\nLütfen yeni email adresinize gelen linke tıklayarak değişimi onaylayın, ardından yeni emailinizle giriş yapın.',
            style: TextStyle(color: contentColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
                Navigator.of(context).pop(); // Profil sayfasından çık
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
        message = 'Bu email adresi zaten kullanılıyor.';
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz email formatı.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Lütfen çıkış yapıp tekrar girin.';
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
          const SnackBar(content: Text('Yeni şifreler eşleşmiyor.')),
        );
        return;
      }

      // 3. Şifre Güçlülük Kontrolü
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreniz başarıyla güncellendi!'),
          backgroundColor: Colors.green,
        ),
      );

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
        bool readOnly = false,
        // Renkleri parametre olarak alıyoruz
        required Color fillColor,
        required Color textColor,
        required Color labelColor,
        required Color iconColor,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      style: TextStyle(
        color:
        readOnly
            ? textColor.withValues(alpha: 0.6)
            : textColor, // Okunabilirse soluk, değilse normal
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: labelColor),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
        showToggle
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: iconColor,
          ),
          onPressed: toggleObscure,
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TEMA VERİLERİNİ ÇEKİYORUZ
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dinamik renkler
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final appBarBg = theme.scaffoldBackgroundColor; // AppBar scaffold ile aynı renk
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final labelColor = isDark ? Colors.white70 : Colors.grey[700]!;
    final inputFillColor = isDark ? const Color(0xFF0D1117) : Colors.grey[200]!;
    final iconColor = theme.iconTheme.color ?? textColor;
    final dividerColor = theme.dividerColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Güncelle',
          style: TextStyle(color: textColor, fontSize: 20),
        ),
        backgroundColor: appBarBg,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor), // Geri butonu rengi
      ),
      backgroundColor: scaffoldBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- EMAIL GÜNCELLEME BÖLÜMÜ ---
            Text(
              'Email Güncelleme',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _textField(
              'Mevcut Email',
              _oldEmailController,
              readOnly: true,
              fillColor: inputFillColor,
              textColor: textColor,
              labelColor: labelColor,
              iconColor: iconColor,
            ),

            const SizedBox(height: 10),

            _textField(
              'Mevcut Şifreniz (Onay için)',
              _emailPasswordController,
              obscure: !_showEmailPassword,
              showToggle: true,
              toggleObscure: () {
                setState(() => _showEmailPassword = !_showEmailPassword);
              },
              fillColor: inputFillColor,
              textColor: textColor,
              labelColor: labelColor,
              iconColor: iconColor,
            ),

            const SizedBox(height: 10),

            _textField(
              'Yeni Email Adresi',
              _newEmailController,
              fillColor: inputFillColor,
              textColor: textColor,
              labelColor: labelColor,
              iconColor: iconColor,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _updateEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: successColor,
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
                    color: Colors.white, // Yükleme ikonu beyaz
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Emaili Güncelle',
                  style: TextStyle(
                    color: Colors.white, // Buton yazısı beyaz
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),
            Divider(color: dividerColor), // Dinamik ayıraç rengi
            const SizedBox(height: 20),

            // --- ŞİFRE GÜNCELLEME BÖLÜMÜ ---
            Text(
              'Şifre Güncelleme',
              style: TextStyle(
                color: textColor,
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
              fillColor: inputFillColor,
              textColor: textColor,
              labelColor: labelColor,
              iconColor: iconColor,
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
              fillColor: inputFillColor,
              textColor: textColor,
              labelColor: labelColor,
              iconColor: iconColor,
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
              fillColor: inputFillColor,
              textColor: textColor,
              labelColor: labelColor,
              iconColor: iconColor,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: successColor,
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
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Şifre Güncelle',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}