import '../models/sentiment_model.dart';

/// Sosyal medya / haber sentiment'ını simüle eden servis.
///
/// Gerçek Twitter/X veya haber API entegrasyonu yok (ücretli + kapsam dışı).
/// Sunumlarda "Bu veriler demo amaçlı simüle edilmiştir" bilgisi gösterilir.
class SentimentService {
  /// Hisse koduna deterministik olarak bağlı (aynı kod → aynı skor).
  /// Böylece ekran her açıldığında sentiment'lar tutarlı kalır.
  SentimentModel getSentimentFor(String hisseKodu) {
    final seed = _stableHash(hisseKodu);
    // -1.0 ile +1.0 arasına normalize et
    final raw = (seed % 2000) / 1000.0 - 1.0;
    // Hafif pozitife kaydır (demo için piyasa genelde pozitif görünsün)
    final score = (raw * 0.85 + 0.1).clamp(-1.0, 1.0);

    SentimentType type;
    if (score > 0.2) {
      type = SentimentType.positive;
    } else if (score < -0.2) {
      type = SentimentType.negative;
    } else {
      type = SentimentType.neutral;
    }

    return SentimentModel(hisseKodu: hisseKodu, score: score, type: type);
  }

  /// Birden fazla hisse için sentiment listesi (score'a göre sıralı, pozitif üstte).
  List<SentimentModel> getSentimentsFor(List<String> hisseKodlari) {
    final list = hisseKodlari.map(getSentimentFor).toList();
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  /// Pazar geneli (giriş verilen hisselerin ortalaması).
  SentimentModel getMarketOverall(List<String> hisseKodlari) {
    if (hisseKodlari.isEmpty) {
      return const SentimentModel(
        hisseKodu: 'MARKET',
        score: 0,
        type: SentimentType.neutral,
      );
    }
    final sentiments = getSentimentsFor(hisseKodlari);
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

  /// Sabit (mock) haber akışı. Her uygulama açılışında aynı haberler görünür.
  List<NewsItem> getMockNewsFeed() {
    return const [
      NewsItem(
        title: 'THYAO 3. çeyrekte beklenti üzeri net kâr açıkladı',
        source: 'BloombergHT',
        sentiment: SentimentType.positive,
        hisseKodu: 'THYAO',
        timeAgo: Duration(minutes: 15),
      ),
      NewsItem(
        title: 'ASELS yeni savunma sözleşmesi imzaladı',
        source: 'Foreks',
        sentiment: SentimentType.positive,
        hisseKodu: 'ASELS',
        timeAgo: Duration(hours: 1),
      ),
      NewsItem(
        title: 'GARAN analisti: Kredi büyümesi ivme kaybetti',
        source: 'Reuters TR',
        sentiment: SentimentType.negative,
        hisseKodu: 'GARAN',
        timeAgo: Duration(hours: 2),
      ),
      NewsItem(
        title: 'SISE kapasite artırımı yatırım programı onaylandı',
        source: 'KAP',
        sentiment: SentimentType.positive,
        hisseKodu: 'SISE',
        timeAgo: Duration(hours: 3),
      ),
      NewsItem(
        title: 'AKBNK hisseleri temettü sonrası zayıf seyrediyor',
        source: 'Finansgündem',
        sentiment: SentimentType.neutral,
        hisseKodu: 'AKBNK',
        timeAgo: Duration(hours: 4),
      ),
      NewsItem(
        title: 'TUPRS rafineri marjları baskı altında',
        source: 'BloombergHT',
        sentiment: SentimentType.negative,
        hisseKodu: 'TUPRS',
        timeAgo: Duration(hours: 5),
      ),
      NewsItem(
        title: 'EREGL çelik fiyatları toparlanmaya başladı',
        source: 'Foreks',
        sentiment: SentimentType.positive,
        hisseKodu: 'EREGL',
        timeAgo: Duration(hours: 6),
      ),
      NewsItem(
        title: 'BIMAS gıda perakende büyümesi yavaşladı',
        source: 'Reuters TR',
        sentiment: SentimentType.neutral,
        hisseKodu: 'BIMAS',
        timeAgo: Duration(hours: 8),
      ),
      NewsItem(
        title: 'KCHOL holding kârı ilk yarıda yüzde 40 arttı',
        source: 'KAP',
        sentiment: SentimentType.positive,
        hisseKodu: 'KCHOL',
        timeAgo: Duration(hours: 10),
      ),
      NewsItem(
        title: 'FROTO otomotiv satışlarında yavaşlama sinyali',
        source: 'Finansgündem',
        sentiment: SentimentType.negative,
        hisseKodu: 'FROTO',
        timeAgo: Duration(hours: 12),
      ),
      NewsItem(
        title: 'TAVHL havacılık trafiği rekor seviyede',
        source: 'BloombergHT',
        sentiment: SentimentType.positive,
        hisseKodu: 'TAVHL',
        timeAgo: Duration(hours: 14),
      ),
      NewsItem(
        title: 'PETKM petrokimya marjları dalgalı',
        source: 'Foreks',
        sentiment: SentimentType.neutral,
        hisseKodu: 'PETKM',
        timeAgo: Duration(hours: 18),
      ),
    ];
  }

  /// Basit deterministik hash (string → pozitif int).
  int _stableHash(String s) {
    int hash = 0;
    for (final code in s.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return hash;
  }
}
