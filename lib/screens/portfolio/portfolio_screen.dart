import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_app/screens/home/home_screen.dart';
import 'package:intl/intl.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  double _totalBalance = 250000.0;
  final currencyFormatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  final Color primaryGreen = const Color(0xFF00C853);
  final Color primaryBlue = const Color(0xFF3D8BFF);
  final Color primaryYellow = const Color(0xFFFFC107);
  final Color primaryPurple = const Color(0xFF9C27B0);
  final Color primaryGrey = const Color(0xFF90A4AE);

  int touchedIndex = -1;

  void _showEditBalanceDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: _totalBalance.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Toplam Varlık Düzenle",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Miktar giriniz",
              hintStyle: TextStyle(
                color: isDark ? Colors.grey : Colors.grey[700],
              ),
              suffixText: "₺",
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: primaryGreen, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "İptal",
                style: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                String cleanText = controller.text.replaceAll(',', '.');
                double? newValue = double.tryParse(cleanText);

                Navigator.pop(context);

                if (newValue != null && newValue > 0) {
                  setState(() {
                    _totalBalance = newValue;
                  });
                }
              },
              child: const Text(
                "Kaydet",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getSectorColor(String? sector) {
    switch (sector?.toLowerCase()) {
      case 'teknoloji':
        return primaryBlue;
      case 'enerji':
        return primaryYellow;
      case 'bankacılık':
        return primaryGreen;
      case 'havacılık':
        return primaryPurple;
      case 'sanayi':
        return Colors.orange;
      default:
        return primaryGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    final borderColor =
        isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.2);

    final balanceCardInnerColor =
        isDark ? const Color(0xFF0F162C) : Colors.white;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalBalanceCard(
              balanceCardInnerColor,
              textColor,
              subTextColor,
              borderColor,
              isDark,
            ),
            const SizedBox(height: 24),
            StreamBuilder<DocumentSnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('user_match')
                      .doc(FirebaseAuth.instance.currentUser?.uid)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return _buildNoDataPlaceholder(cardColor, subTextColor);
                }

                var data = snapshot.data!.data() as Map<String, dynamic>;
                List portfolio = data['recommendedPortfolio'] ?? [];

                if (portfolio.isEmpty) {
                  return Center(
                    child: Text(
                      "Önerilen hisse bulunamadı.",
                      style: TextStyle(color: subTextColor),
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildRecommendedPortfolio(
                      portfolio,
                      cardColor,
                      textColor,
                      subTextColor,
                      isDark,
                    ),
                    const SizedBox(height: 24),
                    _buildSectorChart(
                      portfolio,
                      cardColor,
                      textColor,
                      subTextColor,
                      borderColor,
                      isDark,
                    ),
                    const SizedBox(height: 24),
                    _buildComparisonChart(
                      portfolio,
                      cardColor,
                      textColor,
                      borderColor,
                      isDark,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard(
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.1),
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
                  Icons.edit,
                  size: 18,
                  color: subTextColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF00C853), size: 20),
              const SizedBox(width: 6),
              const Text(
                "+12.8%",
                style: TextStyle(
                  color: Color(0xFF00C853),
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

  Widget _buildRecommendedPortfolio(
    List portfolio,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Yapay Zeka Önerili Dağılım",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: portfolio.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            var stock = portfolio[index];

            double weight = (stock['Onerilen_Agirlik'] ?? 0).toDouble();
            double stockPrice = (stock['Fiyat'] ?? 1.0).toDouble();

            double amountTL = (_totalBalance * weight) / 100;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryBlue.withValues(alpha: 0.1),
                    child: Text(
                      stock['Hisse'].toString().substring(0, 1),
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock['Hisse'],
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${stock['Sektor']} • ${currencyFormatter.format(stockPrice)}",
                          style: TextStyle(color: subTextColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormatter.format(amountTL),
                        style: const TextStyle(
                          color: Color(0xFF00C853),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectorChart(
    List portfolio,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    Color borderColor,
    bool isDark,
  ) {
    Map<String, double> sectorAmountMap = {};
    for (var item in portfolio) {
      String sector = item['Sektor'] ?? 'Diğer';
      double weight = (item['Onerilen_Agirlik'] ?? 0).toDouble();

      double amount = (_totalBalance * weight) / 100;
      sectorAmountMap[sector] = (sectorAmountMap[sector] ?? 0) + amount;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
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
          Text(
            "Sektörel Varlık Dağılımı",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex =
                              pieTouchResponse
                                  .touchedSection!
                                  .touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: List.generate(sectorAmountMap.length, (i) {
                      final isTouched = i == touchedIndex;
                      final radius = isTouched ? 60.0 : 50.0;

                      String sectorName = sectorAmountMap.keys.elementAt(i);
                      double amount = sectorAmountMap.values.elementAt(i);

                      double percentage = (amount / _totalBalance) * 100;

                      return PieChartSectionData(
                        color: _getSectorColor(sectorName),
                        value: amount,
                        title: isTouched ? '%${percentage.toInt()}' : '',
                        radius: radius,
                        titleStyle: const TextStyle(
                          fontSize: 14,
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
                        sectorAmountMap.length.toString(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Sektör",
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Column(
            children:
                sectorAmountMap.entries.map((entry) {
                  double percentage = (entry.value / _totalBalance) * 100;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getSectorColor(entry.key),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          entry.key,
                          style: TextStyle(color: subTextColor, fontSize: 14),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormatter.format(entry.value),
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "%${percentage.toStringAsFixed(1)}",
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
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

  Widget _buildComparisonChart(
    List portfolio,
    Color cardBg,
    Color textColor,
    Color borderColor,
    bool isDark,
  ) {
    final marketBarColor =
        isDark ? const Color(0xFF455A64) : const Color(0xFFCFD8DC);
    final gridColor =
        isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05);
    final labelColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    Map<String, double> mySectorValues = {};
    for (var item in portfolio) {
      String sector = item['Sektor'] ?? 'Diğer';
      double weight = (item['Onerilen_Agirlik'] ?? 0).toDouble();
      double performance = (item['Yillik_Getiri'] ?? 50.0).toDouble();

      double contributedValue = (weight * performance) / 100;
      mySectorValues[sector] = (mySectorValues[sector] ?? 0) + contributedValue;
    }

    Map<String, double> marketValues = {
      'Teknoloji': 60.0,
      'Enerji': 50.0,
      'Bankacılık': 80.0,
      'Havacılık': 40.0,
      'Sanayi': 55.0,
      'Diğer': 30.0,
    };

    List<String> labels = mySectorValues.keys.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
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
              Text(
                "Performans Analizi",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.insights, color: primaryGreen, size: 20),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine:
                      (value) => FlLine(
                        color: gridColor,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                  getDrawingVerticalLine:
                      (value) => FlLine(
                        color: gridColor,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox();
                        }
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
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 20,
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
                      width: 1,
                    ),
                    left: BorderSide(
                      color: labelColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor:
                        (group) =>
                            isDark ? const Color(0xFF1E293B) : Colors.white,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    tooltipRoundedRadius: 8,
                    tooltipBorder: BorderSide(color: borderColor, width: 1),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label = rodIndex == 0 ? "Piyasa" : "Portföy";
                      final tooltipTextColor =
                          isDark ? Colors.white : Colors.black;

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
                barGroups: List.generate(labels.length, (index) {
                  String sector = labels[index];
                  double myValue = mySectorValues[sector] ?? 0;
                  double marketValue = marketValues[sector] ?? 50.0;

                  return BarChartGroupData(
                    x: index,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: marketValue,
                        color: marketBarColor,
                        width: 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                      BarChartRodData(
                        toY: myValue.clamp(0, 100),
                        color: primaryGreen,
                        width: 14,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          topRight: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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

  Widget _buildNoDataPlaceholder(Color cardBg, Color subTextColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 48,
              color: subTextColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              "Analiz verisi bulunamadı.\nLütfen profilinizden testi tamamlayın.",
              textAlign: TextAlign.center,
              style: TextStyle(color: subTextColor),
            ),
          ],
        ),
      ),
    );
  }
}
