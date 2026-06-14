// screens/portfolio/portfolio_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/color_scheme.dart';
import '../../providers/auth_provider.dart';
import '../../core/di/locator.dart';

// ── Tema sabitleri ────────────────────────────────────────────────
const _kBgTop = AppColors.bgGradientTop;
const _kBgMid = AppColors.bgGradientMid;
const _kBgBot = AppColors.bgGradientBot;
const _kTeal = AppColors.accentTeal;
const _kCard = AppColors.darkCard;
const _kCardInner = AppColors.darkCardInner;
const _kGlassBorder = AppColors.glassBorder;
const _kProfit = AppColors.profitDark;

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late Stream<DocumentSnapshot> _portfolioStream;
  double _totalBalance = 250000.0;
  int touchedIndex = -1;

  final currencyFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  final Color _primaryYellow = const Color(0xFFFFC107);
  final Color _primaryPurple = const Color(0xFF9C27B0);

  @override
  void initState() {
    super.initState();
    final uid = context.read<AuthProvider>().uid;
    _portfolioStream = locator.portfolio.watch(uid);
  }

  void _showEditBalanceDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(
      text: _totalBalance.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? _kCardInner : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    "Toplam Varlığını Gir",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: "0",
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white12 : Colors.grey.shade200,
                      ),
                      suffixText: "₺",
                      suffixStyle: const TextStyle(
                        color: _kTeal,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _quickChip(ctx, "100.000", controller),
                      const SizedBox(width: 8),
                      _quickChip(ctx, "250.000", controller),
                      const SizedBox(width: 8),
                      _quickChip(ctx, "500.000", controller),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () async {
                      final clean = controller.text.replaceAll(',', '.');
                      final newVal = double.tryParse(clean);
                      Navigator.pop(ctx);
                      if (newVal != null && newVal >= 0) {
                        try {
                          final uid = context.read<AuthProvider>().uid;
                          await locator.portfolio
                              .updateTotalBalance(uid, newVal);
                        } catch (e) {
                          debugPrint("Bakiye kaydedilirken hata: $e");
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _kTeal.withValues(alpha: isDark ? 0.15 : 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _kTeal.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Bakiyeyi Güncelle",
                          style: TextStyle(
                            color: _kTeal,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
    );
  }

  Widget _quickChip(
    BuildContext context,
    String value,
    TextEditingController ctrl,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        ctrl.text = value.replaceAll('.', '');
        ctrl.selection = TextSelection.fromPosition(
          TextPosition(offset: ctrl.text.length),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? _kCard : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? _kGlassBorder : Colors.grey.shade300,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey.shade800,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color? _getKnownSectorColor(String? sector) {
    switch (sector?.trim().toLowerCase()) {
      case 'teknoloji':
        return _kTeal;
      case 'enerji':
        return _primaryYellow;
      case 'bankacılık':
        return _kProfit;
      case 'havacılık':
        return _primaryPurple;
      case 'sanayi':
        return Colors.orange;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF102C57);
    final subTextColor = isDark ? Colors.white54 : Colors.grey.shade600;

    final body = StreamBuilder<DocumentSnapshot>(
      stream: _portfolioStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _kTeal));
        }

        Map<String, dynamic> data = {};
        List portfolio = [];
        if (snapshot.hasData && snapshot.data!.exists) {
          data = snapshot.data!.data() as Map<String, dynamic>;
          portfolio = data['recommendedPortfolio'] ?? [];
          if (data.containsKey('totalBalance')) {
            _totalBalance =
                double.tryParse(data['totalBalance'].toString()) ?? 250000.0;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Başlık ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Portföyüm",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kişiselleştirilmiş analiz",
                        style: TextStyle(color: subTextColor, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _kTeal.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          isDark
                              ? Border.all(
                                color: _kTeal.withValues(alpha: 0.25),
                              )
                              : null,
                    ),
                    child: const Icon(
                      Icons.pie_chart_rounded,
                      color: _kTeal,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Toplam Bakiye Kartı ──────────────────────────────
              _buildBalanceCard(isDark, textColor, subTextColor),
              const SizedBox(height: 24),

              // ── İçerik ─────────────────────────────────────────
              if (portfolio.isEmpty)
                _buildNoDataPlaceholder(isDark, subTextColor)
              else ...[
                _buildSectorChart(portfolio, isDark, textColor, subTextColor),
                const SizedBox(height: 24),
                _buildComparisonChart(portfolio, isDark, textColor),
              ],
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );

    return Scaffold(
      backgroundColor: isDark ? _kBgTop : const Color(0xFFF5F5F5),
      body:
          isDark
              ? Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_kBgTop, _kBgMid, _kBgBot],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  SafeArea(child: body),
                ],
              )
              : SafeArea(child: body),
    );
  }

  // ── Bakiye Kartı ─────────────────────────────────────────────────
  Widget _buildBalanceCard(bool isDark, Color textColor, Color subTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? _kCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? _kTeal.withValues(alpha: 0.20) : Colors.grey.shade200,
        ),
        boxShadow:
            isDark
                ? [
                  BoxShadow(
                    color: _kTeal.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: _kTeal,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                "Toplam Değer",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showEditBalanceDialog(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  currencyFormatter.format(_totalBalance),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: subTextColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _kTeal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kTeal.withValues(alpha: 0.20)),
            ),
            child: const Text(
              "Planladığınız tutarı dokunarak giriniz",
              style: TextStyle(color: _kTeal, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sektör Pasta Grafiği ─────────────────────────────────────────
  Widget _buildSectorChart(
    List portfolio,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    final Map<String, double> amountMap = {};
    final Map<String, String> sectorMap = {};
    final fallback = AppColors.chartPalette;

    for (var item in portfolio) {
      final stockName = item['Hisse']?.toString().trim() ?? 'Bilinmeyen';
      final sector = item['Sektor']?.toString().trim() ?? '';
      final weight =
          double.tryParse(item['Onerilen_Agirlik'].toString()) ?? 0.0;
      final amount = (_totalBalance * weight) / 100;
      amountMap[stockName] = (amountMap[stockName] ?? 0) + amount;
      sectorMap[stockName] = sector;
    }

    final sorted =
        amountMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _kCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? _kGlassBorder : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: _kTeal,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                "Varlık Dağılımı",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse?.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex =
                              pieTouchResponse!
                                  .touchedSection!
                                  .touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: List.generate(sorted.length, (i) {
                      final isTouched = i == touchedIndex;
                      final entry = sorted[i];
                      final sliceColor =
                          _getKnownSectorColor(sectorMap[entry.key]) ??
                          fallback[i % fallback.length];
                      final pct = (entry.value / _totalBalance) * 100;
                      return PieChartSectionData(
                        color: sliceColor,
                        value: entry.value,
                        title: '%${pct.toStringAsFixed(0)}',
                        radius: isTouched ? 60.0 : 50.0,
                        titleStyle: TextStyle(
                          fontSize: isTouched ? 18 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        sorted.length.toString(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Hisse",
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ...sorted.asMap().entries.map((e) {
            final idx = e.key;
            final data = e.value;
            final legendColor =
                _getKnownSectorColor(sectorMap[data.key]) ??
                fallback[idx % fallback.length];
            final pct = (data.value / _totalBalance) * 100;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: legendColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    data.key,
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormatter.format(data.value),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "%${pct.toStringAsFixed(1)}",
                        style: TextStyle(color: subTextColor, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Performans Bar Grafiği ────────────────────────────────────────
  Widget _buildComparisonChart(List portfolio, bool isDark, Color textColor) {
    final Map<String, double> sectorVals = {};
    for (var item in portfolio) {
      final sector = item['Sektor']?.toString().trim() ?? 'Diğer';
      final weight =
          double.tryParse(item['Onerilen_Agirlik'].toString()) ?? 0.0;
      final perf = double.tryParse(item['Yillik_Getiri'].toString()) ?? 50.0;
      sectorVals[sector] = (sectorVals[sector] ?? 0) + (weight * perf) / 100;
    }
    final labels = sectorVals.keys.toList();
    final gridColor =
        isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05);
    final labelColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _kCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? _kGlassBorder : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: _kTeal,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    "Performans Analizi",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.insights, color: _kTeal, size: 20),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 40,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine:
                      (_) => FlLine(
                        color: gridColor,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                  getDrawingVerticalLine:
                      (_) => FlLine(
                        color: gridColor,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, meta) {
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              labels[i],
                              style: TextStyle(
                                color: labelColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 10,
                      getTitlesWidget:
                          (v, meta) => SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              v.toInt().toString(),
                              style: TextStyle(
                                color: labelColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: labelColor.withValues(alpha: 0.2),
                    ),
                    left: BorderSide(color: labelColor.withValues(alpha: 0.2)),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? _kCardInner : Colors.white,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    tooltipRoundedRadius: 8,
                    tooltipBorder: BorderSide(
                      color: isDark ? _kGlassBorder : Colors.grey.shade200,
                    ),
                    getTooltipItem:
                        (group, gi, rod, ri) => BarTooltipItem(
                          "Portföy\n",
                          TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: "${rod.toY.round()}",
                              style: TextStyle(
                                color: rod.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
                barGroups: List.generate(
                  labels.length,
                  (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: sectorVals[labels[i]] ?? 0,
                        color: _kTeal,
                        width: 24,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 40,
                          color:
                              isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.grey.withValues(alpha: 0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: _kTeal,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Portföyüm",
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataPlaceholder(bool isDark, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark ? _kCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? _kGlassBorder : Colors.grey.shade200,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _kTeal.withValues(alpha: 0.10),
                shape: BoxShape.circle,
                border: Border.all(color: _kTeal.withValues(alpha: 0.20)),
              ),
              child: const Icon(
                Icons.analytics_outlined,
                size: 40,
                color: _kTeal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Analiz verisi bulunamadı",
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Profilinizden testi tamamlayın.",
              textAlign: TextAlign.center,
              style: TextStyle(color: subTextColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
