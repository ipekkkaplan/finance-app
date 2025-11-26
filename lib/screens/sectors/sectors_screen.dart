import 'package:finance_app/core/theme/colors.dart';
import 'package:finance_app/screens/sectors/company_detail_screen.dart';
import 'package:flutter/material.dart';

class SectorsScreen extends StatefulWidget {
  const SectorsScreen({super.key});

  @override
  State<SectorsScreen> createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> {
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> sectorsData = [
    {
      "name": "Teknoloji",
      "tag": "Yüksek",
      "change": "+24.5%",
      "companies": "ASELS • LOGO • Karel",
      "metrics": ["3.8", "18.2%", "+34.7%"],
      "grade": "A",
    },
    {
      "name": "Bankacılık",
      "tag": "Orta",
      "change": "+15.3%",
      "companies": "GARAN • AKBNK • ISCTR",
      "metrics": ["2.9", "22.5%", "+18.4%"],
      "grade": "B+",
    },
    {
      "name": "Enerji",
      "tag": "Yüksek",
      "change": "+28.7%",
      "companies": "TUPRS • ENKAI • AKENR",
      "metrics": ["3.2", "16.8%", "+29.3%"],
      "grade": "A-",
    },
    {
      "name": "İmalat",
      "tag": "Orta",
      "change": "+12.4%",
      "companies": "EREGL • KRDMD • TOASO",
      "metrics": ["2.5", "14.3%", "+15.2%"],
      "grade": "B",
    },
    {
      "name": "Perakende",
      "tag": "Orta",
      "change": "+19.8%",
      "companies": "BIMAS • MGROS • SOKM",
      "metrics": ["2.8", "11.7%", "+21.5%"],
      "grade": "B+",
    },
    {
      "name": "Havacılık",
      "tag": "Yüksek",
      "change": "+31.2%",
      "companies": "THYAO • PGSUS • CLEBI",
      "metrics": ["3.5", "24.1%", "+42.8%"],
      "grade": "A",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bool isDark = theme.brightness == Brightness.dark;

    final Color cardColor =
        isDark ? const Color(0xFF121A2D) : const Color(0xFFF2F3F6);

    final Color barColor =
        isDark ? AppColors.darkProfitGreen : const Color(0xFF1A2E55);

    final Color textColor = isDark ? Colors.white : Colors.black87;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sektör Analizi",
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Son 10 yıllık performans görünümü",
            style: TextStyle(color: isDark ? Colors.grey : Colors.black54),
          ),
          const SizedBox(height: 20),

          // --- GRAFİK KUTUSU ---
          _chartCard(cardColor, barColor, textColor, isDark),

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

          Row(
            children: [
              _filterButton("Tümü", 0, theme),
              const SizedBox(width: 10),
              _filterButton("Yüksek", 1, theme),
              const SizedBox(width: 10),
              _filterButton("Orta", 2, theme),
            ],
          ),

          const SizedBox(height: 16),

          ...sectorsData.map(
            (sector) =>
                _sectorCard(sector, theme, cardColor, textColor, isDark),
          ),
        ],
      ),
    );
  }

  // --- Filtre Butonu ---
  Widget _filterButton(String label, int index, ThemeData theme) {
    final bool selected = index == _selectedFilterIndex;
    final bool isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              selected
                  ? theme.colorScheme.primary
                  : (isDark
                      ? const Color(0xFF1A2238)
                      : const Color(0xFFE0E0E5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:
                selected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- Grafik Kartı ---
  Widget _chartCard(
    Color cardColor,
    Color barColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            isDark
                ? []
                : const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sektör Performans Karşılaştırması",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bar("Teknoloji", 35, barColor),
                _bar("Bankacılık", 15, barColor),
                _bar("Enerji", 28, barColor),
                _bar("İmalat", 12, barColor),
                _bar("Perakende", 18, barColor),
                _bar("Havacılık", 40, barColor),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "Piyasa değeri büyümesi (%)",
              style: TextStyle(color: isDark ? Colors.grey : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, double heightFactor, Color barColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: heightFactor * 3,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  // --- Sektör Kartı ---
  Widget _sectorCard(
    Map<String, dynamic> s,
    ThemeData theme,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            !isDark
                ? const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
                : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //---------------- Üst Satır ------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s["name"],
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                s["change"],
                style: TextStyle(
                  color: ThemeAwareColors.profit(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            s["companies"],
            style: TextStyle(color: isDark ? Colors.grey : Colors.black54),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _metricBox("Z-Skor", s["metrics"][0], textColor, isDark),
              const SizedBox(width: 12),
              _metricBox("Karlılık", s["metrics"][1], textColor, isDark),
              const SizedBox(width: 12),
              _metricBox(
                "Büyüme",
                s["metrics"][2],
                textColor,
                isDark,
                isProfit: true,
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
                        (_) => CompanyDetailScreen(
                          companyName: "Aselsan Elektronik",
                          ticker: "ASELS",
                          sector: s["name"],
                        ),
                  ),
                );
              },
              icon: Text(
                "Şirketleri İncele",
                style: TextStyle(color: ThemeAwareColors.profit(context)),
              ),
              label: Icon(
                Icons.arrow_forward,
                color: ThemeAwareColors.profit(context),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricBox(
    String label,
    String value,
    Color textColor,
    bool isDark, {
    bool isProfit = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C253A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: isProfit ? ThemeAwareColors.profit(context) : textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
