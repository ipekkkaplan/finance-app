import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/models/stock_model.dart';

void main() {
  group('StockModel', () {
    test('fromJson eksik alanlarda 0/null güvenli varsayılan üretir', () {
      final m = StockModel.fromJson({});
      expect(m.sirketIsmi, '');
      expect(m.hacim, 0.0);
      expect(m.temettuVerimliligi, isNull);
    });

    test('fromJson int değerleri double\'a çevirir', () {
      final m = StockModel.fromJson({
        'HisseKodu': 'THYAO',
        'Hacim': 1000,
        'FK': 12,
      });
      expect(m.hisseKodu, 'THYAO');
      expect(m.hacim, 1000.0);
      expect(m.fk, 12.0);
    });

    test('copyWith + değer eşitliği', () {
      final m = StockModel.fromJson({'HisseKodu': 'THYAO'});
      expect(m.copyWith(), m);
      expect(m.copyWith(hisseKodu: 'XU100').hisseKodu, 'XU100');
      expect(m.copyWith(hisseKodu: 'XU100'), isNot(m));
    });
  });
}
