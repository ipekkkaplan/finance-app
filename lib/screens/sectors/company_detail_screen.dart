import 'package:flutter/material.dart';
import '../../models/stock_model.dart';
import '../../services/favorites_service.dart';

class CompanyDetailScreen extends StatefulWidget {
  final String sectorName;
  final List<StockModel> companies;
  final int initialIndex;
  final double dailyChange;

  const CompanyDetailScreen({
    super.key,
    required this.sectorName,
    required this.companies,
    this.initialIndex = 0,
    required this.dailyChange,
  });

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late int _selectedCompanyIndex;
  int _selectedTabIndex = 0;

  // Tema Renkleri
  final Color primary = const Color(0xFF3D8BFF);
  final Color green = const Color(0xFF00C853);
  final Color red = const Color(0xFFFF5252);

  @override
  void initState() {
    super.initState();
    _selectedCompanyIndex = widget.initialIndex;
  }

  StockModel get currentCompany => widget.companies[_selectedCompanyIndex];

  // --- YARDIMCI FORMAT FONKSİYONLARI ---
  String formatCompactNumber(double number) {
    double value = number.abs();
    String sign = number < 0 ? "-" : "";

    if (value >= 1e9) {
      return "$sign${(value / 1e9).toStringAsFixed(1)}B";
    } else if (value >= 1e6) {
      return "$sign${(value / 1e6).toStringAsFixed(1)}M";
    } else if (value >= 1e3) {
      return "$sign${(value / 1e3).toStringAsFixed(1)}K";
    } else {
      return number.toStringAsFixed(2);
    }
  }

  String formatDouble(double number) {
    return number.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.3);

    // --- VERİLER ---
    final String hisseKodu = currentCompany.hisseKodu;
    final String sirketIsmi = currentCompany.sirketIsmi;
    final String sektor = currentCompany.sektor;
    final double piyasaDegeri = currentCompany.pd;
    final double aktifKarlilik = currentCompany.roa;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        // Yıldız buradan kaldırıldı
        title: Text(
          sektor,
          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ÜST ŞİRKET LİSTESİ (YATAY SCROLL)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.companies.asMap().entries.map((entry) {
                  int idx = entry.key;
                  StockModel stock = entry.value;
                  bool isSelected = idx == _selectedCompanyIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCompanyIndex = idx),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primary : cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: borderColor),
                      ),
                      child: Text(
                        stock.hisseKodu,
                        style: TextStyle(
                          color: isSelected ? Colors.white : subTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // 2. ANA BİLGİ KARTI
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sol Taraf: İsim ve Sektör
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sirketIsmi,
                              style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text("$hisseKodu • $sektor", style: TextStyle(color: subTextColor, fontSize: 14)),
                          ],
                        ),
                      ),
                      // Sağ Taraf: Favori Yıldızı
                      IconButton(
                        onPressed: () {
                          FavoritesService.instance.toggleFavorite(
                              currentCompany.hisseKodu,
                              widget.dailyChange
                          );
                        },
                        icon: ValueListenableBuilder(
                          valueListenable: FavoritesService.instance.favoritesNotifier,
                          builder: (context, _, __) {
                            final isFav = FavoritesService.instance.isFavorite(currentCompany.hisseKodu);
                            return Icon(
                              isFav ? Icons.star : Icons.star_border_outlined,
                              color: isFav ? Colors.amber : subTextColor,
                              size: 32,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // -----------------------------------------------------------

                  const SizedBox(height: 25),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Piyasa Değeri (PD)",
                        style: TextStyle(color: subTextColor, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCompactNumber(piyasaDegeri),
                        style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                  Divider(color: borderColor),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      _buildHeaderInfoCard(
                          "Hacim",
                          formatCompactNumber(currentCompany.hacim),
                          Icons.bar_chart,
                          textColor, subTextColor
                      ),
                      Container(height: 30, width: 1, color: borderColor, margin: const EdgeInsets.symmetric(horizontal: 10)),
                      _buildHeaderInfoCard(
                          "Aktif Karlılık",
                          "%${formatDouble(aktifKarlilik)}",
                          Icons.trending_up,
                          textColor, subTextColor
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. TAB MENÜSÜ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton("Özet", 0, textColor),
                const SizedBox(width: 40),
                _buildTabButton("Finansal", 1, textColor),
              ],
            ),
            const SizedBox(height: 20),

            // 4. İÇERİK
            if (_selectedTabIndex == 0) _buildAISummaryTab(textColor, isDark),
            if (_selectedTabIndex == 1) _buildFinancialTab(cardColor, textColor, subTextColor, borderColor),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARÇALARI ---

  Widget _buildHeaderInfoCard(String title, String value, IconData icon, Color textColor, Color? subTextColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: subTextColor),
              const SizedBox(width: 5),
              Text(title, style: TextStyle(color: subTextColor, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTab(Color cardColor, Color textColor, Color? subTextColor, Color borderColor) {
    final fk = formatDouble(currentCompany.fk);
    final fdFavok = formatDouble(currentCompany.fdFavok);
    final pdDd = formatDouble(currentCompany.pdDd);
    final fdSatislar = formatDouble(currentCompany.fdSatislar);
    final temettu = currentCompany.temettuVerimliligi != null
        ? "%${currentCompany.temettuVerimliligi}"
        : "-";
    final favok = formatCompactNumber(currentCompany.favok);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Değerleme Oranları", style: TextStyle(color: subTextColor, fontSize: 14)),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildFinancialMetricBox("FK", fk, textColor, borderColor),
                  const SizedBox(width: 10),
                  _buildFinancialMetricBox("FD/FAVÖK", fdFavok, textColor, borderColor),
                  const SizedBox(width: 10),
                  _buildFinancialMetricBox("PD/DD", pdDd, textColor, borderColor),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildFinancialCardSimple("FD/Satışlar", fdSatislar, cardColor, textColor, subTextColor, borderColor),
            const SizedBox(width: 12),
            _buildFinancialCardSimple("Temettü Verim.", temettu, cardColor, textColor, subTextColor, borderColor),
            const SizedBox(width: 12),
            _buildFinancialCardSimple("FAVÖK", favok, cardColor, textColor, subTextColor, borderColor),
          ],
        ),
      ],
    );
  }

  Widget _buildFinancialMetricBox(String label, String value, Color textColor, Color borderColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialCardSimple(String title, String value, Color bg, Color text, Color? subText, Color border) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: subText, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAISummaryTab(Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2746) : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: primary, size: 20),
              const SizedBox(width: 10),
              Text("Rasyo Analizi", style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "${currentCompany.sirketIsmi} finansal verileri incelendiğinde sektör ortalamasına göre dengeli bir büyüme görülüyor. Aktif karlılık (%${currentCompany.roa}) ve FAVÖK marjları takip edilmeli.",
            style: TextStyle(color: textColor, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index, Color textColor) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? textColor : textColor.withValues(alpha: 0.5),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          if (isSelected)
            Container(
              width: 30,
              height: 3,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(2),
              ),
            )
        ],
      ),
    );
  }
}