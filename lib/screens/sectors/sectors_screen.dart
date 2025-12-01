import 'package:finance_app/screens/sectors/company_detail_screen.dart';
import 'package:flutter/material.dart';

class SectorsScreen extends StatefulWidget {
  const SectorsScreen({super.key});

  @override
  State<SectorsScreen> createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> {
  int _selectedFilterIndex = 0; // Filtre butonu için

  // Marka Renkleri (Sabit)
  final Color primary = const Color(0xFF3D8BFF);
  final Color green = const Color(0xFF00C853);

  final List<Map<String, dynamic>> sectorsData = [
    {
      "name": "Teknoloji",
      "tag": "Yüksek",
      "tagColor": const Color(0xFF00C853),
      "change": "+24.5%",
      "grade": "A",
      "companies": "ASELS • LOGO • Karel",
      "metrics": ["3.8", "18.2%", "+34.7%"],
    },
    {
      "name": "Bankacılık",
      "tag": "Orta",
      "tagColor": const Color(0xFF3D8BFF),
      "change": "+15.3%",
      "grade": "B+",
      "companies": "GARAN • AKBNK • ISCTR",
      "metrics": ["2.9", "22.5%", "+18.4%"],
    },
    {
      "name": "Enerji",
      "tag": "Yüksek",
      "tagColor": const Color(0xFF00C853),
      "change": "+28.7%",
      "grade": "A-",
      "companies": "TUPRS • ENKAI • AKENR",
      "metrics": ["3.2", "16.8%", "+29.3%"],
    },
    {
      "name": "İmalat",
      "tag": "Orta",
      "tagColor": const Color(0xFF3D8BFF),
      "change": "+12.4%",
      "grade": "B",
      "companies": "EREGL • KRDMD • TOASO",
      "metrics": ["2.5", "14.3%", "+15.2%"],
    },
    {
      "name": "Perakende",
      "tag": "Orta",
      "tagColor": const Color(0xFF3D8BFF),
      "change": "+19.8%",
      "grade": "B+",
      "companies": "BIMAS • MGROS • SOKM",
      "metrics": ["2.8", "11.7%", "+21.5%"],
    },
    {
      "name": "Havacılık",
      "tag": "Yüksek",
      "tagColor": const Color(0xFF00C853),
      "change": "+31.2%",
      "grade": "A",
      "companies": "THYAO • PGSUS • CLEBI",
      "metrics": ["3.5", "24.1%", "+42.8%"],
    },
  ];

  // --- Filtreleme mantığı ---
  List<Map<String, dynamic>> get filteredSectors {
    switch (_selectedFilterIndex) {
      case 0:
        return sectorsData; // Tümü
      case 1:
        return sectorsData.where((s) => s["tag"] == "Yüksek").toList();
      case 2:
        return sectorsData.where((s) => s["tag"] == "Orta").toList();
      case 3:
        return sectorsData.where((s) => s["tag"] == "Düşük").toList();
      default:
        return sectorsData;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema verilerini alıyoruz
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dinamik renkler
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = isDark ? Colors.grey : Colors.grey[600];

    // Kart kenarlığı (Light modda belirginleştirmek için)
    final borderColor = isDark ? Colors.transparent : Colors.grey.withValues(alpha: 0.2);
    // Metrik kutucukları (Z-Skor vb.) rengi
    final metricCardBg = isDark ? const Color(0xFF1A2038) : Colors.grey.shade100;

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
                "Son 10 yıllık performans görünümü",
                style: TextStyle(color: subTextColor, fontSize: 14),
              ),
              const SizedBox(height: 20),

              _buildChartPlaceholder(
                title: "Sektör Performans Karşılaştırması",
                bgColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                borderColor: borderColor,
                isDark: isDark,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar("Teknoloji", 35, green, subTextColor),
                    _buildBar("Bankacılık", 15, green, subTextColor),
                    _buildBar("Enerji", 28, green, subTextColor),
                    _buildBar("İmalat", 12, green, subTextColor),
                    _buildBar("Perakende", 18, green, subTextColor),
                    _buildBar("Havacılık", 40, green, subTextColor),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildChartPlaceholder(
                title: "Sektör Trendleri (2020-2025)",
                bgColor: cardColor,
                textColor: textColor,
                subTextColor: subTextColor,
                borderColor: borderColor,
                isDark: isDark,
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  child: Text(
                    "Burada 'fl_chart' ile yapılmış bir Çizgi Grafiği olacak.",
                    style: TextStyle(color: subTextColor),
                    textAlign: TextAlign.center,
                  ),
                ),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterButton("Tümü Potansiyel", 0, cardColor, textColor, isDark),
                    _filterButton("Yüksek Potansiyel", 1, cardColor, textColor, isDark),
                    _filterButton("Orta Potansiyel", 2, cardColor, textColor, isDark),
                    _filterButton("Düşük Potansiyel", 3, cardColor, textColor, isDark),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sektör kartları veya "Tanımlı veri yok"
              filteredSectors.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: Text(
                  "Tanımlı veri yok",
                  style: TextStyle(color: subTextColor, fontSize: 16),
                ),
              )
                  : Column(
                children: filteredSectors
                    .map((sector) => _buildSectorCard(
                  sector,
                  cardColor,
                  textColor,
                  subTextColor,
                  metricCardBg,
                  borderColor,
                  isDark,
                ))
                    .toList(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder({
    required String title,
    required Widget child,
    required Color bgColor,
    required Color textColor,
    required Color? subTextColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 180, child: child),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "Piyasa değeri büyümesi (%)",
              style: TextStyle(color: subTextColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightFactor, Color color, Color? labelColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: heightFactor * 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: labelColor, fontSize: 10)),
      ],
    );
  }

  Widget _filterButton(String text, int index, Color cardColor, Color textColor, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    // Seçili değilse Light modda açık gri, Dark modda kart rengi
    final unselectedBg = isDark ? cardColor : Colors.grey.shade200;
    // Seçili değilse yazı rengi
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

  Widget _buildSectorCard(
      Map<String, dynamic> sector,
      Color cardColor,
      Color textColor,
      Color? subTextColor,
      Color metricBgColor,
      Color borderColor,
      bool isDark,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
          ]
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
                    sector["name"],
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: sector["tagColor"].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sector["tag"],
                      style: TextStyle(color: sector["tagColor"], fontSize: 12),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    sector["change"],
                    style: TextStyle(color: green, fontSize: 16),
                  ),
                  Text(
                    sector["grade"],
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(sector["companies"], style: TextStyle(color: subTextColor)),
          const SizedBox(height: 20),
          Row(
            children: [
              _metricItem("Z-Skor", sector["metrics"][0], metricBgColor, textColor, subTextColor),
              const SizedBox(width: 12),
              _metricItem("Karlılık", sector["metrics"][1], metricBgColor, textColor, subTextColor),
              const SizedBox(width: 12),
              _metricItem("Büyüme", sector["metrics"][2], metricBgColor, textColor, subTextColor, isGrowth: true),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompanyDetailScreen(
                      companyName: "Aselsan Elektronik",
                      ticker: "ASELS",
                      sector: sector["name"],
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

  Widget _metricItem(String label, String value, Color bgColor, Color textColor, Color? labelColor, {bool isGrowth = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: labelColor, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: isGrowth ? green : textColor,
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