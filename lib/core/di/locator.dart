// core/di/locator.dart
import '../../services/data_service.dart';
import '../../services/algo_trade_service.dart';
import '../../services/sentiment_service.dart';
import '../../data/repositories/market_repository.dart';
import '../../data/repositories/sentiment_repository.dart';
import '../../data/repositories/algo_trade_repository.dart';
import '../../data/repositories/portfolio_repository.dart';

/// Çok hafif servis konumlandırıcı (Service Locator).
///
/// Servisler ve repository'ler tek yerden, tekil (singleton) olarak sağlanır.
/// Önceden ekranlar `DataService()` gibi bağımlılıklarını doğrudan `new` ile
/// yaratıyordu; artık `locator.market`, `locator.algoTrade` üzerinden alınır.
/// Bu sayede bağımlılık grafiği tek yerde görünür ve test edilebilir olur.
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  // ── Servisler (veri kaynağı katmanı) ──────────────────────
  final DataService _dataService = DataService();
  final AlgoTradeService _algoTradeService = AlgoTradeService.instance;
  final SentimentService _sentimentService = SentimentService();

  // ── Repository'ler (UI'ın konuştuğu katman) ───────────────
  late final MarketRepository market = MarketRepository(_dataService);
  late final SentimentRepository sentiment =
      SentimentRepository(_sentimentService);
  late final AlgoTradeRepository algoTrade =
      AlgoTradeRepository(_algoTradeService);
  late final PortfolioRepository portfolio = PortfolioRepository();
}

/// Kısa global erişim: `locator.market.loadSectorData()` gibi.
final locator = ServiceLocator.instance;
