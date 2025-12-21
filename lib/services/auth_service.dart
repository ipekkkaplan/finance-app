import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  // Firebase Auth instance - null safety ile
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }

  // Firebase'in kullanılabilir olup olmadığını kontrol et
  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty && _auth != null;
    } catch (e) {
      return false;
    }
  }

  // Kullanıcı kayıt etme ve email doğrulama gönderme
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    DateTime? birthDate,
  }) async {
    // Firebase kontrolü
    if (!isFirebaseAvailable || _auth == null) {
      return {
        'success': false,
        'message': 'Firebase yapılandırması eksik. Lütfen Firebase yapılandırmasını tamamlayın.\n\nflutterfire configure komutunu çalıştırın.',
      };
    }

    try {
      // Kullanıcı oluştur
      UserCredential userCredential =
          await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı profilini güncelle
      await userCredential.user!.updateDisplayName('$firstName $lastName');

      // Email doğrulama gönder
      await userCredential.user!.sendEmailVerification();

      return {
        'success': true,
        'message': 'Kayıt başarılı! Email doğrulama gönderildi.',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Şifre çok zayıf.';
          break;
        case 'email-already-in-use':
          errorMessage = 'Bu email adresi zaten kullanılıyor.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz email adresi.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Bu işlem şu anda izin verilmiyor.';
          break;
        default:
          errorMessage = 'Kayıt işlemi başarısız: ${e.message}';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Beklenmeyen bir hata oluştu: $e',
      };
    }
  }

  // Kullanıcı girişi
  Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
  }) async {
    // Firebase kontrolü
    if (!isFirebaseAvailable || _auth == null) {
      return {
        'success': false,
        'message': 'Firebase yapılandırması eksik. Lütfen Firebase yapılandırmasını tamamlayın.\n\nflutterfire configure komutunu çalıştırın.',
      };
    }

    try {
      UserCredential userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Email doğrulanmış mı kontrol et
      if (!userCredential.user!.emailVerified) {
        return {
          'success': false,
          'message': 'Lütfen email adresinizi doğrulayın.',
          'emailNotVerified': true,
        };
      }

      return {
        'success': true,
        'message': 'Giriş başarılı!',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu email adresi ile kayıtlı kullanıcı bulunamadı.';
          break;
        case 'wrong-password':
          errorMessage = 'Şifre yanlış.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz email adresi.';
          break;
        case 'user-disabled':
          errorMessage = 'Bu kullanıcı hesabı devre dışı bırakılmış.';
          break;
        case 'too-many-requests':
          errorMessage =
              'Çok fazla başarısız giriş denemesi. Lütfen daha sonra tekrar deneyin.';
          break;
        default:
          errorMessage = 'Giriş işlemi başarısız: ${e.message}';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Beklenmeyen bir hata oluştu: $e',
      };
    }
  }

  // Email doğrulama maili yeniden gönder
  Future<Map<String, dynamic>> resendVerificationEmail() async {
    // Firebase kontrolü
    if (!isFirebaseAvailable || _auth == null) {
      return {
        'success': false,
        'message': 'Firebase yapılandırması eksik.',
      };
    }

    try {
      User? user = _auth!.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return {
          'success': true,
          'message': 'Email doğrulama maili yeniden gönderildi.',
        };
      }
      return {
        'success': false,
        'message': 'Kullanıcı bulunamadı veya email zaten doğrulanmış.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Email gönderilirken hata oluştu: $e',
      };
    }
  }

  // Şifre sıfırlama maili gönder
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    // Firebase kontrolü
    if (!isFirebaseAvailable || _auth == null) {
      return {
        'success': false,
        'message': 'Firebase yapılandırması eksik.',
      };
    }

    try {
      await _auth!.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Şifre sıfırlama maili gönderildi.',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Bu email adresi ile kayıtlı kullanıcı bulunamadı.';
          break;
        case 'invalid-email':
          errorMessage = 'Geçersiz email adresi.';
          break;
        default:
          errorMessage = 'Şifre sıfırlama maili gönderilemedi: ${e.message}';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Beklenmeyen bir hata oluştu: $e',
      };
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    if (isFirebaseAvailable && _auth != null) {
      await _auth!.signOut();
    }
  }

  // Mevcut kullanıcı
  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (e) {
      return null;
    }
  }
}

