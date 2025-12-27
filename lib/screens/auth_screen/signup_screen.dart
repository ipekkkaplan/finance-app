import 'package:flutter/material.dart';
import 'package:finance_app/services/auth_service.dart';
import 'package:finance_app/widgets/force_light_mode.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // --- MEVCUT DEĞİŞKENLER VE CONTROLLER'LAR  ---
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


  final Color _primaryColor = const Color(0xFF002650);

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
            colorScheme: ColorScheme.light(
              primary: _primaryColor, // Login rengi
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Kayıt başarılı! Email doğrulama maili gönderildi.',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );

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

  // --- ORTAK INPUT DECORATION (Login tasarımıyla uyumlu) ---
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gereksinimler = _sifreGereksinimleri();

    return ForceLightMode(
      child: Scaffold(
        backgroundColor: const Color(0xFF000428), // Login arka planı
        body: Container(
          width: double.infinity,
          height: double.infinity,
          // --- LOGIN İLE AYNI GRADIENT ---
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF000428), Color(0xFF001535), Color(0xFF002650)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- GERİ BUTONU ---
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- BAŞLIK ALANI ---
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          "Aramıza Katılın",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Formu doldurarak hemen üye olun",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // İsim
                          TextFormField(
                            controller: _isimController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: _buildInputDecoration(
                              "İsim",
                              Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen isminizi giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Soyisim
                          TextFormField(
                            controller: _soyisimController,
                            style: const TextStyle(color: Colors.black87),
                            decoration: _buildInputDecoration(
                              "Soyisim",
                              Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Lütfen soyisminizi giriniz';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.black87),
                            decoration: _buildInputDecoration(
                              "Email Adresi",
                              Icons.email_outlined,
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
                          const SizedBox(height: 20),

                          // Telefon
                          Row(
                            children: [
                              // Ülke kodu
                              Container(
                                width: 90,
                                height: 56, // Input yüksekliği ile aynı
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
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
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          size: 20,
                                          color: Colors.black54,
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
                                  style: const TextStyle(color: Colors.black87),
                                  decoration: _buildInputDecoration(
                                    "Telefon",
                                    Icons.phone_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Lütfen telefon giriniz';
                                    }
                                    if (value.length < 10) {
                                      return 'Geçerli telefon giriniz';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Doğum Günü
                          InkWell(
                            onTap: _dogumGunuSec,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
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
                                                ? Colors.black54
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (_yas != null)
                                          Text(
                                            'Yaş: $_yas',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Şifre
                          TextFormField(
                            controller: _sifreController,
                            obscureText: _sifreGizli,
                            style: const TextStyle(color: Colors.black87),
                            decoration: _buildInputDecoration(
                              "Şifre",
                              Icons.lock_outline,
                            ).copyWith(
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
                            ),
                            validator: _sifreValidator,
                          ),

                          // Şifre gereksinimleri (Login tarzına uyumlu ince font)
                          if (_sifreController.text.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _sifreGereksinimiItem(
                                    'En az 8 karakter',
                                    gereksinimler['enAz8Karakter']!,
                                  ),
                                  _sifreGereksinimiItem(
                                    '1 büyük harf (A-Z)',
                                    gereksinimler['buyukHarf']!,
                                  ),
                                  _sifreGereksinimiItem(
                                    '1 küçük harf (a-z)',
                                    gereksinimler['kucukHarf']!,
                                  ),
                                  _sifreGereksinimiItem(
                                    '1 sayı (0-9)',
                                    gereksinimler['sayi']!,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Şifre Tekrar
                          TextFormField(
                            controller: _sifreTekrarController,
                            obscureText: _sifreTekrarGizli,
                            style: const TextStyle(color: Colors.black87),
                            decoration: _buildInputDecoration(
                              "Şifre Tekrar",
                              Icons.lock_reset,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _sifreTekrarGizli
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _sifreTekrarGizli = !_sifreTekrarGizli;
                                  });
                                },
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

                          const SizedBox(height: 24),

                          // Sözleşme Onayları
                          // Kullanıcı Sözleşmesi
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _kullanimSozlesmesi,
                                  activeColor: _primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _kullanimSozlesmesi = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _sozlesmeGoster('Kullanıcı Sözleşmesi');
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
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
                                                ? _primaryColor
                                                : Colors.blue,
                                            fontWeight: FontWeight.bold,
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
                          const SizedBox(height: 12),
                          // KVKK Onayı
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _kvkkOnay,
                                  activeColor: _primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _kvkkOnay = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _sozlesmeGoster('KVKK Aydınlatma Metni');
                                  },
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 13,
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
                                                ? _primaryColor
                                                : Colors.blue,
                                            fontWeight: FontWeight.bold,
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

                          const SizedBox(height: 30),

                          // Üye Ol Butonu
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed:
                              (_formDoluMu() && !_isLoading)
                                  ? _handleSignup
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryColor,
                                disabledBackgroundColor: Colors.grey.shade400,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                shadowColor: _primaryColor.withAlpha(100),
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
                                "Üye Ol",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Dialog Helper
  void _sozlesmeGoster(String baslik) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(baslik),
        content: SingleChildScrollView(
          child: Text('Buraya $baslik içeriği gelecek...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  // Şifre gereksinimi gösterimi (Görsel iyileştirme)
  Widget _sifreGereksinimiItem(String text, bool tamamlandi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            tamamlandi ? Icons.check_circle : Icons.circle_outlined,
            size: 14,
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
      ),
    );
  }
}