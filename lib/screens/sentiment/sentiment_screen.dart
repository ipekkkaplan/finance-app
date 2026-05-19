import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/color_scheme.dart';
import '../../models/sentiment_model.dart';
import '../../services/sentiment_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/status_badge.dart';

/// Sosyal medya / forum sentiment analizi ekranı.
///
/// Veri kaynağı: finscope_veri_seti.json içindeki sosyal medya postları.
/// AL → pozitif, TUT → nötr, SAT → negatif olarak etiketlenmiştir.
class SentimentScreen extends StatefulWidget {
  const SentimentScreen({super.key});

  @override
  State<SentimentScreen> createState() => _SentimentScreenState();
}

class _SentimentScreenState extends State<SentimentScreen> {
  final SentimentService _service = SentimentService();

  late final Future<_SentimentViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_SentimentViewData> _load() async {
    final sentiments = await _service.getAllSentiments();
    final market = await _service.getMarketOverall();
    final news = await _service.getSocialMediaFeed();

    return _SentimentViewData(
      market: market,
      sentiments: sentiments,
      news: news,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Sosyal Sentiment',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: FutureBuilder<_SentimentViewData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: EmptyState.error(),
            );
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDisclaimer(),
              const SizedBox(height: 16),
              _buildMarketOverall(data.market, data.sentiments),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Sosyal Medya Akışı',
                icon: Icons.forum_outlined,
              ),
              _buildNewsFeed(data.news),
              const SizedBox(height: 24),
              const SectionHeader(
                title: 'Hisse Bazlı Sentiment',
                icon: Icons.list_alt,
              ),
              _buildStockSentimentList(data.sentiments),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDisclaimer() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber[800], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Sosyal medya post\'larından çıkarılmış sentiment etiketleri. Canlı Twitter/X API entegrasyonu sonraki sürümde.',
              style: TextStyle(
                color: isDark ? Colors.amber[300] : Colors.amber[900],
                fontSize: 11.5,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketOverall(SentimentModel market, List<SentimentModel> all) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.3);

    final positive = all.where((s) => s.type == SentimentType.positive).length;
    final neutral = all.where((s) => s.type == SentimentType.neutral).length;
    final negative = all.where((s) => s.type == SentimentType.negative).length;
    final total = (positive + neutral + negative).clamp(1, 1 << 31);
    final posPct = (positive / total * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pazar Genel Sentiment',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              StatusBadge.fromSentiment(market.type),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 28,
                      sections: [
                        if (positive > 0)
                          PieChartSectionData(
                            color: AppColors.profitLight,
                            value: positive.toDouble(),
                            title: '$positive',
                            radius: 28,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (neutral > 0)
                          PieChartSectionData(
                            color: const Color(0xFF78909C),
                            value: neutral.toDouble(),
                            title: '$neutral',
                            radius: 28,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (negative > 0)
                          PieChartSectionData(
                            color: AppColors.lossDark,
                            value: negative.toDouble(),
                            title: '$negative',
                            radius: 28,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '%$posPct Pozitif',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _legend(AppColors.profitLight, 'Pozitif', positive),
                      _legend(const Color(0xFF78909C), 'Nötr', neutral),
                      _legend(AppColors.lossDark, 'Negatif', negative),
                      const SizedBox(height: 6),
                      Text(
                        'Toplam $total hisse analiz edildi',
                        style: TextStyle(color: subTextColor, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label, int count) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $count',
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsFeed(List<NewsItem> news) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: news.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) => _newsCard(news[i]),
      ),
    );
  }

  Widget _newsCard(NewsItem item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.withValues(alpha: 0.25);

    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              StatusBadge.fromSentiment(item.sentiment, compact: true),
              const Spacer(),
              Text(
                item.hisseKodu,
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          Text(
            item.title,
            style: TextStyle(
              color: textColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              Icon(Icons.source, size: 11, color: subTextColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item.source,
                  style: TextStyle(color: subTextColor, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _formatAgo(item.timeAgo),
                style: TextStyle(color: subTextColor, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAgo(Duration d) {
    if (d.inMinutes < 60) return '${d.inMinutes}dk';
    if (d.inHours < 24) return '${d.inHours}sa';
    return '${d.inDays}g';
  }

  Widget _buildStockSentimentList(List<SentimentModel> sentiments) {
    // İlk 30 hisse
    final shown = sentiments.take(30).toList();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.withValues(alpha: 0.25);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          for (int i = 0; i < shown.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                color: borderColor,
                indent: 14,
                endIndent: 14,
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shown[i].hisseKodu,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    'Skor ${shown[i].score.toStringAsFixed(2)}',
                    style: TextStyle(color: subTextColor, fontSize: 11),
                  ),
                  const SizedBox(width: 10),
                  StatusBadge.fromSentiment(shown[i].type, compact: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SentimentViewData {
  final SentimentModel market;
  final List<SentimentModel> sentiments;
  final List<NewsItem> news;

  _SentimentViewData({
    required this.market,
    required this.sentiments,
    required this.news,
  });
}
