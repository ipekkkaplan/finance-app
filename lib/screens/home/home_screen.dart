// screens/home/home_screen.dart
import 'package:finance_app/screens/analysis/analysis_wizard_screen.dart';
import 'package:finance_app/screens/portfolio/portfolio_screen.dart';
import 'package:finance_app/screens/sectors/sectors_screen.dart';
import 'package:finance_app/screens/settings/settings_screen.dart';
import 'package:finance_app/screens/algo_trade/algo_trade_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/sector_model.dart';
import '../../models/valuation_model.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/di/locator.dart';
import '../../services/favorites_service.dart';
import '../../widgets/dashboard_feature_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/app_card.dart';
import '../sentiment/sentiment_screen.dart';

// ── Tema sabitleri ────────────────────────────────────────────────
// Referans görseldeki koyu lacivert gradyan arka plan
const _kBgTop = AppColors.bgGradientTop;
const _kBgMid = AppColors.bgGradientMid;
const _kBgBot = AppColors.bgGradientBot;

// Cam efekti kart — çok hafif beyaz overlay + ince border
const _kGlassColor = AppColors.glassFill; // %5 beyaz
const _kGlassBorder = AppColors.glassBorder; // %9 beyaz border
const _kInnerGlass = AppColors.glassFillInner; // %3 — iç kart

// Teal vurgu
const _kTeal = AppColors.accentTeal;

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
    FavoritesService.instance.loadFavorites();
  }

  static const List<Widget> _pages = [
    DashboardPage(),
    SectorsScreen(),
    AlgoTradeScreen(),
    PortfolioScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor = isDark ? Colors.white30 : Colors.grey.shade500;
    final selectedIconColor = isDark ? Colors.white : _kTeal;
    return GestureDetector(
      onTap:
          () => _onItemTapped(
            [
              Icons.home_rounded,
              Icons.domain_rounded,
              Icons.auto_graph_rounded,
              Icons.pie_chart_rounded,
              Icons.settings_rounded,
            ].indexOf(icon),
          ),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? _kTeal.withValues(alpha: 0.15)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border:
                  isSelected
                      ? Border.all(
                        color: _kTeal.withValues(alpha: 0.25),
                        width: 1,
                      )
                      : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? selectedIconColor : unselectedColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? _kTeal : unselectedColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? _kBgTop : const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        // Açık zeminde status bar ikonları koyu, koyu zeminde beyaz olmalı.
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        title: Text(
          'FinScope AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.3,
            // Şeffaf AppBar + açık zeminde beyaz başlık görünmüyordu.
            color: isDark ? Colors.white : AppColors.primaryLight,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body:
          isDark
              // Gradient arka plan sadece dark modda
              ? Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_kBgTop, _kBgMid, _kBgBot],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  IndexedStack(index: _selectedIndex, children: _pages),
                ],
              )
              : IndexedStack(index: _selectedIndex, children: _pages),

      // ── Bottom Nav ───────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A1528) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? _kGlassBorder : Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.home_rounded,
                  "Ana Sayfa",
                  _selectedIndex == 0,
                ),
                _buildNavItem(
                  Icons.domain_rounded,
                  "Sektörler",
                  _selectedIndex == 1,
                ),
                _buildNavItem(
                  Icons.auto_graph_rounded,
                  "Algo Trade",
                  _selectedIndex == 2,
                ),
                _buildNavItem(
                  Icons.pie_chart_rounded,
                  "Portföy",
                  _selectedIndex == 3,
                ),
                _buildNavItem(
                  Icons.settings_rounded,
                  "Ayarlar",
                  _selectedIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// DASHBOARD PAGE
// ════════════════════════════════════════════════════════════════════

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedPeriod = 'Günlük';
  final List<String> _periods = ['Günlük', 'Haftalık', 'Aylık', '6 Aylık'];
  String _valuationFilter = 'Ucuz';

  late Future<List<ValuationModel>> _valuationFuture;
  late Future<List<SectorModel>> _sectorFuture;
  final _dataService = locator.market;

  @override
  void initState() {
    super.initState();
    _valuationFuture = _dataService.loadValuationData();
    _sectorFuture = _dataService.loadSectorData();
  }

  // ── Kart dekorasyonu → paylaşılan widgets/app_card.dart ─────────
  BoxDecoration _glass({double radius = 16, Color? borderColor}) =>
      glassCardDecoration(radius: radius, borderColor: borderColor);

  BoxDecoration _lightCard(
    Color cardColor,
    bool isDark, {
    double radius = 16,
  }) => lightCardDecoration(cardColor, withShadow: !isDark, radius: radius);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? _kTeal : theme.primaryColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = theme.textTheme.bodyMedium?.color;
    final innerCardColor = isDark ? _kInnerGlass : Colors.grey.shade100;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Analize Başla Butonu ─────────────────────────────
          Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color:
                  isDark
                      ? _kTeal.withValues(alpha: 0.10)
                      : primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color:
                    isDark
                        ? _kTeal.withValues(alpha: 0.25)
                        : primary.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnalysisWizardScreen(),
                      ),
                    ),
                child: Center(
                  child: Text(
                    "Analize Başla",
                    style: TextStyle(
                      color: isDark ? _kTeal : primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── 2. Sektör Performansı Başlık ────────────────────────
          _sectionTitle("Sektör Performansı", textColor, primary),
          const SizedBox(height: 12),

          // ── 3. Filtre Chips ──────────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _periods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final period = _periods[index];
                final isSelected = _selectedPeriod == period;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = period),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? (isDark
                                  ? _kTeal.withValues(alpha: 0.10)
                                  : primary.withValues(alpha: 0.08))
                              : (isDark ? _kGlassColor : Colors.transparent),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? (isDark
                                    ? _kTeal.withValues(alpha: 0.30)
                                    : primary.withValues(alpha: 0.30))
                                : (isDark
                                    ? _kGlassBorder
                                    : Colors.grey.shade300),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        color:
                            isSelected
                                ? (isDark ? _kTeal : primary)
                                : subTextColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ── 4. Sektör Listesi ────────────────────────────────────
          FutureBuilder<List<SectorModel>>(
            future: _sectorFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  height: 200,
                  decoration: isDark ? _glass() : _lightCard(cardColor, isDark),
                  child: Center(
                    child: CircularProgressIndicator(color: primary),
                  ),
                );
              } else if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: isDark ? _glass() : _lightCard(cardColor, isDark),
                  child: Center(
                    child: Text(
                      "Sektör verisi alınamadı",
                      style: TextStyle(color: textColor),
                    ),
                  ),
                );
              }

              List<SectorModel> sectors = snapshot.data!;
              sectors.sort(
                (a, b) => _getChangeValue(b).compareTo(_getChangeValue(a)),
              );
              final top3 = sectors.take(3).toList();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: isDark ? _glass() : _lightCard(cardColor, isDark),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$_selectedPeriod · En Çok Kazandıranlar",
                      style: TextStyle(
                        color: isDark ? Colors.white38 : subTextColor,
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...top3.asMap().entries.map((entry) {
                      final i = entry.key;
                      final sector = entry.value;
                      final change = _getChangeValue(sector);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _sectorItem(
                          (i + 1).toString(),
                          sector.name,
                          "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%",
                          "${sector.name} Endeks Hisseleri",
                          isDark ? _kInnerGlass : innerCardColor,
                          textColor,
                          subTextColor,
                          primary,
                          isDark: isDark,
                          isPositive: change >= 0,
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                    _seeAllSectorsButton(context, primary, isDark),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // ── 5. Değerleme Radarı ──────────────────────────────────
          _buildValuationSection(
            cardColor,
            isDark,
            textColor,
            subTextColor,
            primary,
          ),

          const SizedBox(height: 24),

          // ── 6. AI Destekli Araçlar ───────────────────────────────
          SectionHeader(title: "AI Destekli Araçlar", icon: Icons.auto_awesome),
          DashboardFeatureCard(
            icon: Icons.forum_outlined,
            title: "Sosyal Sentiment",
            description:
                "Sosyal medya ve haber akışındaki piyasa algısı analizi.",
            accentColor: const Color(0xFFAA00FF),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SentimentScreen()),
                ),
          ),

          const SizedBox(height: 24),

          // ── 7. Favorilerim ────────────────────────────────────────
          ValueListenableBuilder<List<FavoriteItem>>(
            valueListenable: FavoritesService.instance.favoritesNotifier,
            builder: (context, favorites, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("Favorilerim", textColor, primary),
                  const SizedBox(height: 12),
                  if (favorites.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration:
                          isDark
                              ? _glass(borderColor: _kGlassBorder)
                              : _lightCard(cardColor, isDark).copyWith(
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                ),
                              ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.star_border_rounded,
                              color: primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Listeniz Boş",
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Hisse detay sayfalarından yıldız ikonuna basarak ekleme yapabilirsiniz.",
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: favorites.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final item = favorites[index];
                          final isPositive = item.changeRate >= 0;
                          final darkBg =
                              isPositive
                                  ? const Color(
                                    0xFF00C853,
                                  ).withValues(alpha: 0.12)
                                  : const Color(
                                    0xFFEF5350,
                                  ).withValues(alpha: 0.12);
                          final lightBg =
                              isPositive
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFFEBEE);
                          final changeColor =
                              isDark
                                  ? (isPositive
                                      ? AppColors.profitDark
                                      : AppColors.lossDark)
                                  : (isPositive
                                      ? Colors.green[700]
                                      : Colors.red[700]);

                          return Container(
                            width: 140,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration:
                                isDark
                                    ? BoxDecoration(
                                      color: darkBg,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: (isPositive
                                                ? AppColors.profitDark
                                                : AppColors.lossDark)
                                            .withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    )
                                    : BoxDecoration(
                                      color: lightBg,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.symbol,
                                  style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      isPositive
                                          ? Icons.trending_up_rounded
                                          : Icons.trending_down_rounded,
                                      color: changeColor,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "%${item.changeRate.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: changeColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),

          // ── 8. Akıllı Para Takibi ─────────────────────────────────
          _sectionTitle("Akıllı Para Takibi", textColor, primary),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: isDark ? _glass() : _lightCard(cardColor, isDark),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _moneyFlowItem(
                  "En Çok Alınan",
                  "THYAO",
                  "+45.3M",
                  textColor,
                  subTextColor,
                  isDark,
                ),
                _moneyFlowItem(
                  "Teknoloji Net",
                  "Alım",
                  "+8%",
                  textColor,
                  subTextColor,
                  isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── 9. Kayan Hisse Şeridi ────────────────────────────────
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

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Değerleme Radarı ─────────────────────────────────────────────
  Widget _buildValuationSection(
    Color cardColor,
    bool isDark,
    Color? textColor,
    Color? subTextColor,
    Color primary,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionTitle("Değerleme Radarı", textColor, primary),
            Container(
              height: 32,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isDark ? _kGlassColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border:
                    isDark ? Border.all(color: _kGlassBorder, width: 1) : null,
              ),
              child: Row(
                children: [
                  _buildToggleOption("Fırsat", "Ucuz", Colors.green, isDark),
                  _buildToggleOption("Riskli", "Pahalı", Colors.red, isDark),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: FutureBuilder<List<ValuationModel>>(
            future: _valuationFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "Veri yok",
                    style: TextStyle(color: subTextColor),
                  ),
                );
              }

              var list =
                  snapshot.data!
                      .where((item) => item.etiket == _valuationFilter)
                      .toList();
              if (_valuationFilter == 'Ucuz') {
                list.sort((a, b) => b.finalSkor.compareTo(a.finalSkor));
              } else {
                list.sort((a, b) => a.finalSkor.compareTo(b.finalSkor));
              }
              final display = list.take(10).toList();
              if (display.isEmpty) {
                return Center(
                  child: Text(
                    "Bu kriterde hisse yok.",
                    style: TextStyle(color: subTextColor),
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: display.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final stock = display[index];
                  final isOpp = _valuationFilter == 'Ucuz';
                  final accent =
                      isOpp ? AppColors.profitLight : AppColors.lossDark;

                  return Container(
                    width: 140,
                    padding: const EdgeInsets.all(12),
                    decoration:
                        isDark
                            ? BoxDecoration(
                              color: _kGlassColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            )
                            : BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              stock.hisseKodu,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                stock.finalSkor.toStringAsFixed(2),
                                style: TextStyle(
                                  color: accent,
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
                              isOpp
                                  ? Icons.trending_up
                                  : Icons.warning_amber_rounded,
                              color: accent,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOpp ? "Fırsat" : "Riskli",
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildToggleOption(
    String label,
    String value,
    Color activeColor,
    bool isDark,
  ) {
    final isSelected = _valuationFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _valuationFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? activeColor.withValues(alpha: isDark ? 0.18 : 0.15)
                  : Colors.transparent,
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
      case 'Günlük':
        return sector.dailyChange;
      case 'Haftalık':
        return sector.weeklyChange;
      case 'Aylık':
        return sector.monthlyChange;
      case '6 Aylık':
        return sector.sixMonthChange;
      default:
        return sector.dailyChange;
    }
  }

  Widget _seeAllSectorsButton(
    BuildContext context,
    Color primary,
    bool isDark,
  ) {
    return Center(
      child: GestureDetector(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HomeScreen(initialIndex: 1),
              ),
            ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 22),
          decoration: BoxDecoration(
            color:
                isDark
                    ? _kTeal.withValues(alpha: 0.10)
                    : primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDark
                      ? _kTeal.withValues(alpha: 0.25)
                      : primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tüm Sektörleri Gör",
                style: TextStyle(
                  color: isDark ? _kTeal : primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                color: isDark ? _kTeal : primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color? color, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 17,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectorItem(
    String rank,
    String title,
    String change,
    String desc,
    Color? bgColor,
    Color? titleColor,
    Color? descColor,
    Color primary, {
    required bool isDark,
    bool isPositive = true,
  }) {
    final changeColor = isPositive ? AppColors.profitDark : AppColors.lossDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? _kInnerGlass : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: isDark ? Border.all(color: _kGlassBorder, width: 1) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: isDark ? 0.15 : 1.0),
              shape: BoxShape.circle,
              border:
                  isDark
                      ? Border.all(
                        color: primary.withValues(alpha: 0.4),
                        width: 1,
                      )
                      : null,
            ),
            child: Center(
              child: Text(
                rank,
                style: TextStyle(
                  color: isDark ? primary : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(desc, style: TextStyle(color: descColor, fontSize: 11)),
              ],
            ),
          ),
          Text(
            change,
            style: TextStyle(
              color: changeColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _moneyFlowItem(
    String label,
    String title,
    String value,
    Color? titleColor,
    Color? labelColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? _kTeal : AppColors.profitDark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// STOCK TICKER
// ════════════════════════════════════════════════════════════════════

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
    final double distance =
        _controller.position.maxScrollExtent - _controller.offset;
    if (distance <= 0) {
      _controller.jumpTo(0);
      _startAutoScrolling();
      return;
    }
    _controller
        .animateTo(
          _controller.position.maxScrollExtent,
          duration: Duration(milliseconds: ((distance / 30) * 1000).toInt()),
          curve: Curves.linear,
        )
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
      height: 26,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemCount: widget.stocks.length * 100,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final item = widget.stocks[index % widget.stocks.length];
          final isNeg = item["change"]!.contains("-");
          return Row(
            children: [
              Text(
                "${item['name']}  ${item['price']}  (${item['change']})",
                style: TextStyle(
                  color: isNeg ? AppColors.lossDark : AppColors.profitLight,
                  fontSize: 13,
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
