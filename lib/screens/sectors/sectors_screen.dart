import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // Min/Max hesaplaması için gerekli
import '../../core/theme/color_scheme.dart';
import '../../models/sector_model.dart';
import '../../models/stock_model.dart';
import '../../models/sector_trend_model.dart';
import '../../services/data_service.dart';
import 'company_detail_screen.dart';

class SectorsScreen extends StatefulWidget {
  const SectorsScreen({super.key});

  @override
  State<SectorsScreen> createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> {
  int _selectedFilterIndex = 0;

  // Servis ve Future Tanımları
  final DataService _dataService = DataService();
  Future<List<SectorModel>>? _sectorsFuture;
  Future<List<SectorTrendModel>>? _trendsFuture;

  // Marka Renkleri (AppColors üzerinden merkezi yönetim)
  final Color primary = AppColors.accentBlue;
  final Color green = AppColors.profitLight;
  final Color red = AppColors.lossLight;

  @override
  void initState() {
    super.initState();
    _sectorsFuture = _dataService.loadSectorData();
    _trendsFuture = _dataService.getSectorTrends();
  }

  // Sektör Filtreleme Mantığı
  List<SectorModel> getFilteredSectors(List<SectorModel> allSectors) {
    const double threshold = 8.0;

    switch (_selectedFilterIndex) {
      case 0: // Tümü
        return allSectors;
      case 1: // Yükselenler (> %8)
        return allSectors.where((s) => s.sixMonthChange > threshold).toList();
      case 2: // Durağan (%0 - %8)
        return allSectors
            .where((s) => s.sixMonthChange > 0 && s.sixMonthChange <= threshold)
            .toList();
      case 3: // Düşenler (<= %0)
        return allSectors.where((s) => s.sixMonthChange <= 0).toList();
      default:
        return allSectors;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema verilerini aldığımız kısım
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dinamik renkler
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = isDark ? Colors.grey : Colors.grey[600];

    // Kart kenarlığı
    final borderColor =
    isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.2);
    // Metrik kutucukları rengi
    final metricCardBg =
    isDark ? AppColors.darkCardInner : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve filtre ikonu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sektör Analizi",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.filter_list, color: primary),
                ],
              ),
              Text(
                "6 aylık piyasa performansı",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // --- PERFORMANS GRAFİĞİ ---
              FutureBuilder<List<SectorModel>>(
                future: _sectorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                        height: 200,
                        child: Center(
                            child: CircularProgressIndicator(color: primary)));
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const SizedBox();
                  }
                  return _buildHorizontalGraph(
                      snapshot.data!, isDark, cardColor, textColor);
                },
              ),

              const SizedBox(height: 16),

              // --- TREND GRAFİĞİ ---
              FutureBuilder<List<SectorTrendModel>>(
                future: _trendsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                            child: CircularProgressIndicator(color: primary)));
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16)),
                      child: Center(
                          child: Text("Trend verisi bulunamadı",
                              style: TextStyle(color: subTextColor))),
                    );
                  }

                  return _buildTrendChart(snapshot.data!, isDark, cardColor,
                      textColor, borderColor, subTextColor);
                },
              ),

              const SizedBox(height: 24),

              Text(
                "Sektörler",
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Filtre Butonları
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterButton("Tümü", 0, cardColor, textColor, isDark),
                    _filterButton(
                        "Yükselenler", 1, cardColor, textColor, isDark),
                    _filterButton("Durağan", 2, cardColor, textColor, isDark),
                    _filterButton("Düşenler", 3, cardColor, textColor, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- SEKTÖR KARTLARI LİSTESİ ---
              FutureBuilder<List<SectorModel>>(
                future: _sectorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(color: primary));
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text("Veri yüklenemedi",
                            style: TextStyle(color: textColor)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text("Veri bulunamadı",
                            style: TextStyle(color: textColor)));
                  }

                  final filteredList = getFilteredSectors(snapshot.data!);

                  if (filteredList.isEmpty) {
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
                    children: filteredList
                        .map((sector) => _buildSectorCard(
                      context,
                      sector,
                      cardColor,
                      textColor,
                      subTextColor,
                      metricCardBg,
                      borderColor,
                      isDark,
                    ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- YATAY PERFORMANS GRAFİĞİ ---
  Widget _buildHorizontalGraph(List<SectorModel> sectors, bool isDark,
      Color cardColor, Color textColor) {
    final sortedSectors = List<SectorModel>.from(sectors);
    sortedSectors.sort((a, b) => b.sixMonthChange.compareTo(a.sixMonthChange));

    final displayList = sortedSectors.take(6).toList();

    double maxValue = displayList.isNotEmpty
        ? displayList
        .map((e) => e.sixMonthChange.abs())
        .reduce((a, b) => a > b ? a : b)
        : 100.0;
    if (maxValue == 0) maxValue = 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Performans Liderleri",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor)),
              Text("6 Aylık",
                  style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),

          ...displayList.map((sector) {
            final isPositive = sector.sixMonthChange >= 0;
            final percentage = sector.sixMonthChange.abs() / maxValue;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      sector.name,
                      style: TextStyle(
                          color: textColor.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
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
                            color: isDark
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
                                colors: isPositive
                                    ? [
                                  const Color(0xFF00C853)
                                      .withValues(alpha: 0.7),
                                  const Color(0xFF00C853)
                                ]
                                    : [
                                  const Color(0xFFFF5252)
                                      .withValues(alpha: 0.7),
                                  const Color(0xFFFF5252)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: (isPositive
                                      ? const Color(0xFF00C853)
                                      : const Color(0xFFFF5252))
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 55,
                    child: Text(
                      "${isPositive ? '+' : ''}${sector.sixMonthChange.toStringAsFixed(1)}%",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                          color: isPositive
                              ? const Color(0xFF00C853)
                              : const Color(0xFFFF5252),
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
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

  // --- DİNAMİK TREND GRAFİĞİ (GÜZELLEŞTİRİLMİŞ & TOP 3) ---
  Widget _buildTrendChart(List<SectorTrendModel> allTrends, bool isDark,
      Color bgColor, Color textColor, Color borderColor, Color? subTextColor) {
    // 1. Filtreleme ve Sıralama
    List<SectorTrendModel> sortedList = List.from(allTrends);
    sortedList.sort((a, b) {
      double lastA = a.yearlyPoints.isNotEmpty ? a.yearlyPoints.last : 0;
      double lastB = b.yearlyPoints.isNotEmpty ? b.yearlyPoints.last : 0;
      return lastB.compareTo(lastA);
    });
    final top3Trends = sortedList.take(3).toList();

    // 2. Dinamik Min/Max Hesabı (Grafiğin düzgün görünmesi için)
    double minData = double.infinity;
    double maxData = double.negativeInfinity;

    for (var trend in top3Trends) {
      for (var point in trend.yearlyPoints) {
        if (point < minData) minData = point;
        if (point > maxData) maxData = point;
      }
    }
    // Biraz boşluk bırakalım ki çizgiler tavana/tabana yapışmasın
    final double padding = (maxData - minData) * 0.1;
    final double finalMinY = (minData - padding).floorToDouble();
    final double finalMaxY = (maxData + padding).ceilToDouble();
    final double yInterval = (finalMaxY - finalMinY) / 5; // Aralığı hesapla

    // Renk Haritası (AppColors merkezi sektör renkleri)
    final colorMap = AppColors.sectorColors;

    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);
    final axisTextColor =
    isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54;

    final double maxX = top3Trends.isNotEmpty
        ? (top3Trends.first.yearlyPoints.length - 1).toDouble()
        : 4.0;

    return Container(
      padding: const EdgeInsets.all(20), // Padding artırıldı
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
        ],
      ),
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
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(
                  "2020-2025",
                  style: TextStyle(
                      color: subTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Lejant (Daha temiz görünüm)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: top3Trends.map((trend) {
                final color = colorMap[trend.sectorName] ?? primary;
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildLegendItem(trend.sectorName, color, isDark),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 30),

          // GRAFİK ALANI
          AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                // -------------------------------------------------------------
                // EKLENEN KISIM BAŞLANGIÇ: Tooltip'teki sayıyı formatlıyoruz
                // -------------------------------------------------------------
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        Colors.blueGrey.withValues(alpha: 0.8),
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        return LineTooltipItem(
                          barSpot.y.toStringAsFixed(1), // BURADA 1. VİRGÜL AYARI
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                // -------------------------------------------------------------
                // EKLENEN KISIM BİTİŞ
                // -------------------------------------------------------------

                clipData: const FlClipData
                    .all(), // Çizgilerin dışarı taşmasını engeller
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine:
                  false, // Dikey çizgileri kaldırdım, daha temiz
                  horizontalInterval: yInterval, // Izgara aralığı
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: gridColor,
                      strokeWidth: 1,
                      dashArray: [5, 5], // Kesikli çizgi
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, // SOL EKSEN DEĞERLERİNİ AÇTIK
                      reservedSize:
                      48, // Ondalık basamak için alanı genişlettik
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        // Alt ve üst sınırları yazma ki kesilmesin
                        if (value <= finalMinY || value >= finalMaxY) {
                          return const SizedBox();
                        }
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 12, // Grafikten biraz daha uzağa
                          child: Text(
                            value.toStringAsFixed(1), // Örn: 110.4
                            style: TextStyle(
                              color: axisTextColor,
                              fontSize: 11, // Biraz daha şık, kompakt font
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5, // Rakamları toplu gösterir
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
                        int index = value.toInt();
                        if (index >= 0 && index <= maxX) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 10,
                            child: Text(
                              (2020 + index).toString(),
                              style: TextStyle(
                                color: axisTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: maxX,
                minY: finalMinY,
                maxY: finalMaxY,
                lineBarsData: top3Trends.map((trend) {
                  final color = colorMap[trend.sectorName] ?? primary;

                  final spots = trend.yearlyPoints
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList();

                  return LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35, // Daha doğal kıvrım
                    preventCurveOverShooting:
                    true, // ÖNEMLİ: Çizginin taşmasını engeller
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true, // Noktaları göster
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: color,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.15), // Çok daha şeffaf
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

  Widget _buildLegendItem(String text, Color color, bool isDark) {
    return Row(
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
                )
              ]),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        )
      ],
    );
  }

  // Filtre Butonu
  Widget _filterButton(
      String text, int index, Color cardColor, Color textColor, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    final unselectedBg = isDark ? cardColor : Colors.grey.shade200;
    final unselectedText = isDark ? Colors.white70 : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? green : unselectedBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.black : unselectedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // --- SEKTÖR KARTI ---
  Widget _buildSectorCard(
      BuildContext context,
      SectorModel sector,
      Color cardColor,
      Color textColor,
      Color? subTextColor,
      Color metricBgColor,
      Color borderColor,
      bool isDark,
      ) {
    String tag = "Yatay";
    Color tagColor = Colors.grey;

    if (sector.sixMonthChange > 8.0) {
      tag = "Yükselişte";
      tagColor = green;
    } else if (sector.sixMonthChange > 0) {
      tag = "Durağan";
      tagColor = primary;
    } else {
      tag = "Düşüşte";
      tagColor = red;
    }

    String companiesText = "${sector.name} Endeks Şirketleri";
    if (sector.topCompanies.isNotEmpty) {
      companiesText = sector.topCompanies
          .map((company) => company['ticker'].toString())
          .join(' • ');
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
          ]),
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                          color: tagColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
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
                        color: sector.sixMonthChange >= 0 ? green : red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
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

          Text(companiesText,
              style:
              TextStyle(color: subTextColor, fontWeight: FontWeight.w500)),

          const SizedBox(height: 20),

          Row(
            children: [
              _metricItem(
                "Günlük",
                "%${sector.dailyChange.toStringAsFixed(2)}",
                metricBgColor,
                textColor,
                subTextColor,
                isGrowth: sector.dailyChange >= 0,
              ),
              const SizedBox(width: 8),
              _metricItem(
                "Haftalık",
                "%${sector.weeklyChange.toStringAsFixed(2)}",
                metricBgColor,
                textColor,
                subTextColor,
                isGrowth: sector.weeklyChange >= 0,
              ),
              const SizedBox(width: 8),
              _metricItem(
                "Aylık",
                "%${sector.monthlyChange.toStringAsFixed(2)}",
                metricBgColor,
                textColor,
                subTextColor,
                isGrowth: sector.monthlyChange >= 0,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // --- BUTON (NAVIGATION) ---
          Center(
            child: TextButton.icon(
              onPressed: () async {
                List<StockModel> detailedStocks =
                await _dataService.getStocksBySector(sector.name);

                if (!context.mounted) return;

                if (detailedStocks.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompanyDetailScreen(
                        sectorName: sector.name,
                        companies: detailedStocks,
                        initialIndex: 0,
                        dailyChange: sector.dailyChange,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            "${sector.name} sektörü için detay verisi bulunamadı.")),
                  );
                }
              },
              icon: Text(
                "Şirketleri İncele",
                style: TextStyle(color: AppColors.profitLight),
              ),
              label: Icon(
                Icons.arrow_forward,
                color: AppColors.profitLight,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value, Color bgColor, Color textColor,
      Color? labelColor,
      {bool isGrowth = false}) {
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
                isGrowth ? green : (value.contains('-') ? red : textColor),
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