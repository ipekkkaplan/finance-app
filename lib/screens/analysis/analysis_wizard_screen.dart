import 'package:flutter/material.dart';
import 'package:finance_app/screens/home/home_screen.dart';
import 'package:finance_app/core/theme/colors.dart';
import 'package:finance_app/core/theme/theme_provider.dart';

class AnalysisWizardScreen extends StatefulWidget {
  const AnalysisWizardScreen({super.key});

  @override
  State<AnalysisWizardScreen> createState() => _AnalysisWizardScreenState();
}

class _AnalysisWizardScreenState extends State<AnalysisWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? _selectedRisk;
  String? _selectedDuration;
  String? _selectedSize;
  final List<String> _selectedSectors = [];

  final List<String> _sectors = [
    "Teknoloji",
    "Enerji",
    "Bankacılık",
    "İmalat",
    "Perakende",
    "Havacılık",
    "Sağlık",
    "Telekomünikasyon",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () {
            if (_currentPage > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          index <= _currentPage
                              ? theme.colorScheme.primary
                              : theme.cardColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildRiskPage(theme),
                _buildDurationPage(theme),
                _buildSectorPage(theme),
                _buildResultPage(theme),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.dividerColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        "Geri",
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium!.color,
                        ),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _nextPage,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == 3 ? "Tamamla" : "Devam Et",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_currentPage != 3) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
        (route) => false,
      );
    }
  }

  Widget _buildRiskPage(ThemeData theme) {
    final text = theme.textTheme.bodyMedium!.color!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: text.withOpacity(0.7)),
          ),
          const SizedBox(height: 30),
          Text(
            "Risk İştahınızı Seçin",
            style: TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSelectableCard(
            theme,
            "Düşük Risk",
            "Güvenli, stabil yatırımlar",
            "dusuk",
            _selectedRisk,
            (val) => setState(() => _selectedRisk = val),
          ),
          _buildSelectableCard(
            theme,
            "Orta Risk",
            "Dengeli büyüme odaklı",
            "orta",
            _selectedRisk,
            (val) => setState(() => _selectedRisk = val),
          ),
          _buildSelectableCard(
            theme,
            "Yüksek Risk",
            "Agresif, yüksek getiri",
            "yuksek",
            _selectedRisk,
            (val) => setState(() => _selectedRisk = val),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationPage(ThemeData theme) {
    final text = theme.textTheme.bodyMedium!.color!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: text.withOpacity(0.7)),
          ),
          const SizedBox(height: 30),
          Text(
            "Yatırım Süreniz",
            style: TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSelectableCard(
            theme,
            "Kısa Vade",
            "3-6 ay",
            "kisa",
            _selectedDuration,
            (val) => setState(() => _selectedDuration = val),
            icon: Icons.access_time,
          ),
          _buildSelectableCard(
            theme,
            "Orta Vade",
            "6-18 ay",
            "orta",
            _selectedDuration,
            (val) => setState(() => _selectedDuration = val),
            icon: Icons.show_chart,
          ),
          _buildSelectableCard(
            theme,
            "Uzun Vade",
            "2+ yıl",
            "uzun",
            _selectedDuration,
            (val) => setState(() => _selectedDuration = val),
            icon: Icons.gps_fixed,
          ),
        ],
      ),
    );
  }

  Widget _buildSectorPage(ThemeData theme) {
    final text = theme.textTheme.bodyMedium!.color!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: text.withOpacity(0.7)),
          ),
          const SizedBox(height: 30),
          Text(
            "Tercih Ettiğiniz Sektörler",
            style: TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Birden fazla seçebilirsiniz",
            style: TextStyle(color: text.withOpacity(0.6), fontSize: 12),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _sectors.length,
              itemBuilder: (context, index) {
                final sector = _sectors[index];
                final isSelected = _selectedSectors.contains(sector);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected
                          ? _selectedSectors.remove(sector)
                          : _selectedSectors.add(sector);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          sector,
                          style: TextStyle(color: text, fontSize: 14),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultPage(ThemeData theme) {
    final text = theme.textTheme.bodyMedium!.color!;
    final profit = ThemeAwareColors.profit(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: text,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: text.withOpacity(0.7)),
          ),
          const SizedBox(height: 30),

          Text(
            "Şirket Büyüklüğü Tercihi",
            style: TextStyle(
              color: text,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildSelectableCard(
            theme,
            "BIST 30",
            "En büyük şirketler",
            "bist30",
            _selectedSize,
            (val) => setState(() => _selectedSize = val),
            icon: Icons.apartment,
          ),
          _buildSelectableCard(
            theme,
            "BIST 100",
            "Büyük ve orta ölçekli",
            "bist100",
            _selectedSize,
            (val) => setState(() => _selectedSize = val),
            icon: Icons.domain,
          ),
          _buildSelectableCard(
            theme,
            "Küçük Şirketler",
            "Yüksek potansiyelli",
            "small",
            _selectedSize,
            (val) => setState(() => _selectedSize = val),
            icon: Icons.storefront,
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: profit.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: profit, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Profil Özeti",
                      style: TextStyle(
                        color: profit,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Orta risk profiline sahip, kısa vade odaklı "
                  "bir yatırımcısınız. Havacılık sektöründe BIST 100 "
                  "şirketleri tercih ediyorsunuz.",
                  style: TextStyle(color: text, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSelectableCard(
    ThemeData theme,
    String title,
    String subtitle,
    String value,
    String? groupValue,
    Function(String) onTap, {
    IconData? icon,
  }) {
    final isSelected = groupValue == value;
    final text = theme.textTheme.bodyMedium!.color!;

    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: text.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: text.withOpacity(0.8), size: 20),
              ),
            if (icon != null) const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: text.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
