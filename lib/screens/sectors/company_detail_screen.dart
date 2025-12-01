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

  // Marka Renkleri (Sabit kalabilir)
  final Color primary = const Color(0xFF3D8BFF);
  final Color green = const Color(0xFF00C853);

  @override
  Widget build(BuildContext context) {
    // Tema verilerini alıyoruz
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dinamik renkler
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final iconColor = theme.iconTheme.color ?? textColor;

    // Border ve Divider renkleri
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.3);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Sektörler",
          style: TextStyle(color: textColor, fontSize: 18),
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
                  _buildTopChip(widget.ticker, isSelected: true, cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark),
                  _buildTopChip("THYAO", isSelected: false, cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark),
                  _buildTopChip("GARAN", isSelected: false, cardColor: cardColor, textColor: textColor, borderColor: borderColor, isDark: isDark),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- ŞİRKET ÖZET KARTI ---
            Container(
              padding: const EdgeInsets.all(20),
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
                            widget.companyName,
                            style: TextStyle(
                              color: textColor,
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
                              color: green.withValues(alpha: 0.15),
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
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "32.5B ₺",
                    style: TextStyle(
                      color: textColor,
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
                            side: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[400]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Karşılaştır",
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[400]!),
                        ),
                        child: Icon(
                          Icons.download,
                          color: textColor,
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
                _buildTabButton("AI Özet", 0, textColor),
                const SizedBox(width: 20),
                _buildTabButton("Finansal", 1, textColor),
                const SizedBox(width: 20),
                _buildTabButton("Teknik", 2, textColor),
              ],
            ),
            const SizedBox(height: 20),

            // --- TAB İÇERİK DEĞİŞTİRİCİ ---
            if (_selectedTabIndex == 0) _buildAISummaryTab(cardColor, textColor, subTextColor, isDark),
            if (_selectedTabIndex == 1) _buildFinancialTab(cardColor, textColor, subTextColor, borderColor, isDark),
            if (_selectedTabIndex == 2) _buildTechnicalTab(cardColor, textColor, isDark, borderColor),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAISummaryTab(Color cardColor, Color textColor, Color? subTextColor, bool isDark) {
    // AI Tabı için özel arka plan (Dark mode: Koyu Mavi, Light Mode: Açık Mavi)
    final aiCardBg = isDark ? const Color(0xFF0D1B3E) : Colors.blue.shade50;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: aiCardBg,
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
          Text(
            "ASELS güçlü borç yönetimine sahip ancak orta düzeyde gelir büyümesi göstermektedir. Savunma sanayi portföyü ve AR-GE yatırımları pozitif sinyal veriyor.",
            style: TextStyle(color: textColor, height: 1.5),
          ),
          const SizedBox(height: 24),
          // Güçlü Yönler
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? cardColor.withValues(alpha: 0.5) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Güçlü Yönler", style: TextStyle(color: subTextColor)),
                const SizedBox(height: 8),
                _buildBulletPoint("Güçlü borç yönetimi", green, textColor),
                const SizedBox(height: 8),
                _buildBulletPoint("Yüksek AR-GE yatırımları", green, textColor),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Dikkat Edilmesi Gerekenler
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? cardColor.withValues(alpha: 0.5) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dikkat Edilmesi Gerekenler",
                  style: TextStyle(color: subTextColor),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint("Orta düzey gelir büyümesi", Colors.amber, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. TAB: FİNANSAL İÇERİK

  Widget _buildFinancialTab(Color cardColor, Color textColor, Color? subTextColor, Color borderColor, bool isDark) {
    return Column(
      children: [
        // Grafik Kartı
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Finansal Göstergeler",
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                  Icon(Icons.info_outline, color: subTextColor, size: 18),
                ],
              ),
              const SizedBox(height: 20),
              _buildHorizontalBar("Likidite", 0.1, subTextColor, borderColor),
              const SizedBox(height: 12),
              _buildHorizontalBar("Karlılık", 0.6, subTextColor, borderColor),
              const SizedBox(height: 12),
              _buildHorizontalBar("Borç Oranı", 0.9, subTextColor, borderColor),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("0", style: TextStyle(color: subTextColor, fontSize: 12)),
                  Text("9", style: TextStyle(color: subTextColor, fontSize: 12)),
                  Text("18", style: TextStyle(color: subTextColor, fontSize: 12)),
                  Text("27", style: TextStyle(color: subTextColor, fontSize: 12)),
                  Text("36", style: TextStyle(color: subTextColor, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Alt Metrik Kartları
        Row(
          children: [
            _buildFinancialMetricCard("Likidite", "2.8", "İyi", cardColor, textColor, subTextColor, borderColor),
            const SizedBox(width: 12),
            _buildFinancialMetricCard("Karlılık", "18.4%", "Yüksek", cardColor, textColor, subTextColor, borderColor),
            const SizedBox(width: 12),
            _buildFinancialMetricCard("Borç", "35%", "Düşük", cardColor, textColor, subTextColor, borderColor),
          ],
        ),
      ],
    );
  }

  // 3. TAB: TEKNİK İÇERİK

  Widget _buildTechnicalTab(Color cardColor, Color textColor, bool isDark, Color borderColor) {
    return Column(
      children: [
        // 6 Aylık Tahmin Grafiği
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "6 Aylık Tahmin",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(
                  painter: SimpleLineChartPainter(lineColor: green, isDark: isDark),
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
            color: isDark ? const Color(0xFF0D1B3E) : Colors.blue.shade50, // AI Kartı
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
              Text(
                "Mevcut RSI kısa vadeli konsolidasyona işaret ediyor. Destek seviyesi 138₺ civarında.",
                style: TextStyle(color: textColor, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text("RSI: ", style: TextStyle(color: isDark ? Colors.grey : Colors.grey[700])),
                  Text(
                    "58 ",
                    style: TextStyle(
                      color: textColor,
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
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "AI Risk Skoru",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "92/100",
                    style: TextStyle(
                      color: const Color(0xFF00C853),
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
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                  color: green,
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Yüksek skor daha iyi finansal sağlığı gösterir",
                style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- YARDIMCI WIDGET'LAR ---

  Widget _buildTopChip(String text, {required bool isSelected, required Color cardColor, required Color textColor, required Color borderColor, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? green : cardColor,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          // Seçiliyse (yeşilse) yazı siyah, değilse dinamik text rengi (beyaz/siyah)
          color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index, Color textColor) {
    bool isSelected = _selectedTabIndex == index;
    // Seçili olmayanlar daha soluk
    final color = isSelected ? textColor : textColor.withOpacity(0.5);

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
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

  Widget _buildBulletPoint(String text, Color dotColor, Color textColor) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6, color: dotColor),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: textColor)),
      ],
    );
  }

  Widget _buildHorizontalBar(String label, double percent, Color? subTextColor, Color borderColor) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(color: subTextColor, fontSize: 12),
          ),
        ),
        Expanded(
          child: Container(
            height: 30,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border(
                left: BorderSide(color: borderColor, width: 1),
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

  Widget _buildFinancialMetricCard(String title, String value, String status, Color cardColor, Color textColor, Color? subTextColor, Color borderColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: subTextColor, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: textColor,
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
  final bool isDark;
  SimpleLineChartPainter({required this.lineColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint =
    Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final Paint gridPaint =
    Paint()
      ..color = isDark ? Colors.grey.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1)
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

    // Noktalar
    final points = [
      Offset(0, size.height * 0.8),
      Offset(size.width * 0.2, size.height * 0.65),
      Offset(size.width * 0.4, size.height * 0.75),
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.30),
      Offset(size.width, size.height * 0.20)
    ];

    for (var point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}