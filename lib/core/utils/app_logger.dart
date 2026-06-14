// core/utils/app_logger.dart
import 'package:flutter/foundation.dart';

/// Uygulama genelinde tek tip loglama.
///
/// Önceden servislere dağılmış `debugPrint(...)` çağrılarının yerini alır.
/// Debug modda konsola yazar; release'de sessizdir. İleride tek noktadan
/// Crashlytics/Sentry gibi bir hedefe yönlendirilebilir.
class AppLogger {
  AppLogger._();

  /// Hata logu (yakalanan exception'lar için).
  static void error(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      final suffix = error != null ? ' → $error' : '';
      debugPrint('[ERROR] $message$suffix');
    }
  }

  /// Bilgilendirme logu.
  static void info(String message) {
    if (kDebugMode) debugPrint('[INFO] $message');
  }

  /// Geliştirme/teşhis logu.
  static void debug(String message) {
    if (kDebugMode) debugPrint('[DEBUG] $message');
  }
}
