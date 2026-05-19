/// Sentiment tür etiketi.
enum SentimentType {
  positive, // Pozitif
  neutral,  // Nötr
  negative, // Negatif
}

extension SentimentTypeX on SentimentType {
  String get label {
    switch (this) {
      case SentimentType.positive:
        return 'Pozitif';
      case SentimentType.neutral:
        return 'Nötr';
      case SentimentType.negative:
        return 'Negatif';
    }
  }
}

/// Bir hisse veya genel piyasa için sentiment skoru.
/// score: -1.0 ile +1.0 arasında (negatiften pozitife).
class SentimentModel {
  final String hisseKodu;
  final double score;
  final SentimentType type;

  const SentimentModel({
    required this.hisseKodu,
    required this.score,
    required this.type,
  });

  /// Pozitif/nötr/negatif dağılımı (0-100 arası yüzde).
  int get percent => ((score + 1) / 2 * 100).round().clamp(0, 100);
}

/// Sosyal medya / haber akışında gösterilecek post öğesi.
class NewsItem {
  final String title;
  final String source;
  final SentimentType sentiment;
  final String hisseKodu;
  final Duration timeAgo;

  /// Karta tıklandığında bottom sheet'te gösterilecek tam post metni.
  final String fullText;

  /// Sentimentin neden bu polariteye atandığını açıklayan kısa not.
  final String reason;

  const NewsItem({
    required this.title,
    required this.source,
    required this.sentiment,
    required this.hisseKodu,
    required this.timeAgo,
    this.fullText = '',
    this.reason = '',
  });
}
