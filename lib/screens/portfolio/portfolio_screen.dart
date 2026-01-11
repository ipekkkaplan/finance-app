import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_app/screens/home/home_screen.dart'; // Yolunuza göre değişebilir
import 'package:intl/intl.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late Stream<DocumentSnapshot> _portfolioStream;

  // Varsayılan değer, veri gelene kadar veya veri yoksa kullanılır.
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

  @override
  void initState() {
    super.initState();
    _portfolioStream = FirebaseFirestore.instance
        .collection('user_match')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots();
  }

  // Bottom Sheet Yapısı
  void _showEditBalanceDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController(
      text: _totalBalance.toStringAsFixed(0),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final bgColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
        final textColor = isDark ? Colors.white : Colors.black;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tutamaç Çizgisi
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const Text(
                  "Toplam Varlığını Gir",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),

                // Büyük Input Alanı
                TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: "0",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white12 : Colors.grey[200],
                    ),
                    suffixText: "₺",
                    suffixStyle: TextStyle(
                      color: primaryGreen,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  autofocus: true,
                ),

                const SizedBox(height: 24),

                // Hızlı Seçim Butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildQuickActionChip(context, "100.000", controller),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(context, "250.000", controller),
                    const SizedBox(width: 8),
                    _buildQuickActionChip(context, "500.000", controller),
                  ],
                ),

                const SizedBox(height: 32),

                // Kaydet Butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      String cleanText = controller.text.replaceAll(',', '.');
                      double? newValue = double.tryParse(cleanText);

                      Navigator.pop(context);

                      if (newValue != null && newValue >= 0) {
                        try {
                          await FirebaseFirestore.instance
                              .collection('user_match')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .set({
                            'totalBalance': newValue,
                          }, SetOptions(merge: true));
                        } catch (e) {
                          debugPrint("Bakiye kaydedilirken hata: $e");
                        }
                      }
                    },
                    child: const Text(
                      "Bakiyeyi Güncelle",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hızlı seçim helper widget'ı
  Widget _buildQuickActionChip(
      BuildContext context,
      String value,
      TextEditingController controller,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        controller.text = value.replaceAll('.', '');
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
          isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey[300]!,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color? _getKnownSectorColor(String? sector) {
    switch (sector?.trim().toLowerCase()) {
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
        return null;
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

    final borderColor = isDark
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: _portfolioStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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

                if (portfolio.isEmpty)
                  _buildNoDataPlaceholder(cardColor, subTextColor)
                else
                  Column(
                    children: [
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
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
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
            color: isDark
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
                  Icons.edit,
                  size: 18,
                  color: subTextColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Planladığınız tutarı giriniz",
            style: TextStyle(
              color: subTextColor.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
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
    Map<String, double> assetAmountMap = {};
    Map<String, String> assetSectorMap = {};

    for (var item in portfolio) {
      String stockName = item['Hisse']?.toString().trim() ?? 'Bilinmeyen';
      String sector = item['Sektor']?.toString().trim() ?? '';

      double weight =
          double.tryParse(item['Onerilen_Agirlik'].toString()) ?? 0.0;

      double amount = (_totalBalance * weight) / 100;
      assetAmountMap[stockName] = (assetAmountMap[stockName] ?? 0) + amount;
      assetSectorMap[stockName] = sector;
    }

    final List<MapEntry<String, double>> sortedAssets =
    assetAmountMap.entries.toList();
    sortedAssets.sort((a, b) => b.value.compareTo(a.value));

    final List<Color> fallbackPalette = [
      primaryBlue,
      primaryGreen,
      primaryYellow,
      primaryPurple,
      Colors.orange,
      Colors.redAccent,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
    ];

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
            "Varlık Dağılımı",
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
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    sections: List.generate(sortedAssets.length, (i) {
                      final isTouched = i == touchedIndex;
                      final radius = isTouched ? 60.0 : 50.0;

                      final entry = sortedAssets[i];
                      final stockName = entry.key;
                      final amount = entry.value;

                      String sectorOfStock = assetSectorMap[stockName] ?? '';
                      Color sliceColor =
                          _getKnownSectorColor(sectorOfStock) ??
                              fallbackPalette[i % fallbackPalette.length];

                      double percentage = (amount / _totalBalance) * 100;

                      return PieChartSectionData(
                        color: sliceColor,
                        value: amount,
                        title: '%${percentage.toStringAsFixed(0)}',
                        radius: radius,
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
                        sortedAssets.length.toString(),
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
          Column(
            children: sortedAssets.asMap().entries.map((entry) {
              int index = entry.key;
              MapEntry<String, double> data = entry.value;

              String sectorOfStock = assetSectorMap[data.key] ?? '';
              Color legendColor = _getKnownSectorColor(sectorOfStock) ??
                  fallbackPalette[index % fallbackPalette.length];

              double percentage = (data.value / _totalBalance) * 100;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  // --- GÜNCELLENEN GRAFİK KISMI ---
  Widget _buildComparisonChart(
      List portfolio,
      Color cardBg,
      Color textColor,
      Color borderColor,
      bool isDark,
      ) {
    // Piyasa ortalaması renk tanımı kaldırıldı, artık gerek yok.
    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.05);
    final labelColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    Map<String, double> mySectorValues = {};
    for (var item in portfolio) {
      String sector = item['Sektor']?.toString().trim() ?? 'Diğer';

      double weight =
          double.tryParse(item['Onerilen_Agirlik'].toString()) ?? 0.0;
      double performance =
          double.tryParse(item['Yillik_Getiri'].toString()) ?? 50.0;

      double contributedValue = (weight * performance) / 100;
      mySectorValues[sector] = (mySectorValues[sector] ?? 0) + contributedValue;
    }

    // Piyasa değerleri (marketValues) haritasını sildik çünkü kullanmayacağız.

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
                maxY: 40, // --- GÜNCELLEME: Y ekseni max 40 yapıldı ---
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: gridColor,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
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
                      interval: 10, // Aralıkları da 10'a düşürdük
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
                    getTooltipColor: (group) =>
                    isDark ? const Color(0xFF1E293B) : Colors.white,
                    tooltipPadding: const EdgeInsets.all(12),
                    tooltipMargin: 8,
                    tooltipRoundedRadius: 8,
                    tooltipBorder: BorderSide(color: borderColor, width: 1),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      // Artık sadece tek bar olduğu için "Portföy" yazdırıyoruz
                      String label = "Portföy";
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
                            // Gerçek değeri gösteriyoruz (40'tan büyük olsa bile)
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

                  return BarChartGroupData(
                    x: index,
                    // barsSpace artık gerekli değil çünkü tek çubuk var
                    barRods: [
                      // --- GÜNCELLEME: Sadece tek bir rod (yeşil) kaldı ---
                      BarChartRodData(
                        // Görsel olarak 40'ı taşmasın diye clamp kullanabiliriz
                        // ama fl_chart genelde halleder. Yine de max 40 dedik.
                        toY: myValue,
                        color: primaryGreen,
                        width: 24, // Çubuğu biraz kalınlaştırdık (daha şık durur)
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

              _buildLegendItem("Portföyüm", primaryGreen, isDark),
            ],
          ),
        ],
      ),
    );
  }
  // --- END OF CHART UPDATE ---

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