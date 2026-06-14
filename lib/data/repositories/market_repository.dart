// data/repositories/market_repository.dart
import '../../models/sector_model.dart';
import '../../models/valuation_model.dart';
import '../../models/sector_trend_model.dart';
import '../../models/stock_model.dart';
import '../../services/data_service.dart';

/// Piyasa/analiz verisi için repository katmanı.
///
/// UI doğrudan [DataService]'e (veri kaynağı) bağlanmaz; bu soyutlamaya
/// bağlanır. Böylece kaynak değişse (JSON → API) ekranlar etkilenmez ve
/// testte [DataService] yerine sahte (fake) bir kaynak enjekte edilebilir.
class MarketRepository {
  MarketRepository(this._dataSource);

  final DataService _dataSource;

  Future<List<SectorModel>> loadSectorData() => _dataSource.loadSectorData();

  Future<List<ValuationModel>> loadValuationData() =>
      _dataSource.loadValuationData();

  Future<List<SectorTrendModel>> getSectorTrends() =>
      _dataSource.getSectorTrends();

  Future<List<StockModel>> getStocksBySector(String sectorName) =>
      _dataSource.getStocksBySector(sectorName);

  /// Kullanıcı çıkışında cache'i temizler.
  void clearCache() => DataService.clearCache();
}
