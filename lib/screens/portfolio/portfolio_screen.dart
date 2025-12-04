import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // fl_chart paketini import et
import 'package:finance_app/screens/home/home_screen.dart'; // HomeScreen importu eklendi

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  // --- MARKA RENKLERİ ---
  final Color primaryGreen = const Color(0xFF00C853);
  final Color primaryBlue = const Color(0xFF3D8BFF);
  final Color primaryYellow = const Color(0xFFFFC107);
  final Color primaryPurple = const Color(0xFF9C27B0);
  final Color primaryGrey = const Color(0xFF90A4AE);

  // Pie Chart Etkileşimi için seçili dilim indeksi
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    // TEMA VERİLERİ
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dinamik Renkler
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.2);
    final balanceCardInnerColor = isDark ? const Color(0xFF0F162C) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        // --- GERİ BUTONU EKLENDİ ---
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            // Ana Sayfaya Yönlendir
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Portföyüm",
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Kişiselleştirilmiş analiz ve öneriler",
              style: TextStyle(color: subTextColor, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none, color: textColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. TOPLAM DEĞER KARTI
            _buildTotalBalanceCard(balanceCardInnerColor, textColor, subTextColor, borderColor, isDark),

            const SizedBox(height: 24),

            // 2. SEKTÖR DAĞILIMI (FL CHART - PIE)
            _buildSectorChart(cardColor, textColor, subTextColor, borderColor, isDark),

            const SizedBox(height: 24),

            // 3. KARŞILAŞTIRMA (FL CHART - BAR)
            _buildComparisonChart(cardColor, textColor, borderColor, isDark),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 1. KART: TOPLAM BAKİYE ---
  Widget _buildTotalBalanceCard(Color cardBg, Color textColor, Color subTextColor, Color borderColor, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Toplam Değer",
            style: TextStyle(color: subTextColor, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "250.000₺",
            style: TextStyle(
              color: textColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.trending_up, color: primaryGreen, size: 20),
              const SizedBox(width: 6),
              Text(
                "+12.8%",
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                " Son 30 gün",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. KART: SEKTÖR DAĞILIMI (FL CHART - PIE) ---
  Widget _buildSectorChart(Color cardBg, Color textColor, Color subTextColor, Color borderColor, bool isDark) {
    // Grafik Verileri
    final List<ChartData> data = [
      ChartData("Teknoloji", 35, primaryGreen, "87.500₺"),
      ChartData("Enerji", 25, primaryYellow, "62.500₺"),
      ChartData("Bankacılık", 20, primaryBlue, "50.000₺"),
      ChartData("Havacılık", 15, primaryPurple, "37.500₺"),
      ChartData("Diğer", 5, primaryGrey, "12.500₺"),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sektör Dağılımı",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 30),

          // --- FL CHART: PIE CHART ---
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
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2, // Dilimler arası boşluk
                    centerSpaceRadius: 60, // Donut boşluğu
                    sections: List.generate(data.length, (i) {
                      final isTouched = i == touchedIndex;
                      final fontSize = isTouched ? 18.0 : 14.0;
                      final radius = isTouched ? 60.0 : 50.0;
                      final item = data[i];

                      return PieChartSectionData(
                        color: item.color,
                        value: item.percent,
                        title: '${item.percent.toInt()}%',
                        radius: radius,
                        titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [Shadow(color: Colors.black26, blurRadius: 2)],
                        ),
                      );
                    }),
                  ),
                ),
                // Ortadaki Metin
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "5",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Sektör",
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Lejant (Liste)
          Column(
            children: data.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.label,
                      style: TextStyle(color: subTextColor, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      "${item.percent}%",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.amount,
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- 3. KART: KARŞILAŞTIRMA (FL CHART - BAR) ---
  Widget _buildComparisonChart(Color cardBg, Color textColor, Color borderColor, bool isDark) {
    // Piyasa rengi
    final marketBarColor = isDark ? const Color(0xFF455A64) : const Color(0xFFCFD8DC);
    final gridColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05);
    final labelColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    // Veri
    final labels = ["Teknoloji", "Enerji", "Bankacılık", "Havacılık", "Diğer"];
    final marketValues = [60.0, 50.0, 80.0, 40.0, 30.0];
    final myValues = [90.0, 40.0, 50.0, 40.0, 15.0];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performans Analizi",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.info_outline, color: labelColor, size: 18),
            ],
          ),
          const SizedBox(height: 30),

          // --- FL CHART: BAR CHART ---
          SizedBox(
            height: 250, // Grafik alanını biraz büyüttük
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,

                // --- ARKA PLAN IZGARALARI ---
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true, // Dikey çizgiler (Sektörleri ayırır)
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: gridColor,
                    strokeWidth: 1,
                    dashArray: [5, 5], // Kesikli Yatay
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: gridColor,
                    strokeWidth: 1,
                    dashArray: [5, 5], // Kesikli Dikey
                  ),
                ),

                // --- EKSEN BAŞLIKLARI (AXIS TITLES) ---
                titlesData: FlTitlesData(
                  show: true,
                  // ALT EKSEN (Kategoriler)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) return const SizedBox();
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 8,
                          child: Transform.rotate(
                            angle: -0.5,
                            child: Text(
                              labels[index],
                              style: TextStyle(
                                color: labelColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // SOL EKSEN (Değerler - 0, 20, 40...)
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30, // Sayılar için yer ayır
                      interval: 20, // 20'şer artış
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: labelColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),

                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: labelColor.withValues(alpha: 0.2), width: 1),
                    left: BorderSide(color: labelColor.withValues(alpha: 0.2), width: 1),
                  ),
                ),

                // --- TOOLTIP (İPUCU) AYARLARI ---
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => isDark ? const Color(0xFF1E293B) : Colors.white,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    tooltipRoundedRadius: 8,
                    tooltipBorder: BorderSide(color: borderColor, width: 1),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = rodIndex == 0 ? "Piyasa" : "Portföy";
                      final tooltipTextColor = isDark ? Colors.white : Colors.black;

                      return BarTooltipItem(
                        "$label\n",
                        TextStyle(
                          color: tooltipTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: "${rod.toY.round()}",
                            style: TextStyle(
                              color: rod.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                // --- ÇUBUKLAR ---
                barGroups: List.generate(labels.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4, // Çubuklar arası boşluk
                    barRods: [
                      // 1. Çubuk: Piyasa
                      BarChartRodData(
                        toY: marketValues[index],
                        color: marketBarColor,
                        width: 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        // Arka planda silik çubuk (Background Bar) efekti
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100, // Max değer
                          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.withValues(alpha: 0.05),
                        ),
                      ),
                      // 2. Çubuk: Portföy
                      BarChartRodData(
                        toY: myValues[index],
                        color: primaryGreen,
                        width: 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.withValues(alpha: 0.05),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Lejant
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem("Piyasa Ort.", marketBarColor, isDark),
              const SizedBox(width: 24),
              _buildLegendItem("Portföyüm", primaryGreen, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[700],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// --- MODELLER ---
class ChartData {
  final String label;
  final double percent;
  final Color color;
  final String amount;

  ChartData(this.label, this.percent, this.color, this.amount);
}