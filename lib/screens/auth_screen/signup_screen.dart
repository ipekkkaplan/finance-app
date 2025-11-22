import 'package:flutter/material.dart';
import 'package:finance_app/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Form controller'ları
  final _formKey = GlobalKey<FormState>();
  final _isimController = TextEditingController();
  final _soyisimController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();

  // Şifre görünürlük kontrolü
  bool _sifreGizli = true;
  bool _sifreTekrarGizli = true;

  // Doğum günü
  DateTime? _dogumGunu;
  String? _yas;

  // Sözleşme onayları
  bool _kullanimSozlesmesi = false;
  bool _kvkkOnay = false;

  // Ülke kodu
  String _ulkeKodu = '+90';

  // Firebase Auth servisi
  final AuthService _authService = AuthService();

  // Loading durumu
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Form değişikliklerini dinle
    _isimController.addListener(_validateForm);
    _soyisimController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _telefonController.addListener(_validateForm);
    _sifreController.addListener(_validateForm);
    _sifreTekrarController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _isimController.dispose();
    _soyisimController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _sifreController.dispose();
    _sifreTekrarController.dispose();
    super.dispose();
  }

  // Form validasyonu kontrolü
  void _validateForm() {
    setState(() {});
  }

  // Şifre gereksinimlerini kontrol et
  Map<String, bool> _sifreGereksinimleri() {
    final sifre = _sifreController.text;
    return {
      'enAz8Karakter': sifre.length >= 8,
      'buyukHarf': sifre.contains(RegExp(r'[A-Z]')),
      'kucukHarf': sifre.contains(RegExp(r'[a-z]')),
      'sayi': sifre.contains(RegExp(r'[0-9]')),
    };
  }

  // Tüm şifre gereksinimleri karşılanıyor mu?
  bool _sifreGereksinimleriKarsilaniyor() {
    final gereksinimler = _sifreGereksinimleri();
    return gereksinimler.values.every((value) => value);
  }

  // Form dolu mu kontrolü
  bool _formDoluMu() {
    return _isimController.text.isNotEmpty &&
        _soyisimController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _telefonController.text.isNotEmpty &&
        _sifreController.text.isNotEmpty &&
        _sifreTekrarController.text.isNotEmpty &&
        _dogumGunu != null &&
        _kullanimSozlesmesi &&
        _kvkkOnay &&
        _sifreGereksinimleriKarsilaniyor() &&
        _sifreController.text == _sifreTekrarController.text;
  }

  // Yaş hesaplama
  void _yasHesapla() {
    if (_dogumGunu != null) {
      final bugun = DateTime.now();
      int yas = bugun.year - _dogumGunu!.year;
      if (bugun.month < _dogumGunu!.month ||
          (bugun.month == _dogumGunu!.month && bugun.day < _dogumGunu!.day)) {
        yas--;
      }
      setState(() {
        _yas = yas.toString();
      });
    }
  }

  // Doğum günü seçici
  Future<void> _dogumGunuSec() async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Doğum Gününüzü Seçin',
      cancelText: 'İptal',
      confirmText: 'Seç',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0D47A1),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (secilen != null) {
      setState(() {
        _dogumGunu = secilen;
        _yasHesapla();
      });
    }
  }

  // Şifre validasyonu
  String? _sifreValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen şifrenizi giriniz';
    }
    final gereksinimler = _sifreGereksinimleri();
    if (!gereksinimler['enAz8Karakter']!) {
      return 'Şifre en az 8 karakter olmalıdır';
    }
    if (!gereksinimler['buyukHarf']!) {
      return 'Şifre en az 1 büyük harf içermelidir';
    }
    if (!gereksinimler['kucukHarf']!) {
      return 'Şifre en az 1 küçük harf içermelidir';
    }
    if (!gereksinimler['sayi']!) {
      return 'Şifre en az 1 sayı içermelidir';
    }
    return null;
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate() && _formDoluMu()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await _authService.registerUser(
          email: _emailController.text.trim(),
          password: _sifreController.text,
          firstName: _isimController.text.trim(),
          lastName: _soyisimController.text.trim(),
          phoneNumber: '$_ulkeKodu${_telefonController.text.trim()}',
          birthDate: _dogumGunu,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Başarılı kayıt
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Kayıt başarılı! Email doğrulama maili gönderildi. Lütfen email adresinizi kontrol edin.',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );

            // Email doğrulama uyarısı göster
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Email Doğrulama'),
                    content: const Text(
                      'Kayıt işleminiz başarıyla tamamlandı! Email adresinize doğrulama maili gönderildi. Lütfen email adresinizi kontrol edip doğrulama linkine tıklayın.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Dialog'u kapat
                          Navigator.pop(context); // Signup ekranından çık
                        },
                        child: const Text('Tamam'),
                      ),
                    ],
                  ),
            );
          }
        } else {
          // Hata durumu
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
    final gereksinimler = _sifreGereksinimleri();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // Üstteki koyu mavi başlık bölümü
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: const BoxDecoration(
              color: Color(0xFF0D47A1),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "Üye Ol",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Geri butonu - daha küçük ve modern
                Positioned(
                  top: 40,
                  left: 10,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form kartı
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          // İsim alanı
                          TextFormField(
                            controller: _isimController,
                            decoration: InputDecoration(
                              hintText: "Adınızı giriniz",
                              labelText: "İsim",
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              constraints: const BoxConstraints(minHeight: 48),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0D47A1),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen isminizi giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Soyisim alanı
                          TextFormField(
                            controller: _soyisimController,
                            decoration: InputDecoration(
                              hintText: "Soyadınızı giriniz",
                              labelText: "Soyisim",
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              constraints: const BoxConstraints(minHeight: 48),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0D47A1),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen soyisminizi giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Email alanı
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "example@example.com",
                              labelText: "Email Adresi",
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              constraints: const BoxConstraints(minHeight: 48),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0D47A1),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen email adresinizi giriniz';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Geçerli bir email adresi giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Telefon alanı
                          Row(
                            children: [
                              // Ülke kodu seçici
                              Container(
                                width: 80,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: PopupMenuButton<String>(
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _ulkeKodu,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  onSelected: (value) {
                                    setState(() {
                                      _ulkeKodu = value;
                                    });
                                  },
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: '+90',
                                          child: Text('+90 (TR)'),
                                        ),
                                        const PopupMenuItem(
                                          value: '+1',
                                          child: Text('+1 (US)'),
                                        ),
                                        const PopupMenuItem(
                                          value: '+44',
                                          child: Text('+44 (UK)'),
                                        ),
                                      ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              // Telefon numarası
                              Expanded(
                                child: TextFormField(
                                  controller: _telefonController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    hintText: "5XX XXX XX XX",
                                    labelText: "Telefon Numarası",
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    constraints: const BoxConstraints(
                                      minHeight: 48,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF0D47A1),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen telefon numaranızı giriniz';
                                    }
                                    if (value.length < 10) {
                                      return 'Geçerli bir telefon numarası giriniz';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Şifre Oluştur alanı
                          TextFormField(
                            controller: _sifreController,
                            obscureText: _sifreGizli,
                            decoration: InputDecoration(
                              hintText: "Şifrenizi giriniz",
                              labelText: "Şifre Oluştur",
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              constraints: const BoxConstraints(minHeight: 48),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _sifreGizli
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sifreGizli = !_sifreGizli;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0D47A1),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: _sifreValidator,
                          ),
                          // Şifre gereksinimleri
                          if (_sifreController.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sifreGereksinimiItem(
                                    'En az 8 karakter',
                                    gereksinimler['enAz8Karakter']!,
                                  ),
                                  const SizedBox(height: 4),
                                  _sifreGereksinimiItem(
                                    '1 büyük harf (A-Z)',
                                    gereksinimler['buyukHarf']!,
                                  ),
                                  const SizedBox(height: 4),
                                  _sifreGereksinimiItem(
                                    '1 küçük harf (a-z)',
                                    gereksinimler['kucukHarf']!,
                                  ),
                                  const SizedBox(height: 4),
                                  _sifreGereksinimiItem(
                                    '1 sayı (0-9)',
                                    gereksinimler['sayi']!,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          // Şifreyi Tekrarla alanı
                          TextFormField(
                            controller: _sifreTekrarController,
                            obscureText: _sifreTekrarGizli,
                            decoration: InputDecoration(
                              hintText: "Şifrenizi tekrar giriniz",
                              labelText: "Şifreyi Tekrarla",
                              filled: true,
                              fillColor: const Color(0xFFF5F5F5),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              constraints: const BoxConstraints(minHeight: 48),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _sifreTekrarGizli
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey[600],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sifreTekrarGizli = !_sifreTekrarGizli;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0D47A1),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen şifrenizi tekrar giriniz';
                              }
                              if (value != _sifreController.text) {
                                return 'Şifreler eşleşmiyor';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Doğum Günü alanı
                          InkWell(
                            onTap: _dogumGunuSec,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              constraints: const BoxConstraints(minHeight: 48),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _dogumGunu == null
                                              ? 'Doğum Günü'
                                              : '${_dogumGunu!.day}/${_dogumGunu!.month}/${_dogumGunu!.year}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color:
                                                _dogumGunu == null
                                                    ? Colors.grey[600]
                                                    : Colors.black87,
                                          ),
                                        ),
                                        if (_yas != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Yaş: $_yas',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Sözleşme onayları
                          // Kullanıcı Sözleşmesi
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _kullanimSozlesmesi,
                                onChanged: (value) {
                                  setState(() {
                                    _kullanimSozlesmesi = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF0D47A1),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // Sözleşme sayfasına yönlendirme
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              'Kullanıcı Sözleşmesi',
                                            ),
                                            content: const SingleChildScrollView(
                                              child: Text(
                                                'Buraya kullanıcı sözleşmesi metni gelecek...',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text('Kapat'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Kullanıcı Sözleşmesini ',
                                        ),
                                        TextSpan(
                                          text: 'okudum ve onaylıyorum',
                                          style: TextStyle(
                                            color:
                                                _kullanimSozlesmesi
                                                    ? const Color(0xFF0D47A1)
                                                    : Colors.blue,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // KVKK Onayı
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: _kvkkOnay,
                                onChanged: (value) {
                                  setState(() {
                                    _kvkkOnay = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF0D47A1),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // KVKK sayfasına yönlendirme
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text(
                                              'KVKK Aydınlatma Metni',
                                            ),
                                            content: const SingleChildScrollView(
                                              child: Text(
                                                'Buraya KVKK aydınlatma metni gelecek...',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text('Kapat'),
                                              ),
                                            ],
                                          ),
                                    );
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'KVKK Aydınlatma Metnini ',
                                        ),
                                        TextSpan(
                                          text: 'kabul ediyorum',
                                          style: TextStyle(
                                            color:
                                                _kvkkOnay
                                                    ? const Color(0xFF0D47A1)
                                                    : Colors.blue,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Üye Ol butonu
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  (_formDoluMu() && !_isLoading)
                                      ? _handleSignup
                                      : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D47A1),
                                disabledBackgroundColor: Colors.grey[300],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: _formDoluMu() ? 2 : 0,
                              ),
                              child:
                                  _isLoading
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : const Text(
                                        "Üye Ol",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 10),
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

  // Şifre gereksinimi gösterimi
  Widget _sifreGereksinimiItem(String text, bool tamamlandi) {
    return Row(
      children: [
        Icon(
          tamamlandi ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: tamamlandi ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: tamamlandi ? Colors.green : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
