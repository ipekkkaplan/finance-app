import 'package:flutter/material.dart';

import '../../core/theme/color_scheme.dart';
import '../../models/recommendation_model.dart';
import '../../services/data_service.dart';
import '../../services/recommendations_service.dart';
import '../../widgets/empty_state.dart';
import '../sectors/company_detail_screen.dart';

/// Hisse Alım Önerileri ekranı.
///
/// Değerleme + temel analiz + risk raporu birleştirilerek skor üretilir.
/// Kategori filtreleriyle değer, temettü, düşük risk odaklı seçenekler sunulur.
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final RecommendationsService _service = RecommendationsService();
  RecommendationCategory _category = RecommendationCategory.all;

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
          'Hisse Önerileri',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Column(
        children: [
          _buildHeaderBanner(),
          _buildFilterChips(),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<RecommendationModel>>(
              future: _service.getTopRecommendations(
                limit: 15,
                category: _category,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: EmptyState.error(),
                  );
                }
                final recs = snapshot.data ?? [];
                if (recs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: 'Bu kategoride öneri yok',
                      subtitle: 'Farklı bir filtre seçmeyi deneyin.',
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: recs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _buildRecommendationCard(recs[i], i + 1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: isDark ? 0.3 : 0.12),
            primary.withValues(alpha: isDark ? 0.15 : 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.lightbulb, color: primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Veri tabanlı yatırım önerileri',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Değerleme + temel analiz + risk skoruyla sıralanır.',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: RecommendationCategory.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = RecommendationCategory.values[i];
          return _filterChip(cat);
        },
      ),
    );
  }

  Widget _filterChip(RecommendationCategory cat) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final selected = _category == cat;

    return GestureDetector(
      onTap: () => setState(() => _category = cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? primary
                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
          ),
        ),
        child: Center(
          child: Text(
            cat.label,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.grey[400] : Colors.grey[700]),
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(RecommendationModel r, int rank) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.withValues(alpha: 0.25);

    return GestureDetector(
      onTap: () => _openStockDetail(r),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.hisseKodu,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        r.sirketIsmi,
                        style: TextStyle(color: subTextColor, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Skor',
                      style: TextStyle(color: subTextColor, fontSize: 10),
                    ),
                    Text(
                      '${r.scorePercent}',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Skor barı
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: r.totalScore,
                backgroundColor: primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(primary),
                minHeight: 5,
              ),
            ),
            const SizedBox(height: 10),
            // Sebepler
            ...r.reasons.map((reason) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle,
                          size: 12, color: AppColors.profitLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          reason,
                          style: TextStyle(
                            color: subTextColor,
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            if (r.potentialReturn != null && r.potentialReturn! > 0) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.profitLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Potansiyel: %${r.potentialReturn!.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: AppColors.profitLight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openStockDetail(RecommendationModel r) async {
    final dataService = DataService();
    final stocks = await dataService.getStocksBySector(r.sektor);
    if (stocks.isEmpty || !mounted) return;

    final index = stocks.indexWhere((x) => x.hisseKodu == r.hisseKodu);
    if (index < 0) return;

    final sectors = await dataService.loadSectorData();
    double dailyChange = 0;
    for (final sector in sectors) {
      if (sector.name == r.sektor) {
        dailyChange = sector.dailyChange;
        break;
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyDetailScreen(
          sectorName: r.sektor,
          companies: stocks,
          initialIndex: index,
          dailyChange: dailyChange,
        ),
      ),
    );
  }
}
