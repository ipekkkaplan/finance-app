import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/models/valuation_model.dart';

void main() {
  final sample = ValuationModel(
    hisseKodu: 'ASELS',
    sektor: 'Savunma',
    hisseSkor: 80,
    sektorSkor: 70,
    finalSkor: 75,
    etiket: 'AL',
  );

  group('ValuationModel', () {
    test('fromJson alanları doğru çözer', () {
      final m = ValuationModel.fromJson({
        'HisseKodu': 'ASELS',
        'Sektor': 'Savunma',
        'Hisse_Skor': 80,
        'Sektor_Skor': 70,
        'Final_Skor': 75,
        'Etiket': 'AL',
      });
      expect(m, sample);
    });

    test('fromJson eksik alanlarda güvenli varsayılan verir', () {
      final m = ValuationModel.fromJson({});
      expect(m.hisseKodu, '');
      expect(m.finalSkor, 0.0);
      expect(m.etiket, 'Bilinmiyor');
    });

    test('toJson → fromJson round-trip aynı nesneyi verir', () {
      final round = ValuationModel.fromJson(sample.toJson());
      expect(round, sample);
    });

    test('copyWith yalnızca verilen alanı değiştirir', () {
      final c = sample.copyWith(etiket: 'SAT');
      expect(c.etiket, 'SAT');
      expect(c.hisseKodu, 'ASELS');
      expect(c, isNot(sample));
    });

    test('değer eşitliği ve hashCode tutarlı', () {
      expect(sample, sample.copyWith());
      expect(sample.hashCode, sample.copyWith().hashCode);
    });
  });
}
