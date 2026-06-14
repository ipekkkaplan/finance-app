import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/core/error/result.dart';

void main() {
  group('Result', () {
    test('Ok veriyi taşır ve when() ok dalını çağırır', () {
      const Result<int> r = Ok(42);
      expect(r.isOk, isTrue);
      expect(r.isErr, isFalse);
      final out = r.when(ok: (d) => 'v=$d', err: (f) => 'e=${f.message}');
      expect(out, 'v=42');
    });

    test('Err hatayı taşır ve when() err dalını çağırır', () {
      const Result<int> r = Err(DataFailure('yok'));
      expect(r.isErr, isTrue);
      final out = r.when(ok: (d) => 'v=$d', err: (f) => 'e=${f.message}');
      expect(out, 'e=yok');
    });
  });

  group('AppFailure', () {
    test('alt tipler anlamlı varsayılan mesaj taşır', () {
      expect(const NetworkFailure().message, isNotEmpty);
      expect(const DataFailure().message, 'Veri yüklenemedi.');
      expect(const UnknownFailure().message, isNotEmpty);
      expect(const AuthFailure('parola hatalı').message, 'parola hatalı');
    });
  });
}
