import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/sector_model.dart';
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

  // Marka Renkleri (Sabit)
  final Color primary = const Color(0xFF3D8BFF);
  final Color green = const Color(0xFF00C853);
  final Color red = const Color(0xFFFF5252);

  @override
  void initState() {
    super.initState();
    _sectorsFuture = _dataService.loadSectorData();
  }

  //Sektör Filtreleme
  List<SectorModel> getFilteredSectors(List<SectorModel> allSectors) {
    switch (_selectedFilterIndex) {
      case 0: // Tümü
        return allSectors;
      case 1: // Yüksek Potansiyel
        return allSectors.where((s) => s.sixMonthChange > 10.0).toList();
      case 2: // Orta Potansiyel
        return allSectors
            .where((s) => s.sixMonthChange > 0 && s.sixMonthChange <= 10.0)
            .toList();
      case 3: // Düşük Potansiyel
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
        isDark ? const Color(0xFF1A2038) : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: FutureBuilder<List<SectorModel>>(
          future: _sectorsFuture,
          builder: (context, snapshot) {
            // 1. Durum: Veri yükleniyor
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primary));
            }
            // 2. Durum: Hata var
            else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: red, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      "Veri yüklenemedi",
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              );
            }
            // 3. Durum: Veri yok veya boş
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "Veri bulunamadı",
                  style: TextStyle(color: textColor),
                ),
              );
            }

            // Veri başarıyla geldi
            final allSectors = snapshot.data!;
            final filteredList = getFilteredSectors(allSectors);

            return SingleChildScrollView(
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

                  // ---  PERFORMANS GRAFİĞİ ---
                  _buildHorizontalGraph(
                    allSectors,
                    isDark,
                    cardColor,
                    textColor,
                  ),

                  const SizedBox(height: 16),

                  // --- TREND GRAFİĞİ ---
                  _buildTrendChart(isDark, cardColor, textColor, borderColor),

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
                          "Yüksek Potansiyel",
                          1,
                          cardColor,
                          textColor,
                          isDark,
                        ),
                        _filterButton(
                          "Orta Potansiyel",
                          2,
                          cardColor,
                          textColor,
                          isDark,
                        ),
                        _filterButton(
                          "Düşük Potansiyel",
                          3,
                          cardColor,
                          textColor,
                          isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sektör kartları
                  filteredList.isEmpty
                      ? Container(
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: Text(
                          "Kriterlere uygun sektör yok",
                          style: TextStyle(color: subTextColor, fontSize: 16),
                        ),
                      )
                      : Column(
                        children:
                            filteredList
                                .map(
                                  (sector) => _buildSectorCard(
                                    sector,
                                    cardColor,
                                    textColor,
                                    subTextColor,
                                    metricCardBg,
                                    borderColor,
                                    isDark,
                                  ),
                                )
                                .toList(),
                      ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- YATAY PERFORMANS GRAFİĞİ (PROFESYONEL) ---
  Widget _buildHorizontalGraph(
    List<SectorModel> sectors,
    bool isDark,
    Color cardColor,
    Color textColor,
  ) {
    // 1. Sıralama: En yüksekten en düşüğe
    final sortedSectors = List<SectorModel>.from(sectors);
    sortedSectors.sort((a, b) => b.sixMonthChange.compareTo(a.sixMonthChange));

    // İlk 6 tanesi
    final displayList = sortedSectors.take(6).toList();

    // En yüksek değeri bul (Çubukların boyunu buna göre oranlayacağız)
    double maxValue =
        displayList.isNotEmpty
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
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
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
              Text(
                "Performans Liderleri",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              Text(
                "6 Aylık",
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Çubukları Listele
          ...displayList.map((sector) {
            final isPositive = sector.sixMonthChange >= 0;
            final percentage =
                sector.sixMonthChange.abs() /
                maxValue; // 0.0 ile 1.0 arası oran

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  // 1. Sektör Adı (Solda)
                  SizedBox(
                    width: 100, // İsmin sığacağı alan
                    child: Text(
                      sector.name,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // 2. Grafik Çubuğu (Ortada)
                  Expanded(
                    child: Stack(
                      children: [
                        // Arka plandaki silik gri çubuk (Ray)
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
                        // Öndeki renkli çubuk (Doluluk oranı)
                        FractionallySizedBox(
                          widthFactor: percentage.clamp(0.01, 1.0),
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    isPositive
                                        ? [
                                          const Color(
                                            0xFF00C853,
                                          ).withValues(alpha: 0.7),
                                          const Color(0xFF00C853),
                                        ]
                                        : [
                                          const Color(
                                            0xFFFF5252,
                                          ).withValues(alpha: 0.7),
                                          const Color(0xFFFF5252),
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 3. Yüzde Değeri (Sağda)
                  SizedBox(
                    width: 55,
                    child: Text(
                      "${isPositive ? '+' : ''}${sector.sixMonthChange.toStringAsFixed(1)}%",
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color:
                            isPositive
                                ? const Color(0xFF00C853)
                                : const Color(0xFFFF5252),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // --- TREND GRAFİĞİ (YENİ VERİLER) ---
  Widget _buildTrendChart(
    bool isDark,
    Color bgColor,
    Color textColor,
    Color borderColor,
  ) {
    // RENKLER
    final Color techColor = const Color(0xFF9D46FF); // Teknoloji (Mor)
    final Color healthColor = const Color(0xFF00C853); // Sağlık (Yeşil)
    final Color realEstateColor = const Color(
      0xFFFF9100,
    ); // Gayrimenkul (Turuncu)

    // --- YENİ VERİ SETİ ---
    // HEDEF: Teknoloji: 8.9, Sağlık: 17.9, Gayrimenkul: 29.2

    // 1. Teknoloji: Yüksekten düşüş trendi (8.9 ile kapanış)
    final List<FlSpot> techSpots = [
      const FlSpot(0, 55), // 2021 (Yüksek başlangıç)
      const FlSpot(1, 45), // 2022
      const FlSpot(2, 30), // 2023 (Düşüş hızlanıyor)
      const FlSpot(3, 15), // 2024
      const FlSpot(4, 8.9), // 2025 (HEDEF)
    ];

    // 2. Sağlık: İstikrarlı ve Defansif (17.9 ile kapanış)
    final List<FlSpot> healthSpots = [
      const FlSpot(0, 14), // 2021
      const FlSpot(1, 15), // 2022
      const FlSpot(2, 13), // 2023
      const FlSpot(3, 16), // 2024
      const FlSpot(4, 17.9), // 2025 (HEDEF)
    ];

    // 3. Gayrimenkul: Yükseliş Trendi (29.2 ile kapanış)
    final List<FlSpot> realEstateSpots = [
      const FlSpot(0, 10), // 2021 (Düşük başlangıç)
      const FlSpot(1, 18), // 2022
      const FlSpot(2, 15), // 2023 (Hafif düzeltme)
      const FlSpot(3, 24), // 2024
      const FlSpot(4, 29.2), // 2025 (HEDEF)
    ];

    // Stil değişkenleri
    final gridColor =
        isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05);
    final axisTextColor =
        isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sektör Trendleri (2021-2025)",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // --- LEJANT ---
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildLegendItem("Teknoloji", techColor, isDark),
                const SizedBox(width: 12),
                _buildLegendItem("Sağlık", healthColor, isDark),
                const SizedBox(width: 12),
                _buildLegendItem("Gayrimenkul", realEstateColor, isDark),
              ],
            ),
          ),

          const SizedBox(height: 25),
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 10,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: gridColor, strokeWidth: 1);
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(color: gridColor, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  // SOL EKSEN
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: 10,
                      getTitlesWidget: (value, meta) {
                        if (value < 0) return const SizedBox();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Text(
                            "${value.toInt()}",
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

                  // ALT EKSEN
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index <= 4) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Text(
                              (2021 + index).toString(),
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
                maxX: 4,
                minY: 0,
                maxY: 80,
                lineBarsData: [
                  // Teknoloji
                  LineChartBarData(
                    spots: techSpots,
                    isCurved: true,
                    color: techColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: bgColor,
                          strokeWidth: 2,
                          strokeColor: techColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          techColor.withValues(alpha: 0.3),
                          techColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Sağlık
                  LineChartBarData(
                    spots: healthSpots,
                    isCurved: true,
                    color: healthColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: bgColor,
                          strokeWidth: 2,
                          strokeColor: healthColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          healthColor.withValues(alpha: 0.3),
                          healthColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Gayrimenkul
                  LineChartBarData(
                    spots: realEstateSpots,
                    isCurved: true,
                    color: realEstateColor,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: bgColor,
                          strokeWidth: 2,
                          strokeColor: realEstateColor,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          realEstateColor.withValues(alpha: 0.3),
                          realEstateColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                // Tooltip
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor:
                        (_) => isDark ? const Color(0xFF2C3246) : Colors.white,
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        String sectorName = "";
                        if (barSpot.bar.color == techColor) {
                          sectorName = "Tekno";
                        } else if (barSpot.bar.color == healthColor) {
                          sectorName = "Sağlık";
                        } else {
                          sectorName = "G.Menkul";
                        }

                        return LineTooltipItem(
                          "$sectorName: ${barSpot.y.toStringAsFixed(1)}",
                          TextStyle(
                            color: barSpot.bar.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Lejant Yardımcı Widget
  Widget _buildLegendItem(String text, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? Colors.white24 : Colors.black12,
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _filterButton(
    String text,
    int index,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
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

  // --- GÜNCELLENMİŞ SEKTÖR KARTI (Şirketler Eklendi) ---
  Widget _buildSectorCard(
    SectorModel sector,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
    Color metricBgColor,
    Color borderColor,
    bool isDark,
  ) {
    String tag = "Nötr";
    Color tagColor = Colors.grey;

    if (sector.sixMonthChange > 10.0) {
      tag = "Yüksek";
      tagColor = green;
    } else if (sector.sixMonthChange > 0) {
      tag = "Orta";
      tagColor = primary;
    } else {
      tag = "Düşük";
      tagColor = red;
    }

    // YENİ: Top 3 şirket ismini oluşturduk
    String companiesText = "${sector.name} Endeks Şirketleri";
    if (sector.topCompanies.isNotEmpty) {
      // Şirket isimlerini alıp araya nokta koyarak birleştirdik
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
              offset: const Offset(0, 4),
            ),
        ],
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
                      fontSize: 18,
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
              Text(
                "${sector.sixMonthChange >= 0 ? '+' : ''}${sector.sixMonthChange.toStringAsFixed(1)}%",
                style: TextStyle(
                  color: sector.sixMonthChange >= 0 ? green : red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            companiesText,
            style: TextStyle(color: subTextColor, fontWeight: FontWeight.w500),
          ),

          // -------------------------
          const SizedBox(height: 20),

          Row(
            children: [
              _metricItem(
                "6 Aylık Performans",
                "%${sector.sixMonthChange.toStringAsFixed(1)}",
                metricBgColor,
                textColor,
                subTextColor,
                isGrowth: sector.sixMonthChange > 0,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CompanyDetailScreen(
                          companyName: "${sector.name} Şirketleri",
                          ticker:
                              "X${sector.name.substring(0, (sector.name.length > 3 ? 3 : sector.name.length)).toUpperCase()}",
                          sector: sector.name,
                        ),
                  ),
                );
              },
              icon: const Text(
                "Şirketleri İncele",
                style: TextStyle(color: Colors.greenAccent),
              ),
              label: const Icon(
                Icons.arrow_forward,
                color: Colors.greenAccent,
                size: 18,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color:
                    isGrowth ? green : (value.contains('-') ? red : textColor),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
