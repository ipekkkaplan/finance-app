import 'dart:math';

class TwoFactorService {
  String? _lastCode;
  DateTime? _generatedAt;
  int _failCount = 0;

  // 6 HANELİ KOD ÜRET
  Future<String> generateCode() async {
    final rand = Random();
    final code = (rand.nextInt(900000) + 100000).toString();

    _lastCode = code;
    _generatedAt = DateTime.now();
    _failCount = 0;

    print("📩 2FA CODE → $code");

    return code;
  }

  // **MAIL GÖNDERME YERİNE** konsola yazıyoruz
  Future<void> sendCode(String email, String code) async {
    print("📨 Kod $email adresine gönderildi → $code");
  }

  // 2FA DOĞRULAMA
  Future<Map<String, dynamic>> verifyCode(String entered) async {
    if (_lastCode == null) {
      return {"ok": false, "error": "Kod üretilmedi"};
    }

    // 5 dk süresi doldu mu?
    final now = DateTime.now();
    if (_generatedAt != null && now.difference(_generatedAt!).inMinutes >= 5) {
      return {"ok": false, "error": "Kodun süresi doldu"};
    }

    // 3 yanlış deneme limiti
    if (_failCount >= 3) {
      return {"ok": false, "error": "Çok fazla yanlış deneme yaptın"};
    }

    if (entered != _lastCode) {
      _failCount++;
      final left = 3 - _failCount;
      return {"ok": false, "error": "Kod yanlış ($left deneme kaldı)"};
    }

    // Başarılı
    return {"ok": true};
  }
}
