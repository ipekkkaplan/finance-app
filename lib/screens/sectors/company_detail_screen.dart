// screens/sectors/company_detail_screen.dart
import 'package:flutter/material.dart';

class CompanyDetailScreen extends StatefulWidget {
  final String companyName;
  final String ticker;
  final String sector;

  const CompanyDetailScreen({
    super.key,
    required this.companyName,
    required this.ticker,
    required this.sector,
  });

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  int _selectedTabIndex = 0; // 0: AI Özet, 1: Finansal, 2: Teknik

  final Color darkBg = const Color(0xFF0A0F24);
  final Color cardBg = const Color(0xFF0F162C);
  final Color primary = const Color(0xFF3D8BFF);
  final Color green = const Color(0xFF00C853);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Sektörler",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ÜSTTEKİ CHIP LISTESI ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTopChip(widget.ticker, isSelected: true),
                  _buildTopChip("THYAO", isSelected: false),
                  _buildTopChip("GARAN", isSelected: false),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- ŞİRKET ÖZET KARTI ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                            widget.companyName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "A+",
                              style: TextStyle(
                                color: green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.star_border, color: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${widget.ticker} • ${widget.sector}",
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "32.5B ₺",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "İzleme Listesi",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[700]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Karşılaştır",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: const Icon(
                          Icons.download,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- TAB MENÜ ---
            Row(
              children: [
                _buildTabButton("AI Özet", 0),
                const SizedBox(width: 20),
                _buildTabButton("Finansal", 1),
                const SizedBox(width: 20),
                _buildTabButton("Teknik", 2),
              ],
            ),
            const SizedBox(height: 20),

            // --- TAB İÇERİK DEĞİŞTİRİCİ ---
            if (_selectedTabIndex == 0) _buildAISummaryTab(),
            if (_selectedTabIndex == 1) _buildFinancialTab(),
            if (_selectedTabIndex == 2) _buildTechnicalTab(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAISummaryTab() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B3E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: primary, size: 18),
              const SizedBox(width: 8),
              Text(
                "AI Şirket Analizi",
                style: TextStyle(
                  color: primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "ASELS güçlü borç yönetimine sahip ancak orta düzeyde gelir büyümesi göstermektedir. Savunma sanayi portföyü ve AR-GE yatırımları pozitif sinyal veriyor.",
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
          const SizedBox(height: 24),
          // Güçlü Yönler
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Güçlü Yönler", style: TextStyle(color: Colors.grey[400])),
                const SizedBox(height: 8),
                _buildBulletPoint("Güçlü borç yönetimi", green),
                const SizedBox(height: 8),
                _buildBulletPoint("Yüksek AR-GE yatırımları", green),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Dikkat Edilmesi Gerekenler
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dikkat Edilmesi Gerekenler",
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint("Orta düzey gelir büyümesi", Colors.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. TAB: FİNANSAL İÇERİK (Görselindeki Tasarım)

  Widget _buildFinancialTab() {
    return Column(
      children: [
        // Grafik Kartı
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Finansal Göstergeler",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Icon(Icons.info_outline, color: Colors.grey, size: 18),
                ],
              ),
              const SizedBox(height: 20),
              _buildHorizontalBar("Likidite", 0.1),
              const SizedBox(height: 12),
              _buildHorizontalBar("Karlılık", 0.6),
              const SizedBox(height: 12),
              _buildHorizontalBar("Borç Oranı", 0.9),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "0",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    "9",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    "18",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    "27",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    "36",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Alt Metrik Kartları
        Row(
          children: [
            _buildFinancialMetricCard("Likidite", "2.8", "İyi"),
            const SizedBox(width: 12),
            _buildFinancialMetricCard("Karlılık", "18.4%", "Yüksek"),
            const SizedBox(width: 12),
            _buildFinancialMetricCard("Borç", "35%", "Düşük"),
          ],
        ),
      ],
    );
  }

  // 3. TAB: TEKNİK İÇERİK (Görselindeki Tasarım)

  Widget _buildTechnicalTab() {
    return Column(
      children: [
        // 6 Aylık Tahmin Grafiği
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "6 Aylık Tahmin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(
                  painter: SimpleLineChartPainter(lineColor: green),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // AI Teknik Yorum
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B3E), // Koyu mavi
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "AI Teknik Yorum",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Mevcut RSI kısa vadeli konsolidasyona işaret ediyor. Destek seviyesi 138₺ civarında.",
                style: TextStyle(color: Colors.white, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("RSI: ", style: TextStyle(color: Colors.grey)),
                  const Text(
                    "58 ",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "Nötr",
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // AI Risk Skoru
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "AI Risk Skoru",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "92/100",
                    style: TextStyle(
                      color: Color(0xFF00C853),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: 0.92,
                  backgroundColor: Colors.grey[800],
                  color: green,
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Yüksek skor daha iyi finansal sağlığı gösterir",
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- YARDIMCI WIDGET'LAR ---

  Widget _buildTopChip(String text, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? green : cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: Colors.grey[800]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.grey[400],
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected) Container(width: 20, height: 2, color: primary),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color dotColor) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6, color: dotColor),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildHorizontalBar(String label, double percent) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                left: BorderSide(color: Colors.grey[800]!, width: 1),
              ),
            ),
            child: FractionallySizedBox(
              widthFactor: percent,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialMetricCard(String title, String value, String status) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(status, style: TextStyle(color: green, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class SimpleLineChartPainter extends CustomPainter {
  final Color lineColor;
  SimpleLineChartPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final Paint gridPaint =
        Paint()
          ..color = Colors.grey.withValues(alpha: 0.2)
          ..strokeWidth = 1;

    final Paint dotPaint = Paint()..color = lineColor;

    // Izgara Çizgileri (Dikey)
    double stepX = size.width / 5;
    for (int i = 0; i <= 5; i++) {
      canvas.drawLine(
        Offset(i * stepX, 0),
        Offset(i * stepX, size.height),
        gridPaint,
      );
    }
    // Izgara Çizgileri (Yatay)
    double stepY = size.height / 4;
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(0, i * stepY),
        Offset(size.width, i * stepY),
        gridPaint,
      );
    }

    final Path path = Path();
    path.moveTo(0, size.height * 0.8); // Başlangıç
    path.lineTo(size.width * 0.2, size.height * 0.65);
    path.lineTo(size.width * 0.4, size.height * 0.75);
    path.lineTo(size.width * 0.6, size.height * 0.45);
    path.lineTo(size.width * 0.8, size.height * 0.30);
    path.lineTo(size.width, size.height * 0.20); // Bitiş

    canvas.drawPath(path, linePaint);

    canvas.drawCircle(Offset(0, size.height * 0.8), 4, dotPaint);
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.65),
      4,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.75),
      4,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.45),
      4,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.30),
      4,
      dotPaint,
    );
    canvas.drawCircle(Offset(size.width, size.height * 0.20), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
