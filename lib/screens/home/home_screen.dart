import 'package:finance_app/screens/analysis/analysis_wizard_screen.dart';
import 'package:finance_app/screens/portfolio/portfolio_screen.dart';
import 'package:finance_app/screens/sectors/sectors_screen.dart';
import 'package:finance_app/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';

// Modeller ve Servisler
import '../../models/sector_model.dart';
import '../../models/valuation_model.dart';
import '../../services/data_service.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // Sayfalar listesi
  static const List<Widget> _pages = [
    DashboardPage(),
    SectorsScreen(),
    PortfolioScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "FinScope AI",
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),

      // --- DÜZELTME BURADA YAPILDI ---
      // IndexedStack kullanılarak sayfaların durumu korunur (Dispose olmaz).
      // Böylece sekmeler arası geçişte loading bar çıkmaz, anında geçiş sağlanır.
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // -------------------------------

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: theme.cardColor,
        currentIndex: _selectedIndex,
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: isDark ? Colors.grey : Colors.grey.shade600,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Ana Sayfa"),
          BottomNavigationBarItem(icon: Icon(Icons.domain), label: "Sektörler"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: "Portföy"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ayarlar"),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedPeriod = 'Günlük';
  final List<String> _periods = ['Günlük', 'Haftalık', 'Aylık', '6 Aylık'];

  // Değerleme filtresi
  String _valuationFilter = 'Ucuz';

  // Verileri hafızada tutmak için Future değişkenleri
  late Future<List<ValuationModel>> _valuationFuture;
  late Future<List<SectorModel>> _sectorFuture;
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _valuationFuture = _dataService.loadValuationData();
    _sectorFuture = _dataService.loadSectorData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = theme.textTheme.bodyMedium?.color;
    final innerCardColor = isDark ? const Color(0xFF1A2038) : Colors.grey.shade100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Üst Buton (Sadece Analize Başla) ---
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnalysisWizardScreen()),
                    );
                  },
                  child: const Text("Analize Başla", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              // Giriş Yap butonu kaldırıldı.
            ],
          ),

          const SizedBox(height: 20),

          // --- 2. Sektör Performansı Başlığı ---
          Text(
            "Sektör Performansı",
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // --- 3. Filtre Butonları ---
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _periods.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final period = _periods[index];
                final isSelected = _selectedPeriod == period;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = period),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? primary : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        period,
                        style: TextStyle(
                          color: isSelected ? Colors.white : subTextColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // --- 4. Sektör Listesi ---
          FutureBuilder<List<SectorModel>>(
            future: _sectorFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: CircularProgressIndicator(color: primary)),
                );
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text("Sektör verisi alınamadı", style: TextStyle(color: textColor))),
                );
              }

              List<SectorModel> sectors = snapshot.data!;
              sectors.sort((a, b) {
                double valA = _getChangeValue(a);
                double valB = _getChangeValue(b);
                return valB.compareTo(valA);
              });
              List<SectorModel> top3 = sectors.take(3).toList();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$_selectedPeriod - En Çok Kazandıranlar",
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ...top3.asMap().entries.map((entry) {
                      int index = entry.key;
                      SectorModel sector = entry.value;
                      double changeValue = _getChangeValue(sector);
                      return Column(
                        children: [
                          _sectorItem(
                            (index + 1).toString(),
                            sector.name,
                            "${changeValue >= 0 ? '+' : ''}${changeValue.toStringAsFixed(1)}%",
                            "${sector.name} Endeks Hisseleri",
                            innerCardColor,
                            textColor,
                            subTextColor,
                            primary,
                            isPositive: changeValue >= 0,
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),
                    const SizedBox(height: 15),
                    _seeAllSectorsButton(context, primary),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // =============================================================
          // DEĞERLEME RADARI
          // =============================================================
          _buildValuationSection(cardColor, innerCardColor, textColor, subTextColor),

          const SizedBox(height: 24),

          // --- 6. Akıllı Para Takibi ---
          _sectionTitle("Akıllı Para Takibi", textColor),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDark)
                  BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _moneyFlowItem("En Çok Alınan", "THYAO", "+45.3M", textColor, subTextColor),
                _moneyFlowItem("Teknoloji Net", "Alım", "+8%", textColor, subTextColor),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- 7. Kayan Hisse Şeridi ---
          StockTicker(
            stocks: const [
              {"name": "GARAN", "price": "98.20₺", "change": "-0.5%"},
              {"name": "AKBNK", "price": "56.80₺", "change": "+1.2%"},
              {"name": "ASELS", "price": "59.40₺", "change": "+3.1%"},
              {"name": "THYAO", "price": "295.50₺", "change": "+0.8%"},
              {"name": "SISE", "price": "48.60₺", "change": "-0.2%"},
            ],
            textColor: textColor,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- WIDGET: DEĞERLEME RADARI ---
  Widget _buildValuationSection(
      Color cardColor,
      Color innerCardColor,
      Color? textColor,
      Color? subTextColor
      ) {
    return Column(
      children: [
        // Başlık ve Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Değerleme Radarı",
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 32,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: innerCardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildToggleOption("Fırsat", "Ucuz", Colors.green),
                  _buildToggleOption("Riskli", "Pahalı", Colors.red),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Liste
        SizedBox(
          height: 140,
          child: FutureBuilder<List<ValuationModel>>(
            future: _valuationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(strokeWidth: 2));
              }
              if (snapshot.hasError) {
                return Center(child: Text("Hata oluştu", style: TextStyle(color: subTextColor)));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Veri yok", style: TextStyle(color: subTextColor)),
                      Text("(assets/hisse_degerleme_sonuclari.json?)",
                          style: TextStyle(color: subTextColor, fontSize: 10)),
                    ],
                  ),
                );
              }

              // Filtreleme
              var filteredList = snapshot.data!.where((item) => item.etiket == _valuationFilter).toList();

              // Sıralama
              if (_valuationFilter == 'Ucuz') {
                filteredList.sort((a, b) => b.finalSkor.compareTo(a.finalSkor));
              } else {
                filteredList.sort((a, b) => a.finalSkor.compareTo(b.finalSkor));
              }

              var displayList = filteredList.take(10).toList();

              if (displayList.isEmpty) {
                return Center(child: Text("Bu kriterde hisse yok.", style: TextStyle(color: subTextColor)));
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: displayList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  var stock = displayList[index];
                  bool isOpportunity = _valuationFilter == 'Ucuz';
                  Color themeColor = isOpportunity ? Colors.green : Colors.redAccent;

                  return Container(
                    width: 140,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: themeColor.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst Kısım
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              stock.hisseKodu,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                stock.finalSkor.toStringAsFixed(2),
                                style: TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stock.sektor,
                          style: TextStyle(color: subTextColor, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                                isOpportunity ? Icons.trending_up : Icons.warning_amber_rounded,
                                color: themeColor,
                                size: 16
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOpportunity ? "Fırsat" : "Riskli",
                              style: TextStyle(
                                color: themeColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // --- Helper Metodlar ---
  Widget _buildToggleOption(String label, String value, Color activeColor) {
    bool isSelected = _valuationFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _valuationFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  double _getChangeValue(SectorModel sector) {
    switch (_selectedPeriod) {
      case 'Günlük': return sector.dailyChange;
      case 'Haftalık': return sector.weeklyChange;
      case 'Aylık': return sector.monthlyChange;
      case '6 Aylık': return sector.sixMonthChange;
      default: return sector.dailyChange;
    }
  }

  Widget _seeAllSectorsButton(BuildContext context, Color primary) {
    return Center(
      child: GestureDetector(
        onTap: () {
         //Push yerine Index kullanabiliriz
          Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary.withValues(alpha: 0.15), primary.withValues(alpha: 0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Tüm Sektörleri Gör", style: TextStyle(color: primary, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(width: 6),
              Icon(Icons.arrow_right_alt, color: primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color? color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(text, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _sectorItem(String rank, String title, String change, String desc, Color? bgColor, Color? titleColor, Color? descColor, Color primary, {bool isPositive = true}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: primary,
            radius: 14,
            child: Text(rank, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w600)),
                Text(desc, style: TextStyle(color: descColor, fontSize: 12)),
              ],
            ),
          ),
          Text(change, style: TextStyle(color: isPositive ? Colors.greenAccent : Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _moneyFlowItem(String label, String title, String value, Color? titleColor, Color? labelColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
        const SizedBox(height: 4),
        Text(title, style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(value, style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class StockTicker extends StatefulWidget {
  final List<Map<String, String>> stocks;
  final Color? textColor;
  const StockTicker({super.key, required this.stocks, this.textColor});

  @override
  State<StockTicker> createState() => _StockTickerState();
}

class _StockTickerState extends State<StockTicker> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScrolling());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAutoScrolling() {
    if (!_controller.hasClients || !mounted) return;
    final double currentOffset = _controller.offset;
    final double maxScroll = _controller.position.maxScrollExtent;
    final double distance = maxScroll - currentOffset;

    if (distance <= 0) {
      _controller.jumpTo(0);
      _startAutoScrolling();
      return;
    }
    const double velocity = 30.0;
    final Duration duration = Duration(milliseconds: ((distance / velocity) * 1000).toInt());
    _controller.animateTo(maxScroll, duration: duration, curve: Curves.linear).then((_) {
      if (mounted) {
        _controller.jumpTo(0);
        _startAutoScrolling();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: widget.stocks.length * 100,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = widget.stocks[index % widget.stocks.length];
          final isNegative = item["change"]!.contains("-");
          return Row(
            children: [
              Text("${item['name']}  ${item['price']}  (${item['change']})", style: TextStyle(color: isNegative ? Colors.redAccent : Colors.green, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(width: 40),
            ],
          );
        },
      ),
    );
  }
}