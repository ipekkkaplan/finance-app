import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/services/portfolio_provider.dart';

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
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bg = theme.scaffoldBackgroundColor;
    final cardBg =
        theme.brightness == Brightness.dark
            ? const Color(0xFF0F162C)
            : const Color(0xFFEFEFEF);

    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    final secondaryText =
        theme.brightness == Brightness.dark ? Colors.grey[400] : Colors.black54;

    final primary = theme.colorScheme.primary;
    final green = const Color(0xFF00C853);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip(widget.ticker, true),
                  _chip("THYAO", false),
                  _chip("GARAN", false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow:
                    theme.brightness == Brightness.light
                        ? [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ]
                        : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ÜST BAŞLIK
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
                              color: green.withOpacity(0.2),
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
                    style: TextStyle(color: secondaryText, fontSize: 14),
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
                        child: Builder(
                          builder: (context) {
                            final portfolio = Provider.of<PortfolioProvider>(
                              context,
                            );
                            final isAdded = portfolio.isInPortfolio(
                              widget.ticker,
                            );

                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isAdded
                                        ? Colors.redAccent
                                        : const Color(0xFF00C853),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () async {
                                final item = PortfolioItem(
                                  companyName: widget.companyName,
                                  ticker: widget.ticker,
                                  sector: widget.sector,
                                );

                                await portfolio.toggle(item);

                                final nowAdded = portfolio.isInPortfolio(
                                  widget.ticker,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      nowAdded
                                          ? 'Portföye eklendi'
                                          : 'Portföyden çıkarıldı',
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Text(
                                isAdded ? "Portföyden Çıkart" : "Portföye Ekle",
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      /// KARŞILAŞTIR
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color:
                                  theme.brightness == Brightness.dark
                                      ? Colors.grey[700]!
                                      : Colors.black54,
                            ),
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

                      /// İNDİR ICONU
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                theme.brightness == Brightness.dark
                                    ? Colors.grey[700]!
                                    : Colors.black54,
                          ),
                        ),
                        child: Icon(Icons.download, color: textColor, size: 20),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// --- TAB MENÜ ---
                  Row(
                    children: [
                      _tabButton("AI Özet", 0),
                      const SizedBox(width: 20),
                      _tabButton("Finansal", 1),
                      const SizedBox(width: 20),
                      _tabButton("Teknik", 2),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (_selectedTabIndex == 0)
                    _aiTab(cardBg, textColor, primary),
                  if (_selectedTabIndex == 1) _financialTab(cardBg, textColor),
                  if (_selectedTabIndex == 2)
                    _technicalTab(cardBg, textColor, green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, bool selected) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color:
            selected
                ? theme.colorScheme.primary
                : (theme.brightness == Brightness.dark
                    ? const Color(0xFF0F162C)
                    : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border:
            selected
                ? null
                : Border.all(
                  color:
                      theme.brightness == Brightness.dark
                          ? Colors.grey[700]!
                          : Colors.black26,
                ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color:
              selected
                  ? Colors.white
                  : (theme.brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.black87),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _tabButton(String text, int index) {
    final theme = Theme.of(context);
    final selected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color:
                  selected
                      ? (theme.brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      : (theme.brightness == Brightness.dark
                          ? Colors.grey
                          : Colors.black45),
              fontSize: 16,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (selected)
            Container(width: 24, height: 2, color: theme.colorScheme.primary),
        ],
      ),
    );
  }

  Widget _aiTab(Color cardBg, Color textColor, Color primary) {
    final theme = Theme.of(context);
    final green = const Color(0xFF00C853);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow:
            theme.brightness == Brightness.light
                ? [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ]
                : [],
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
            "ASELS güçlü borç yönetimine sahip ancak orta düzey gelir büyümesi göstermektedir.",
            style: TextStyle(color: textColor.withOpacity(.9)),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.dark
                      ? cardBg.withOpacity(.5)
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Güçlü Yönler",
                  style: TextStyle(color: textColor.withOpacity(.6)),
                ),
                const SizedBox(height: 8),
                _bullet("Güçlü borç yönetimi", green),
                const SizedBox(height: 8),
                _bullet("Yüksek AR-GE yatırımları", green),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  theme.brightness == Brightness.dark
                      ? cardBg.withOpacity(.5)
                      : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dikkat Edilmesi Gerekenler",
                  style: TextStyle(color: textColor.withOpacity(.6)),
                ),
                const SizedBox(height: 8),
                _bullet("Orta düzey gelir büyümesi", Colors.amber),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text, Color dotColor) {
    final theme = Theme.of(context);
    final textColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return Row(
      children: [
        Icon(Icons.circle, size: 6, color: dotColor),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: textColor)),
      ],
    );
  }

  Widget _financialTab(Color cardBg, Color textColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
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
                  Text(
                    "Finansal Göstergeler",
                    style: TextStyle(color: textColor),
                  ),
                  Icon(
                    Icons.info_outline,
                    color: textColor.withOpacity(.6),
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _bar("Likidite", 0.1),
              const SizedBox(height: 12),
              _bar("Karlılık", 0.6),
              const SizedBox(height: 12),
              _bar("Borç Oranı", 0.9),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bar(String label, double value) {
    final theme = Theme.of(context);
    final green = const Color(0xFF00C853);

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color:
                  theme.brightness == Brightness.dark
                      ? Colors.grey
                      : Colors.black54,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 14,
              backgroundColor:
                  theme.brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.black12,
              color: green,
            ),
          ),
        ),
      ],
    );
  }

  Widget _technicalTab(Color cardBg, Color textColor, Color green) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "6 Aylık Tahmin",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                width: double.infinity,
                child: CustomPaint(
                  painter: SimpleLineChartPainter(
                    lineColor: green,
                    gridColor: textColor.withOpacity(.15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SimpleLineChartPainter extends CustomPainter {
  final Color lineColor;
  final Color gridColor;

  SimpleLineChartPainter({required this.lineColor, required this.gridColor});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint =
        Paint()
          ..color = gridColor
          ..strokeWidth = 1;

    final linePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final dotPaint = Paint()..color = lineColor;

    double stepX = size.width / 5;
    for (int i = 0; i <= 5; i++) {
      canvas.drawLine(
        Offset(i * stepX, 0),
        Offset(i * stepX, size.height),
        gridPaint,
      );
    }

    double stepY = size.height / 4;
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(0, i * stepY),
        Offset(size.width, i * stepY),
        gridPaint,
      );
    }

    final path = Path();
    path.moveTo(0, size.height * .8);
    path.lineTo(size.width * .2, size.height * .65);
    path.lineTo(size.width * .4, size.height * .75);
    path.lineTo(size.width * .6, size.height * .45);
    path.lineTo(size.width * .8, size.height * .3);
    path.lineTo(size.width, size.height * .2);

    canvas.drawPath(path, linePaint);

    canvas.drawCircle(Offset(0, size.height * .8), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * .2, size.height * .65), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * .4, size.height * .75), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * .6, size.height * .45), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * .8, size.height * .3), 4, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height * .2), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
