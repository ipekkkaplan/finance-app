// data/repositories/sentiment_repository.dart
import '../../models/sentiment_model.dart';
import '../../services/sentiment_service.dart';

/// Sentiment verisi için repository katmanı. UI [SentimentService] yerine
/// bu soyutlamaya bağlanır.
class SentimentRepository {
  SentimentRepository(this._service);

  final SentimentService _service;

  Future<List<SentimentModel>> getAllSentiments() =>
      _service.getAllSentiments();

  Future<SentimentModel> getMarketOverall() => _service.getMarketOverall();

  Future<List<NewsItem>> getSocialMediaFeed({int limit = 12}) =>
      _service.getSocialMediaFeed(limit: limit);

  Future<SentimentModel?> getSentimentFor(String hisseKodu) =>
      _service.getSentimentFor(hisseKodu);
}
