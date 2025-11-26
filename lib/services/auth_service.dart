import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }

  bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty && _auth != null;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    DateTime? birthDate,
  }) async {
    if (!isFirebaseAvailable || _auth == null) {
      return {
        'success': false,
        'message':
            'Firebase yapılandırması eksik. flutterfire configure komutunu çalıştır.',
      };
    }

    try {
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName('$firstName $lastName');
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
        default:
          errorMessage = 'Kayıt işlemi başarısız: ${e.message}';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Beklenmeyen hata: $e'};
    }
  }

  Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
  }) async {
    if (!isFirebaseAvailable || _auth == null) {
      return {'success': false, 'message': 'Firebase yapılandırması eksik.'};
    }

    try {
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

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
          errorMessage = 'Bu email ile kayıtlı kullanıcı yok.';
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
              'Çok fazla başarısız deneme. Lütfen daha sonra tekrar deneyin.';
          break;
        default:
          errorMessage = 'Giriş işlemi başarısız: ${e.message}';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Beklenmeyen hata: $e'};
    }
  }

  Future<Map<String, dynamic>> resendVerificationEmail() async {
    if (!isFirebaseAvailable || _auth == null) {
      return {'success': false, 'message': 'Firebase yapılandırması eksik.'};
    }

    try {
      final user = _auth!.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return {
          'success': true,
          'message': 'Email doğrulama maili yeniden gönderildi.',
        };
      }
      return {
        'success': false,
        'message': 'Kullanıcı yok veya email zaten doğrulanmış.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Email gönderilirken hata oluştu: $e',
      };
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    if (!isFirebaseAvailable || _auth == null) {
      return {'success': false, 'message': 'Firebase yapılandırması eksik.'};
    }

    try {
      await _auth!.sendPasswordResetEmail(email: email);
      return {'success': true, 'message': 'Şifre sıfırlama maili gönderildi.'};
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
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': 'Beklenmeyen hata: $e'};
    }
  }

  Future<void> signOut() async {
    if (isFirebaseAvailable && _auth != null) {
      await _auth!.signOut();
    }
  }

  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (!isFirebaseAvailable || _auth == null) {
      return {'success': false, 'message': 'Firebase yapılandırması eksik.'};
    }

    try {
      final user = _auth!.currentUser;

      if (user == null || user.email == null) {
        return {'success': false, 'message': 'Kullanıcı oturumu bulunamadı.'};
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return {'success': true};
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'Eski şifre yanlış.';
          break;
        case 'weak-password':
          message = 'Yeni şifre çok zayıf.';
          break;
        case 'requires-recent-login':
          message = 'Lütfen tekrar giriş yapıp yeniden deneyin.';
          break;
        default:
          message = e.message ?? 'Şifre güncellenemedi.';
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Beklenmeyen bir hata oluştu: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAccount({required String password}) async {
    if (!isFirebaseAvailable || _auth == null) {
      return {'success': false, 'message': 'Firebase yapılandırması eksik.'};
    }

    try {
      final user = _auth!.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'Kullanıcı oturumu açık değil.'};
      }

      // Reauthenticate
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(cred);

      // Hesabı sil
      await user.delete();

      return {'success': true, 'message': 'Hesap başarıyla silindi.'};
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return {'success': false, 'message': 'Şifre yanlış.'};
      }
      if (e.code == 'requires-recent-login') {
        return {
          'success': false,
          'message':
              'Güvenlik nedeniyle tekrar giriş yapmanız gerekiyor. Tekrar giriş yapın.',
        };
      }
      return {'success': false, 'message': e.message ?? 'Hesap silinemedi.'};
    } catch (e) {
      return {'success': false, 'message': 'Hata oluştu: $e'};
    }
  }
}
