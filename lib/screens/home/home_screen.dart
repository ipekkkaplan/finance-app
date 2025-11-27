// screens/home/home_screen.dart
import 'package:finance_app/screens/analysis/analysis_wizard_screen.dart';
import 'package:finance_app/screens/sectors/sectors_screen.dart';
import 'package:finance_app/screens/settings/settings_screen.dart';
import 'package:flutter/material.dart';

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

  final Color darkBg = const Color(0xFF0A0F24);
  final Color cardBg = const Color(0xFF0F162C);
  final Color primary = const Color(0xFF3D8BFF);

  static const List<Widget> _pages = [
    DashboardPage(),
    SectorsScreen(),
    Center(
      child: Text("Portföy Sayfası", style: TextStyle(color: Colors.white)),
    ),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        title: const Text(
          "FinScope AI",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardBg,
        currentIndex: _selectedIndex,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey,
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

  final Color cardBg = const Color(0xFF0F162C);
  final Color primary = const Color(0xFF3D8BFF);

  @override
  Widget build(BuildContext context) {
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

          _sectionTitle("En İyi Performans Gösteren Sektörler"),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                _sectorItem("1", "Teknoloji", "+24.5%", "ASELS, LOGO, Karel"),
                const SizedBox(height: 12),
                _sectorItem("2", "Bankacılık", "+15.3%", "GARAN, AKBNK, ISCTR"),
                const SizedBox(height: 12),
                _sectorItem("3", "Enerji", "+28.7%", "TUPRS, ENKAI, AKENR"),

                const SizedBox(height: 25),

                //Tüm sektörleri gör butonu
                _seeAllSectorsButton(context, primary),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _sectionTitle("Yapay Zeka Tahminleri"),

          _aiPredictionCard(
            "Havacılık sektöründe önümüzdeki çeyrek için güçlü büyüme bekleniyor.",
          ),
          const SizedBox(height: 12),
          _aiPredictionCard("ASELS ve THYAO kurumsal alımlarda öne çıkıyor."),

          const SizedBox(height: 24),

          _sectionTitle("Akıllı Para Takibi"),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _moneyFlowItem("En Çok Alınan", "THYAO", "+45.3M"),
                _moneyFlowItem("Teknoloji Net", "Alım", "+8%"),
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
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ---------------------
  //yeni buton
  // ---------------------
  Widget _seeAllSectorsButton(BuildContext context, Color primary) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const HomeScreen(initialIndex: 1),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.15),
                primary.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary.withOpacity(0.3)),
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

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _sectorItem(String rank, String title, String change, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2038),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF3D8BFF),
            child: Text(rank, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(desc, style: TextStyle(color: Colors.grey.shade400)),
              ],
            ),
          ),
          Text(
            change,
            style: const TextStyle(color: Colors.greenAccent, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _aiPredictionCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2038),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 15),
      ),
    );
  }

  Widget _moneyFlowItem(String label, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 18)),
        Text(value, style: const TextStyle(color: Colors.greenAccent)),
      ],
    );
  }
}

class StockTicker extends StatefulWidget {
  final List<Map<String, String>> stocks;
  const StockTicker({super.key, required this.stocks});

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
                  color: isNegative ? Colors.redAccent : Colors.greenAccent,
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
