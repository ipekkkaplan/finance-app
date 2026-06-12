// screens/sectors/sectors_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/color_scheme.dart';
import '../../models/sector_model.dart';
import '../../models/sector_trend_model.dart';
import '../../services/data_service.dart';
import 'company_detail_screen.dart';

// ── Tema sabitleri ────────────────────────────────────────────────
const _kBgTop = Color(0xFF07111F);
const _kBgMid = Color(0xFF0C1B31);
const _kBgBot = Color(0xFF0F2040);
const _kTeal = Color(0xFF00C9A7);
const _kCard = Color(0xFF132040);
const _kCardInner = Color(0xFF0C1A30);
const _kGlassBorder = Color(0x18FFFFFF);
const _kProfit = Color(0xFF00E676);
const _kLoss = Color(0xFFEF5350);

class SectorsScreen extends StatefulWidget {
  const SectorsScreen({super.key});

  @override
  State<SectorsScreen> createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> {
  int _selectedFilterIndex = 0;

  final DataService _dataService = DataService();
  Future<List<SectorModel>>? _sectorsFuture;
  Future<List<SectorTrendModel>>? _trendsFuture;

  @override
  void initState() {
    super.initState();
    _sectorsFuture = _dataService.loadSectorData();
    _trendsFuture = _dataService.getSectorTrends();
  }

  List<SectorModel> getFilteredSectors(List<SectorModel> allSectors) {
    const double threshold = 8.0;
    switch (_selectedFilterIndex) {
      case 1:
        return allSectors.where((s) => s.sixMonthChange > threshold).toList();
      case 2:
        return allSectors
            .where((s) => s.sixMonthChange > 0 && s.sixMonthChange <= threshold)
            .toList();
      case 3:
        return allSectors.where((s) => s.sixMonthChange <= 0).toList();
      default:
        return allSectors;
    }
  }

  // ── Kart dekorasyonu ─────────────────────────────────────────────
  BoxDecoration _cardDeco(
    bool isDark, {
    double radius = 20,
    Color? borderColor,
  }) => BoxDecoration(
    color: isDark ? _kCard : Colors.white,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: borderColor ?? (isDark ? _kGlassBorder : Colors.grey.shade200),
      width: 1,
    ),
    boxShadow:
        isDark
            ? null
            : [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF102C57);
    final subTextColor = isDark ? Colors.white54 : Colors.grey.shade600;

    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Başlık ──────────────────────────────────────────────
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sektör Analizi",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "6 aylık piyasa performansı",
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
                          ? Border.all(color: _kTeal.withValues(alpha: 0.25))
                          : null,
                ),
                child: const Icon(Icons.filter_list, color: _kTeal, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Performans Grafiği ───────────────────────────────────
          FutureBuilder<List<SectorModel>>(
            future: _sectorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  decoration: _cardDeco(isDark),
                  child: const Center(
                    child: CircularProgressIndicator(color: _kTeal),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox();
              }
              return _buildHorizontalGraph(snapshot.data!, isDark, textColor);
            },
          ),
          const SizedBox(height: 16),

          // ── Trend Grafiği ────────────────────────────────────────
          FutureBuilder<List<SectorTrendModel>>(
            future: _trendsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 250,
                  decoration: _cardDeco(isDark),
                  child: const Center(
                    child: CircularProgressIndicator(color: _kTeal),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDeco(isDark),
                  child: Center(
                    child: Text(
                      "Trend verisi bulunamadı",
                      style: TextStyle(color: subTextColor),
                    ),
                  ),
                );
              }
              return _buildTrendChart(
                snapshot.data!,
                isDark,
                textColor,
                subTextColor,
              );
            },
          ),
          const SizedBox(height: 24),

          // ── Sektörler Başlık ─────────────────────────────────────
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: _kTeal,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                "Sektörler",
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Filtre Butonları ─────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip("Tümü", 0, isDark, subTextColor),
                _filterChip("Yükselenler", 1, isDark, subTextColor),
                _filterChip("Durağan", 2, isDark, subTextColor),
                _filterChip("Düşenler", 3, isDark, subTextColor),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Sektör Kartları ──────────────────────────────────────
          FutureBuilder<List<SectorModel>>(
            future: _sectorsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: _kTeal),
                );
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "Veri bulunamadı",
                    style: TextStyle(color: textColor),
                  ),
                );
              }
              final filtered = getFilteredSectors(snapshot.data!);
              if (filtered.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: Text(
                    "Kriterlere uygun sektör yok",
                    style: TextStyle(color: subTextColor, fontSize: 16),
                  ),
                );
              }
              return Column(
                children:
                    filtered
                        .map(
                          (s) => _buildSectorCard(
                            context,
                            s,
                            isDark,
                            textColor,
                            subTextColor,
                          ),
                        )
                        .toList(),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
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

  // ── Filtre Chip ──────────────────────────────────────────────────
  Widget _filterChip(String text, int index, bool isDark, Color subText) {
    final isSelected = _selectedFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? (isDark
                        ? _kTeal.withValues(alpha: 0.12)
                        : _kTeal.withValues(alpha: 0.08))
                    : (isDark ? _kCard : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isSelected
                      ? _kTeal.withValues(alpha: isDark ? 0.35 : 0.30)
                      : (isDark ? _kGlassBorder : Colors.grey.shade300),
              width: 1,
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? _kTeal : subText,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // ── Yatay Performans Grafiği ─────────────────────────────────────
  Widget _buildHorizontalGraph(
    List<SectorModel> sectors,
    bool isDark,
    Color textColor,
  ) {
    final sorted = List<SectorModel>.from(sectors)
      ..sort((a, b) => b.sixMonthChange.compareTo(a.sixMonthChange));
    final display = sorted.take(6).toList();

    double maxValue =
        display.isEmpty
            ? 100
            : display
                .map((e) => e.sixMonthChange.abs())
                .reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue = 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDeco(isDark, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performans Liderleri",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? _kTeal.withValues(alpha: 0.10)
                          : _kTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      isDark
                          ? Border.all(color: _kTeal.withValues(alpha: 0.25))
                          : null,
                ),
                child: const Text(
                  "6 Aylık",
                  style: TextStyle(
                    color: _kTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...display.map((sector) {
            final isPositive = sector.sixMonthChange >= 0;
            final percentage = sector.sixMonthChange.abs() / maxValue;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      sector.name,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: percentage.clamp(0.01, 1.0),
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    isPositive
                                        ? [
                                          _kProfit.withValues(alpha: 0.7),
                                          _kProfit,
                                        ]
                                        : [
                                          _kLoss.withValues(alpha: 0.7),
                                          _kLoss,
                                        ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: (isPositive ? _kProfit : _kLoss)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 58,
                    child: Text(
                      "${isPositive ? '+' : ''}${sector.sixMonthChange.toStringAsFixed(1)}%",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: isPositive ? _kProfit : _kLoss,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Trend Grafiği ────────────────────────────────────────────────
  Widget _buildTrendChart(
    List<SectorTrendModel> allTrends,
    bool isDark,
    Color textColor,
    Color subTextColor,
  ) {
    List<SectorTrendModel> sorted = List.from(allTrends)..sort((a, b) {
      double la = a.yearlyPoints.isNotEmpty ? a.yearlyPoints.last : 0;
      double lb = b.yearlyPoints.isNotEmpty ? b.yearlyPoints.last : 0;
      return lb.compareTo(la);
    });
    final top3 = sorted.take(3).toList();

    double minData = double.infinity, maxData = double.negativeInfinity;
    for (var t in top3) {
      for (var p in t.yearlyPoints) {
        if (p < minData) minData = p;
        if (p > maxData) maxData = p;
      }
    }
    final pad = (maxData - minData) * 0.1;
    final minY = (minData - pad).floorToDouble();
    final maxY = (maxData + pad).ceilToDouble();
    final yInterval = (maxY - minY) / 5;
    final colorMap = AppColors.sectorColors;
    final gridColor =
        isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03);
    final axisTextColor =
        isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54;
    final maxX =
        top3.isNotEmpty ? (top3.first.yearlyPoints.length - 1).toDouble() : 4.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDeco(isDark, radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Trend Liderleri (Top 3)",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? _kCardInner : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "2020-2025",
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  top3.map((t) {
                    final color = colorMap[t.sectorName] ?? _kTeal;
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _legendItem(t.sectorName, color),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 30),
          AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor:
                        (_) => Colors.blueGrey.withValues(alpha: 0.8),
                    getTooltipItems:
                        (spots) =>
                            spots
                                .map(
                                  (s) => LineTooltipItem(
                                    s.y.toStringAsFixed(1),
                                    const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                                .toList(),
                  ),
                ),
                clipData: const FlClipData.all(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: yInterval,
                  getDrawingHorizontalLine:
                      (_) => FlLine(
                        color: gridColor,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        if (value <= minY || value >= maxY) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 12,
                          child: Text(
                            value.toStringAsFixed(1),
                            style: TextStyle(
                              color: axisTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i > maxX) return const SizedBox();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 10,
                          child: Text(
                            (2020 + i).toString(),
                            style: TextStyle(
                              color: axisTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                lineBarsData:
                    top3.map((t) {
                      final color = colorMap[t.sectorName] ?? _kTeal;
                      final spots =
                          t.yearlyPoints
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value))
                              .toList();
                      return LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        preventCurveOverShooting: true,
                        color: color,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter:
                              (_, __, ___, ____) => FlDotCirclePainter(
                                radius: 3,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: color,
                              ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.15),
                              color.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String text, Color color) => Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  // ── Sektör Kartı ─────────────────────────────────────────────────
  Widget _buildSectorCard(
    BuildContext context,
    SectorModel sector,
    bool isDark,
    Color textColor,
    Color? subTextColor,
  ) {
    final isUp = sector.sixMonthChange > 8.0;
    final isFlat = sector.sixMonthChange > 0 && sector.sixMonthChange <= 8.0;
    final tag = isUp ? "Yükselişte" : (isFlat ? "Durağan" : "Düşüşte");
    final tagColor = isUp ? _kProfit : (isFlat ? _kTeal : _kLoss);

    String companiesText = "${sector.name} Endeks Şirketleri";
    if (sector.topCompanies.isNotEmpty) {
      companiesText = sector.topCompanies
          .map((c) => c['ticker'].toString())
          .join(' • ');
    }

    final metricBg = isDark ? _kCardInner : Colors.grey.shade100;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: _cardDeco(
        isDark,
        borderColor:
            isDark
                ? AppColors.sectorColors[sector.name]?.withValues(
                      alpha: 0.20,
                    ) ??
                    _kGlassBorder
                : Colors.grey.shade200,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    sector.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: tagColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${sector.sixMonthChange >= 0 ? '+' : ''}%${sector.sixMonthChange.toStringAsFixed(1)}",
                    style: TextStyle(
                      color: sector.sixMonthChange >= 0 ? _kProfit : _kLoss,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "6 Aylık",
                    style: TextStyle(color: subTextColor, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            companiesText,
            style: TextStyle(color: subTextColor, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _metricItem(
                "Günlük",
                "%${sector.dailyChange.toStringAsFixed(2)}",
                metricBg,
                textColor,
                subTextColor,
                isGrowth: sector.dailyChange >= 0,
              ),
              const SizedBox(width: 8),
              _metricItem(
                "Haftalık",
                "%${sector.weeklyChange.toStringAsFixed(2)}",
                metricBg,
                textColor,
                subTextColor,
                isGrowth: sector.weeklyChange >= 0,
              ),
              const SizedBox(width: 8),
              _metricItem(
                "Aylık",
                "%${sector.monthlyChange.toStringAsFixed(2)}",
                metricBg,
                textColor,
                subTextColor,
                isGrowth: sector.monthlyChange >= 0,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // "Şirketleri İncele" teal outlined buton
          GestureDetector(
            onTap: () async {
              final stocks = await _dataService.getStocksBySector(sector.name);
              if (!context.mounted) return;
              if (stocks.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => CompanyDetailScreen(
                          sectorName: sector.name,
                          companies: stocks,
                          initialIndex: 0,
                          dailyChange: sector.dailyChange,
                        ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${sector.name} için detay verisi bulunamadı.",
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _kTeal.withValues(alpha: isDark ? 0.10 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _kTeal.withValues(alpha: isDark ? 0.25 : 0.20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Şirketleri İncele",
                    style: TextStyle(
                      color: _kTeal,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: _kTeal,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricItem(
    String label,
    String value,
    Color bgColor,
    Color textColor,
    Color? labelColor, {
    bool isGrowth = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(color: labelColor, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color:
                    isGrowth
                        ? _kProfit
                        : (value.contains('-') ? _kLoss : textColor),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
