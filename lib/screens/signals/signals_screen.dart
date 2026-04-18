import 'package:flutter/material.dart';

import '../../models/signal_model.dart';
import '../../services/data_service.dart';
import '../../services/signals_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../sectors/company_detail_screen.dart';

/// Al-Sat Sinyal Uyarıları ekranı.
///
/// Tüm hisseler için kural tabanlı sinyaller listelenir; filtre chip'leriyle
/// istenilen sinyal türü seçilebilir. Hisseye tıklayınca detay ekranı açılır.
class SignalsScreen extends StatefulWidget {
  const SignalsScreen({super.key});

  @override
  State<SignalsScreen> createState() => _SignalsScreenState();
}

class _SignalsScreenState extends State<SignalsScreen> {
  final SignalsService _service = SignalsService();
  late final Future<List<SignalModel>> _future;

  // null = Hepsi
  SignalType? _filter;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllSignals();
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
          'Al-Sat Sinyalleri',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: FutureBuilder<List<SignalModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: EmptyState.error(
                message: 'Sinyaller şu an oluşturulamadı.',
              ),
            );
          }
          final signals = snapshot.data!;
          final filtered = _filter == null
              ? signals
              : signals.where((s) => s.type == _filter).toList();

          return Column(
            children: [
              _buildSummaryBanner(signals),
              _buildFilterChips(),
              const SizedBox(height: 4),
              Expanded(
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: EmptyState(
                          icon: Icons.filter_alt_off_outlined,
                          title: 'Bu filtrede sinyal yok',
                          subtitle: 'Farklı bir sinyal türü seçin.',
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _buildSignalCard(filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryBanner(List<SignalModel> all) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    final strongBuy = all.where((s) => s.type == SignalType.strongBuy).length;
    final buy = all.where((s) => s.type == SignalType.buy).length;
    final count = strongBuy + buy;

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
            child: Icon(Icons.notifications_active, color: primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bugün $count yeni alım fırsatı',
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kural tabanlı sinyal motoru — temel analize dayalıdır.',
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
    final chips = <(String, SignalType?)>[
      ('Hepsi', null),
      ('GÜÇLÜ AL', SignalType.strongBuy),
      ('AL', SignalType.buy),
      ('BEKLE', SignalType.hold),
      ('SAT', SignalType.sell),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, type) = chips[i];
          return _filterChip(label, type);
        },
      ),
    );
  }

  Widget _filterChip(String label, SignalType? type) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final selected = _filter == type;

    return GestureDetector(
      onTap: () => setState(() => _filter = type),
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
            label,
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

  Widget _buildSignalCard(SignalModel s) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.withValues(alpha: 0.25);

    return GestureDetector(
      onTap: () => _openStockDetail(s),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.hisseKodu,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.sirketIsmi,
                        style: TextStyle(color: subTextColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.sektor,
                        style: TextStyle(color: subTextColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge.fromSignal(s.type),
                    const SizedBox(height: 6),
                    Text(
                      'Güven %${(s.confidence * 100).round()}',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 13, color: subTextColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      s.reason,
                      style: TextStyle(color: subTextColor, fontSize: 11.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openStockDetail(SignalModel s) async {
    final dataService = DataService();
    final stocks = await dataService.getStocksBySector(s.sektor);
    if (stocks.isEmpty || !mounted) return;

    final index = stocks.indexWhere((x) => x.hisseKodu == s.hisseKodu);
    if (index < 0) return;

    // Sektör dailyChange'ini bul (yoksa 0)
    final sectors = await dataService.loadSectorData();
    double dailyChange = 0;
    for (final sector in sectors) {
      if (sector.name == s.sektor) {
        dailyChange = sector.dailyChange;
        break;
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyDetailScreen(
          sectorName: s.sektor,
          companies: stocks,
          initialIndex: index,
          dailyChange: dailyChange,
        ),
      ),
    );
  }
}
