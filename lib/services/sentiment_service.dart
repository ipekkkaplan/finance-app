import '../models/analyst_signal_model.dart';
import '../models/sentiment_model.dart';
import 'analyst_signals_service.dart';

/// Sosyal medya / forum sentiment analizi servisi.
///
/// Veri kaynağı: `assets/finscope_veri_seti.json` (sosyal medya postlarının
/// AL/SAT/TUT etiketli formu). AL → pozitif, TUT → nötr, SAT → negatif.
/// Aynı veri seti hem sinyaller ekranında hem sentiment ekranında kullanılır.
class SentimentService {
  final AnalystSignalsService _analyst = AnalystSignalsService.instance;

  /// AL içinde "güçlü/muazzam/tavan" geçenler daha yüksek pozitif skor alır.
  static const List<String> _strongMarkers = [
    'güçlü al',
    'çok güçlü',
    'muazzam',
    'tavan',
    'devasa',
  ];

  /// Tek bir hisse için sentiment (veri yoksa null).
  Future<SentimentModel?> getSentimentFor(String hisseKodu) async {
    final analyst = await _analyst.getFor(hisseKodu);
    if (analyst == null) return null;
    return _toSentiment(analyst);
  }

  /// Finscope veri setindeki tüm hisselerin sentiment'ları
  /// (skor sıralı: pozitif önce).
  Future<List<SentimentModel>> getAllSentiments() async {
    final all = await _analyst.loadAll();
    final list = all.values.map(_toSentiment).toList();
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  /// Pazar geneli sentiment (tüm hisselerin ortalaması).
  Future<SentimentModel> getMarketOverall() async {
    final sentiments = await getAllSentiments();
    if (sentiments.isEmpty) {
      return const SentimentModel(
        hisseKodu: 'MARKET',
        score: 0,
        type: SentimentType.neutral,
      );
    }
    final avg =
        sentiments.map((s) => s.score).reduce((a, b) => a + b) / sentiments.length;
    SentimentType type;
    if (avg > 0.2) {
      type = SentimentType.positive;
    } else if (avg < -0.2) {
      type = SentimentType.negative;
    } else {
      type = SentimentType.neutral;
    }
    return SentimentModel(hisseKodu: 'MARKET', score: avg, type: type);
  }

  /// Sosyal medya / haber akışı: orijinal post'lardan haber kartları üretir.
  /// En güçlü polariteye sahip ilk 12 post (uçtaki AL/SAT'lar) gösterilir.
  Future<List<NewsItem>> getSocialMediaFeed({int limit = 12}) async {
    final all = await _analyst.loadAll();
    final entries = all.values.toList();
    // Mutlak skora göre sırala: en uç (en ilginç) post'lar önce.
    entries.sort((a, b) {
      final aAbs = _scoreOf(a).abs();
      final bAbs = _scoreOf(b).abs();
      return bAbs.compareTo(aAbs);
    });
    return entries.take(limit).map(_toNewsItem).toList();
  }

  SentimentModel _toSentiment(AnalystSignalModel a) {
    return SentimentModel(
      hisseKodu: a.hisseKodu,
      score: _scoreOf(a),
      type: _typeOf(a),
    );
  }

  NewsItem _toNewsItem(AnalystSignalModel a) {
    // Orijinal metni özetle: ilk satır veya ilk 110 karakter.
    var text = a.orijinalMetin.split('\n').first.trim();
    if (text.length > 110) {
      text = '${text.substring(0, 110).trim()}…';
    }
    // Görsel çeşitlilik için deterministik "süre".
    final hours = (_stableHash(a.hisseKodu) % 47) + 1;
    return NewsItem(
      title: text.isEmpty ? a.gerekce : text,
      source: 'Sosyal Medya',
      sentiment: _typeOf(a),
      hisseKodu: a.hisseKodu,
      timeAgo: Duration(hours: hours),
    );
  }

  SentimentType _typeOf(AnalystSignalModel a) {
    switch (a.rawSinyal) {
      case 'AL':
        return SentimentType.positive;
      case 'SAT':
        return SentimentType.negative;
      case 'TUT':
      default:
        return SentimentType.neutral;
    }
  }

  double _scoreOf(AnalystSignalModel a) {
    switch (a.rawSinyal) {
      case 'AL':
        final combined = '${a.gerekce} ${a.orijinalMetin}'.toLowerCase();
        for (final m in _strongMarkers) {
          if (combined.contains(m)) return 0.85;
        }
        return 0.55;
      case 'SAT':
        return -0.65;
      case 'TUT':
      default:
        // Nötr için küçük variation: -0.10 ile +0.10 arası.
        final h = _stableHash(a.hisseKodu);
        return ((h % 200) / 1000.0) - 0.10;
    }
  }

  int _stableHash(String s) {
    int hash = 0;
    for (final code in s.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }
}
