import 'package:flutter/material.dart';
import 'package:finance_app/screens/analysis/analysis_wizard_screen.dart';
import 'package:finance_app/screens/sectors/sectors_screen.dart';
import 'package:finance_app/screens/settings/settings_page.dart';
import 'package:finance_app/screens/portfolio/portfolio_screen.dart';
import 'package:finance_app/core/theme/colors.dart';

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

  static List<Widget> _pages = [
    const DashboardPage(),
    const SectorsScreen(),
    const PortfolioScreen(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "FinScope AI",
          style: theme.textTheme.titleLarge!.copyWith(
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
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.textTheme.bodySmall!.color,
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
    final theme = Theme.of(context);

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
                    backgroundColor: theme.colorScheme.primary,
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
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _sectionTitle(context, "En İyi Performans Gösteren Sektörler"),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _sectorItem(
                  context,
                  "1",
                  "Teknoloji",
                  "+24.5%",
                  "ASELS, LOGO, Karel",
                ),
                const SizedBox(height: 12),
                _sectorItem(
                  context,
                  "2",
                  "Bankacılık",
                  "+15.3%",
                  "GARAN, AKBNK, ISCTR",
                ),
                const SizedBox(height: 12),
                _sectorItem(
                  context,
                  "3",
                  "Enerji",
                  "+28.7%",
                  "TUPRS, ENKAI, AKENR",
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _sectionTitle(context, "Yapay Zeka Tahminleri"),

          _aiPredictionCard(
            context,
            "Havacılık sektöründe güçlü büyüme bekleniyor.",
          ),
          const SizedBox(height: 12),
          _aiPredictionCard(
            context,
            "ASELS ve THYAO kurumsal alımlarda öne çıkıyor.",
          ),

          const SizedBox(height: 24),
          _sectionTitle(context, "Akıllı Para Takibi"),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _moneyFlowItem(context, "En Çok Alınan", "THYAO", "+45.3M"),
                _moneyFlowItem(context, "Teknoloji Net", "Alım", "+8%"),
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

  Widget _sectionTitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: TextStyle(
        color: theme.textTheme.bodyMedium!.color,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _sectorItem(
    BuildContext context,
    String rank,
    String title,
    String change,
    String desc,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Text(rank, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium!.color,
                    fontSize: 16,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(color: theme.textTheme.bodySmall!.color),
                ),
              ],
            ),
          ),
          Text(
            change,
            style: TextStyle(
              color: ThemeAwareColors.profit(context),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiPredictionCard(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: theme.textTheme.bodyMedium!.color,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _moneyFlowItem(
    BuildContext context,
    String label,
    String title,
    String value,
  ) {
    final theme = Theme.of(context);

    final bool isNegative = value.contains("-");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: theme.textTheme.bodySmall!.color)),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: theme.textTheme.bodyMedium!.color,
            fontSize: 18,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color:
                isNegative
                    ? ThemeAwareColors.loss(context)
                    : ThemeAwareColors.profit(context),
            fontWeight: FontWeight.bold,
          ),
        ),
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
                  color:
                      isNegative
                          ? ThemeAwareColors.loss(context)
                          : ThemeAwareColors.profit(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
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
