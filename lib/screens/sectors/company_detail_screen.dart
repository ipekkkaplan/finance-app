import 'package:flutter/material.dart';

class CompanyDetailScreen extends StatefulWidget {
  // ARTIK TEK BİR TİCKER YERİNE, SEKTÖR ADI VE ŞİRKET LİSTESİ ALIYORUZ
  final String sectorName;
  final List<Map<String, dynamic>> companies;
  final int initialIndex;

  const CompanyDetailScreen({
    super.key,
    required this.sectorName,
    required this.companies,
    this.initialIndex = 0,
  });

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late int _selectedCompanyIndex;
  int _selectedTabIndex = 0; // 0: AI Özet, 1: Finansal, 2: Teknik

  // Marka Renkleri
  final Color primary = const Color(0xFF3D8BFF);
  final Color green = const Color(0xFF00C853);
  final Color red = const Color(0xFFFF5252);

  @override
  void initState() {
    super.initState();
    // İlk açılışta hangi şirketin seçili geleceğini belirliyoruz
    _selectedCompanyIndex = widget.initialIndex;
  }

  // Şu an seçili olan şirketin verisine kolay erişim
  Map<String, dynamic> get currentCompany => widget.companies[_selectedCompanyIndex];

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
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.3);

    // --- SEÇİLİ ŞİRKET VERİLERİNİ HAZIRLAMA ---
    // JSON'da veri eksik olsa bile hata vermemesi için "?? '...'" ile varsayılan değer atıyoruz
    final String ticker = currentCompany['ticker'] ?? '???';
    final String companyName = currentCompany['name'] ?? ticker;

    // Fiyat verisi JSON'da varsa al, yoksa simüle et (Mock)
    final String currentPrice = currentCompany['currentPrice']?.toString() ?? '142.5';
    final double changeRate = double.tryParse(currentCompany['changeRate']?.toString() ?? '1.25') ?? 0.0;

    // Şirkete özel detay verisi (AI Yorumu vb. simüle ediyoruz)
    final Map<String, dynamic> mockDetails = _getMockDetails(ticker);

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
          widget.sectorName, // Başlık artık Sektör Adı
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- 1. DİNAMİK ŞİRKET SEÇİM BUTONLARI (CHIPS) ---
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.companies.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Map<String, dynamic> company = entry.value;
                  bool isSelected = idx == _selectedCompanyIndex;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCompanyIndex = idx;
                      });
                    },
                    child: _buildTopChip(
                      company['ticker'] ?? '',
                      isSelected: isSelected,
                      cardColor: cardColor,
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. ŞİRKET ÖZET KARTI ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
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
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                companyName,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
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
                      ),
                      const Icon(Icons.star_border, color: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$ticker • ${widget.sectorName}",
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  // Fiyat ve Değişim
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "$currentPrice ₺",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${changeRate >= 0 ? '+' : ''}%$changeRate",
                        style: TextStyle(
                          color: changeRate >= 0 ? green : red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
            // İçeriğe seçili şirketin verilerini (mockDetails) gönderiyoruz
            if (_selectedTabIndex == 0) _buildAISummaryTab(mockDetails['aiSummary'], cardColor, textColor, subTextColor, isDark),
            if (_selectedTabIndex == 1) _buildFinancialTab(cardColor, textColor, subTextColor, borderColor, isDark),
            if (_selectedTabIndex == 2) _buildTechnicalTab(ticker, cardColor, textColor, isDark, borderColor),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET YAPICILAR (BUILDERS) ---

  Widget _buildAISummaryTab(String summary, Color cardColor, Color textColor, Color? subTextColor, bool isDark) {
    // AI Tabı için özel arka plan
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
          // Dinamik gelen metin buraya yazılıyor
          Text(
            summary,
            style: TextStyle(color: textColor, height: 1.5),
          ),
          const SizedBox(height: 24),
          // Güçlü Yönler (Sabit Örnek)
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
        ],
      ),
    );
  }

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
              _buildHorizontalBar("Likidite", 0.7, subTextColor, borderColor),
              const SizedBox(height: 12),
              _buildHorizontalBar("Karlılık", 0.6, subTextColor, borderColor),
              const SizedBox(height: 12),
              _buildHorizontalBar("Borç Oranı", 0.4, subTextColor, borderColor),
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

  Widget _buildTechnicalTab(String ticker, Color cardColor, Color textColor, bool isDark, Color borderColor) {
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
                "$ticker - 6 Aylık Tahmin",
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
        // ... (Diğer teknik detaylar eklenebilir)
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
          color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index, Color textColor) {
    bool isSelected = _selectedTabIndex == index;
    final color = isSelected ? textColor : textColor.withValues(alpha: 0.5);

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

  // --- MOCK DATA (Şirket değiştiğinde metinleri değiştirmek için) ---
  Map<String, dynamic> _getMockDetails(String ticker) {
    switch (ticker) {
      case 'THYAO':
        return {
          'aiSummary': 'Türk Hava Yolları, yaz sezonu beklentileri ve artan yolcu trafiği ile güçlü bir görünüm sergiliyor. Yakıt maliyetlerindeki değişimler marjları etkileyebilir.'
        };
      case 'PGSUS':
        return {
          'aiSummary': 'Pegasus, düşük maliyetli iş modeli sayesinde operasyonel verimliliğini koruyor. Yeni uçak siparişleri büyüme potansiyelini destekliyor.'
        };
      case 'ASELS':
        return {
          'aiSummary': 'ASELSAN, artan savunma sanayi harcamaları ve yeni ihracat anlaşmaları ile backlogunu büyütmeye devam ediyor.'
        };
      case 'KCHOL':
        return {
          'aiSummary': 'Koç Holding, çeşitlendirilmiş portföyü, enerji ve otomotiv grubundaki güçlü nakit akışı ile sağlam duruşunu koruyor.'
        };
      default:
        return {
          'aiSummary': '$ticker güçlü bir finansal yapıya sahip ancak piyasa koşulları yakından takip edilmeli. Şirketin büyüme potansiyeli sektör ortalamasının üzerinde.'
        };
    }
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

    // Izgara Çizgileri
    double stepX = size.width / 5;
    for (int i = 0; i <= 5; i++) {
      canvas.drawLine(Offset(i * stepX, 0), Offset(i * stepX, size.height), gridPaint);
    }
    double stepY = size.height / 4;
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(Offset(0, i * stepY), Offset(size.width, i * stepY), gridPaint);
    }

    final Path path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.2, size.height * 0.65);
    path.lineTo(size.width * 0.4, size.height * 0.75);
    path.lineTo(size.width * 0.6, size.height * 0.45);
    path.lineTo(size.width * 0.8, size.height * 0.30);
    path.lineTo(size.width, size.height * 0.20);

    canvas.drawPath(path, linePaint);

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