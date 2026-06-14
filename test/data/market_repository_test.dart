import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/data/repositories/market_repository.dart';
import 'package:finance_app/services/data_service.dart';
import 'package:finance_app/models/valuation_model.dart';

/// Sahte veri kaynağı: gerçek JSON/asset yüklemeden, kontrollü veri döndürür.
/// Repository'nin enjekte edilen kaynağa delege ettiğini (DI seam) kanıtlar.
class _FakeDataService extends DataService {
  @override
  Future<List<ValuationModel>> loadValuationData() async => [
        ValuationModel(
          hisseKodu: 'TEST',
          sektor: 'Teknoloji',
          hisseSkor: 1,
          sektorSkor: 2,
          finalSkor: 3,
          etiket: 'AL',
        ),
      ];
}

void main() {
  group('MarketRepository', () {
    test('enjekte edilen veri kaynağına delege eder (DI seam)', () async {
      final repo = MarketRepository(_FakeDataService());

      final result = await repo.loadValuationData();

      expect(result, hasLength(1));
      expect(result.first.hisseKodu, 'TEST');
      expect(result.first.finalSkor, 3.0);
    });
  });
}
