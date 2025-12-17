import 'package:finance_app/screens/analysis/analysis_wizard_screen.dart';
import 'package:finance_app/screens/portfolio/portfolio_screen.dart';
import 'package:finance_app/screens/sectors/sectors_screen.dart';
import 'package:finance_app/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';

// JSON verileri için gerekli importlar
import '../../models/sector_model.dart';
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

  // Sayfa listesi
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
      body: _pages[_selectedIndex],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: "Portföy",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ayarlar"),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema renklerini buradan çekiyoruz
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = theme.textTheme.bodyMedium?.color;

    // İç kartlar için renk
    final innerCardColor = isDark ? const Color(0xFF1A2038) : Colors.grey.shade100;

    // Servis bağlantısı
    final DataService dataService = DataService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AnalysisWizardScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Analize Başla",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(color: primary, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _sectionTitle("En İyi Performans Gösteren Sektörler", textColor),

          // --- FutureBuilder ile JSON Verisi (6 AYLIK) ---
          FutureBuilder<List<SectorModel>>(
            future: dataService.loadSectorData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: CircularProgressIndicator(color: primary)),
                );
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text("Veri alınamadı", style: TextStyle(color: textColor))),
                );
              }

              // Verileri al
              List<SectorModel> sectors = snapshot.data!;

              // GÜNCELLEME: 6 Aylık değişime göre büyükten küçüğe sırala
              sectors.sort((a, b) => b.sixMonthChange.compareTo(a.sixMonthChange));

              // İlk 3'ü al
              List<SectorModel> top3 = sectors.take(3).toList();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Son 6 ayın liderleri",
                      style: TextStyle(color: subTextColor, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    // Dinamik Liste Oluşturma
                    ...top3.asMap().entries.map((entry) {
                      int index = entry.key;
                      SectorModel sector = entry.value;
                      return Column(
                        children: [
                          _sectorItem(
                            (index + 1).toString(), // Sıra no
                            sector.name, // Sektör adı
                            // GÜNCELLEME: Ekranda 6 aylık veriyi göster
                            "${sector.sixMonthChange >= 0 ? '+' : ''}${sector.sixMonthChange}%",
                            "${sector.name} Endeks Hisseleri", // Açıklama
                            innerCardColor,
                            textColor,
                            subTextColor,
                            primary,
                            // Rengi de 6 aylık değişime göre belirle
                            isPositive: sector.sixMonthChange >= 0,
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

          _sectionTitle("Yapay Zeka Tahminleri", textColor),

          _aiPredictionCard(
              "Havacılık sektöründe önümüzdeki çeyrek için güçlü büyüme bekleniyor.",
              innerCardColor, textColor
          ),
          const SizedBox(height: 12),
          _aiPredictionCard("ASELS ve THYAO kurumsal alımlarda öne çıkıyor.", innerCardColor, textColor),

          const SizedBox(height: 24),

          _sectionTitle("Akıllı Para Takibi", textColor),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
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

  // ---------------------
  // Yardımcı Widget'lar
  // ---------------------

  Widget _seeAllSectorsButton(BuildContext context, Color primary) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(initialIndex: 1), // Sektörler sekmesi index 1
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withValues(alpha: 0.15),
                primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tüm Sektörleri Gör",
                style: TextStyle(
                  color: primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _sectorItem(
      String rank,
      String title,
      String change,
      String desc,
      Color bgColor,
      Color? titleColor,
      Color? descColor,
      Color primary,
      {bool isPositive = true}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
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
                Text(
                  title,
                  style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(desc, style: TextStyle(color: descColor, fontSize: 12)),
              ],
            ),
          ),
          Text(
            change,
            style: TextStyle(
                color: isPositive ? Colors.greenAccent : Colors.redAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiPredictionCard(String text, Color bgColor, Color? textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: Colors.purpleAccent.shade100, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: textColor?.withValues(alpha: 0.9), fontSize: 14),
            ),
          ),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScrolling();
    });
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
    final Duration duration = Duration(
      milliseconds: ((distance / velocity) * 1000).toInt(),
    );

    _controller
        .animateTo(maxScroll, duration: duration, curve: Curves.linear)
        .then((_) {
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
              Text(
                "${item['name']}  ${item['price']}  (${item['change']})",
                style: TextStyle(
                  color: isNegative ? Colors.redAccent : Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 40),
            ],
          );
        },
      ),
    );
  }
}