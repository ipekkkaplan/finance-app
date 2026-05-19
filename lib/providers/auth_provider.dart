import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Uygulama genelinde auth state'i tutan merkezi ChangeNotifier.
///
/// FirebaseAuth.authStateChanges() stream'ini dinler ve değişimde
/// dinleyici widget'ları otomatik olarak yeniden inşa eder.
///
/// Yalnızca state aynası olarak çalışır; giriş, kayıt, çıkış gibi
/// eylem metodları AuthService üzerinden çağrılmaya devam eder.
class AuthProvider extends ChangeNotifier {
  User? _user;
  late final StreamSubscription<User?> _sub;

  AuthProvider() {
    _user = FirebaseAuth.instance.currentUser;
    _sub = FirebaseAuth.instance.authStateChanges().listen((u) {
      _user = u;
      notifyListeners();
    });
  }

  /// Mevcut Firebase kullanıcısı (null ise giriş yok).
  User? get user => _user;

  /// Giriş yapılmış mı?
  bool get isLoggedIn => _user != null;

  /// Aktif kullanıcının UID'si (null güvenli).
  String? get uid => _user?.uid;

  /// Aktif kullanıcının e-postası.
  String? get email => _user?.email;

  /// E-posta doğrulanmış mı?
  bool get isEmailVerified => _user?.emailVerified ?? false;

  /// Kullanıcı bilgisini Firebase'den yeniden çeker
  /// (emailVerified durumu güncellendikten sonra çağrılır).
  Future<void> reload() async {
    await _user?.reload();
    _user = FirebaseAuth.instance.currentUser;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
