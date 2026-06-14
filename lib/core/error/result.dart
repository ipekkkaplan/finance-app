// core/error/result.dart

/// Uygulama genelinde anlamlı hata tipleri.
///
/// Ham `Exception`/`dynamic` yerine; her hata kullanıcıya gösterilebilir bir
/// [message] taşır. `sealed` olduğu için `switch` ile eksiksiz ele alınır.
sealed class AppFailure {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

/// Ağ/bağlantı kaynaklı hata.
class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = 'Bağlantı hatası. Lütfen tekrar deneyin.',
  ]);
}

/// Veri okuma/ayrıştırma hatası (JSON, parse vb.).
class DataFailure extends AppFailure {
  const DataFailure([super.message = 'Veri yüklenemedi.']);
}

/// Kimlik/oturum hatası.
class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

/// Sınıflandırılamayan hata.
class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Beklenmeyen bir hata oluştu.']);
}

/// Başarılı veriyi [Ok] veya hatayı [Err] olarak taşıyan tip.
///
/// İstisna fırlatmak yerine hatayı bir DEĞER olarak döndürür; böylece çağıran
/// tarafı hatayı ele almaya zorlanır (sessizce yutulmaz). `sealed` olduğu için
/// `switch (result) { case Ok(): ... case Err(): ... }` eksiksiz olur.
sealed class Result<T> {
  const Result();

  /// Kısa kullanım: iki dala da fonksiyon ver, sonucu döndür.
  R when<R>({
    required R Function(T data) ok,
    required R Function(AppFailure failure) err,
  });

  bool get isOk => this is Ok<T>;
  bool get isErr => this is Err<T>;
}

class Ok<T> extends Result<T> {
  const Ok(this.data);
  final T data;

  @override
  R when<R>({
    required R Function(T data) ok,
    required R Function(AppFailure failure) err,
  }) =>
      ok(data);
}

class Err<T> extends Result<T> {
  const Err(this.failure);
  final AppFailure failure;

  @override
  R when<R>({
    required R Function(T data) ok,
    required R Function(AppFailure failure) err,
  }) =>
      err(failure);
}
