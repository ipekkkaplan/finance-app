import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/models/sentiment_model.dart';

void main() {
  group('SentimentModel', () {
    test('percent, -1..+1 skoru 0..100 yüzdeye çevirir', () {
      expect(
        const SentimentModel(hisseKodu: 'A', score: 1.0, type: SentimentType.positive).percent,
        100,
      );
      expect(
        const SentimentModel(hisseKodu: 'A', score: 0.0, type: SentimentType.neutral).percent,
        50,
      );
      expect(
        const SentimentModel(hisseKodu: 'A', score: -1.0, type: SentimentType.negative).percent,
        0,
      );
    });

    test('copyWith + değer eşitliği', () {
      const m = SentimentModel(hisseKodu: 'A', score: 0.5, type: SentimentType.positive);
      expect(m.copyWith(), m);
      expect(m.copyWith(score: -0.5).score, -0.5);
      expect(m.copyWith(score: -0.5), isNot(m));
    });
  });

  group('SentimentType', () {
    test('label Türkçe etiket döndürür', () {
      expect(SentimentType.positive.label, 'Pozitif');
      expect(SentimentType.neutral.label, 'Nötr');
      expect(SentimentType.negative.label, 'Negatif');
    });
  });
}
