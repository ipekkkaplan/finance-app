// screens/sectors/sectors_screen.dart
import 'package:finance_app/screens/sectors/company_detail_screen.dart';
import 'package:flutter/material.dart';

class SectorsScreen extends StatefulWidget {
  const SectorsScreen({super.key});

  @override
  State<SectorsScreen> createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> {
  int _selectedFilterIndex = 0; // Filtre butonu için
  final Color cardBg = const Color(0xFF0F162C);
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D193F),
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
                  const Text(
                    "Sektör Analizi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.filter_list, color: primary),
                ],
              ),
              const Text(
                "Son 10 yıllık performans görünümü",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 20),

              _buildChartPlaceholder(
                title: "Sektör Performans Karşılaştırması",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar("Teknoloji", 35, green),
                    _buildBar("Bankacılık", 15, green),
                    _buildBar("Enerji", 28, green),
                    _buildBar("İmalat", 12, green),
                    _buildBar("Perakende", 18, green),
                    _buildBar("Havacılık", 40, green),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildChartPlaceholder(
                title: "Sektör Trendleri (2020-2025)",
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  child: const Text(
                    "Burada 'fl_chart' ile yapılmış bir Çizgi Grafiği olacak.",
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Sektörler",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterButton("Tümü Potansiyel", 0),
                    _filterButton("Yüksek Potansiyel", 1),
                    _filterButton("Orta Potansiyel", 2),
                    _filterButton("Düşük Potansiyel", 3),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sektör kartları veya "Tanımlı veri yok"
              filteredSectors.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.center,
                child: const Text(
                  "Tanımlı veri yok",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
                  : Column(
                children: filteredSectors
                    .map((sector) => _buildSectorCard(sector))
                    .toList(),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 180, child: child),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "Piyasa değeri büyümesi (%)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double heightFactor, Color color) {
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
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }

  Widget _filterButton(String text, int index) {
    final isSelected = _selectedFilterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? green : cardBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectorCard(Map<String, dynamic> sector) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
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
                    style: const TextStyle(
                      color: Colors.white,
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
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(sector["companies"], style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            children: [
              _metricItem("Z-Skor", sector["metrics"][0]),
              const SizedBox(width: 12),
              _metricItem("Karlılık", sector["metrics"][1]),
              const SizedBox(width: 12),
              _metricItem("Büyüme", sector["metrics"][2], isGrowth: true),
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

  Widget _metricItem(String label, String value, {bool isGrowth = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2038),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: isGrowth ? green : Colors.white,
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
