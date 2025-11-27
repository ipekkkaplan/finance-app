import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _auth = FirebaseAuth.instance;

  // Email Güncelleme
  final _oldEmailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();

  // Şifre Güncelleme
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  // Şifre göz toggle'ları
  bool _showEmailPassword = false;
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // ----------------- Email Güncelle -----------------
  Future<void> _updateEmail() async {
    setState(() => _loading = true);
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Kullanıcıyı yeniden doğrula
      final cred = EmailAuthProvider.credential(
          email: _oldEmailController.text.trim(),
          password: _emailPasswordController.text.trim());
      await user.reauthenticateWithCredential(cred);

      // Email güncelle
      await user.updateEmail(_newEmailController.text.trim());

      // Yeni email'e doğrulama maili gönder
      await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Email başarıyla güncellendi! Yeni email adresine doğrulama maili gönderildi.'),
        ),
      );

      // Kullanıcı doğrulama yapmadan yeni email ile işlem yapamayacak
      await _auth.signOut();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF0D1117),
          title: const Text('Doğrulama Gerekiyor',
              style: TextStyle(color: Colors.white)),
          content: const Text(
              'Yeni email adresinizi doğrulamadan giriş yapamazsınız. Lütfen mailinizi kontrol edin.',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tamam', style: TextStyle(color: Colors.blue)),
            )
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email güncellenemedi: ${e.message}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // ----------------- Şifre Güncelle -----------------
  Future<void> _updatePassword() async {
    setState(() => _loading = true);
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı bulunamadı. Lütfen tekrar giriş yapın.')),
      );
      setState(() => _loading = false);
      return;
    }

    try {
      // Eski şifre ile yeniden doğrulama
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: _oldPasswordController.text.trim());
      await user.reauthenticateWithCredential(cred);

      // Yeni şifreler eşleşiyor mu kontrolü
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'Yeni şifre ve tekrar şifre eşleşmiyor. Lütfen iki alana da aynı şifreyi.')),
        );
        return;
      }

      // Şifre güçlü mü kontrolü
      final password = _newPasswordController.text.trim();
      final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');
      if (!passwordRegex.hasMatch(password)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'Şifre güçlü değil! En az 8 karakter, 1 büyük harf, 1 küçük harf ve 1 sayı içermelidir.')),
        );
        return;
      }

      // Şifre güncelleme
      await user.updatePassword(password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre başarıyla güncellendi!')),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Şifre güncellenemedi. Lütfen tekrar deneyin.';
      if (e.code == 'wrong-password') {
        message = 'Eski şifre yanlış. Lütfen doğru şifreyi girin.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Güvenlik nedeniyle işlemi tekrar yapmak için yeniden giriş yapmanız gerekiyor.';
      } else if (e.code == 'weak-password') {
        message = 'Yeni şifreniz çok zayıf. Lütfen daha güçlü bir şifre seçin.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => _loading = false);
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

  // ----------------- TextField Widget -----------------
  Widget _textField(String label, TextEditingController controller,
      {bool obscure = false, VoidCallback? toggleObscure, bool showToggle = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: const Color(0xFF0D1117),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: showToggle
            ? IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.white70),
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
        title: const Text('Profil Güncelle',
        style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF0D193F),
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
      ),
      backgroundColor: const Color(0xFF0D193F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Email Güncelleme',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _textField('Eski Email', _oldEmailController),
            const SizedBox(height: 10),
            _textField('Şifre', _emailPasswordController,
                obscure: !_showEmailPassword,
                showToggle: true,
                toggleObscure: () {
                  setState(() => _showEmailPassword = !_showEmailPassword);
                }),
            const SizedBox(height: 10),
            _textField('Yeni Email', _newEmailController),
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
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Email Güncelle',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
            ),
            const SizedBox(height: 30),
            const Text('Şifre Güncelleme',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _textField('Eski Şifre', _oldPasswordController,
                obscure: !_showOldPassword,
                showToggle: true,
                toggleObscure: () {
                  setState(() => _showOldPassword = !_showOldPassword);
                }),
            const SizedBox(height: 10),
            _textField('Yeni Şifre', _newPasswordController,
                obscure: !_showNewPassword,
                showToggle: true,
                toggleObscure: () {
                  setState(() => _showNewPassword = !_showNewPassword);
                }),
            const SizedBox(height: 10),
            _textField('Yeni Şifre (Tekrar)', _confirmPasswordController,
                obscure: !_showConfirmPassword,
                showToggle: true,
                toggleObscure: () {
                  setState(() => _showConfirmPassword = !_showConfirmPassword);
                }),
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
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Şifre Güncelle',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
