import 'package:finance_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

class AnalysisWizardScreen extends StatefulWidget {
  const AnalysisWizardScreen({super.key});

  @override
  State<AnalysisWizardScreen> createState() => _AnalysisWizardScreenState();
}

class _AnalysisWizardScreenState extends State<AnalysisWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Sabit marka renkleri (Tema bağımsız)
  final Color primary = const Color(0xFF3D8BFF);
  final Color green = const Color(0xFF00C853);

  // Seçim Durumları
  String? _selectedRisk;
  String? _selectedDuration;
  String? _selectedSize;
  final List<String> _selectedSectors = [];

  // Sektör Listesi
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
    // Tema verilerini alıyoruz
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dinamik renkler
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final iconColor = theme.iconTheme.color ?? textColor;

    // İlerleme çubuğu pasif rengi
    final progressInactiveColor = isDark ? const Color(0xFF0F162C) : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
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
          // --- İLERLEME ÇUBUĞU ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index <= _currentPage ? green : progressInactiveColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // --- SAYFA İÇERİKLERİ (PAGEVIEW) ---
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Elle kaydırmayı kapat
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildRiskPage(textColor, cardColor, isDark), // 1. Sayfa
                _buildDurationPage(textColor, cardColor, isDark), // 2. Sayfa
                _buildSectorPage(textColor, cardColor, isDark), // 3. Sayfa
                _buildResultPage(textColor, cardColor, isDark), // 4. Sayfa
              ],
            ),
          ),

          // --- ALT BUTONLAR ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[400]!,
                        ),
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
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
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
                            color: Colors.white, // Buton içi hep beyaz
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_currentPage != 3)
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
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

  // --- BUTON FONKSİYONU ---
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(initialIndex: 1),
        ),
            (route) => false,
      );
    }
  }

  // --- 1. SAYFA: RİSK SEÇİMİ ---
  Widget _buildRiskPage(Color textColor, Color cardColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Text(
            "Risk İştahınızı Seçin",
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSelectableCard(
            title: "Düşük Risk",
            subtitle: "Güvenli, stabil yatırımlar",
            value: "dusuk",
            groupValue: _selectedRisk,
            onTap: (val) => setState(() => _selectedRisk = val),
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSelectableCard(
            title: "Orta Risk",
            subtitle: "Dengeli büyüme odaklı",
            value: "orta",
            groupValue: _selectedRisk,
            onTap: (val) => setState(() => _selectedRisk = val),
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSelectableCard(
            title: "Yüksek Risk",
            subtitle: "Agresif, yüksek getiri",
            value: "yuksek",
            groupValue: _selectedRisk,
            onTap: (val) => setState(() => _selectedRisk = val),
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // --- 2. SAYFA: VADE SEÇİMİ ---
  Widget _buildDurationPage(Color textColor, Color cardColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Text(
            "Yatırım Süreniz",
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSelectableCard(
            title: "Kısa Vade",
            subtitle: "3-6 ay",
            icon: Icons.access_time,
            value: "kisa",
            groupValue: _selectedDuration,
            onTap: (val) => setState(() => _selectedDuration = val),
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSelectableCard(
            title: "Orta Vade",
            subtitle: "6-18 ay",
            icon: Icons.show_chart,
            value: "orta",
            groupValue: _selectedDuration,
            onTap: (val) => setState(() => _selectedDuration = val),
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSelectableCard(
            title: "Uzun Vade",
            subtitle: "2+ yıl",
            icon: Icons.gps_fixed,
            value: "uzun",
            groupValue: _selectedDuration,
            onTap: (val) => setState(() => _selectedDuration = val),
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  // --- 3. SAYFA: SEKTÖR SEÇİMİ ---
  Widget _buildSectorPage(Color textColor, Color cardColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]),
          ),
          const SizedBox(height: 30),
          Text(
            "Tercih Ettiğiniz Sektörler",
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Birden fazla seçebilirsiniz",
            style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600], fontSize: 12),
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
                      if (isSelected) {
                        _selectedSectors.remove(sector);
                      } else {
                        _selectedSectors.add(sector);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                        color: cardColor,
                        border: Border.all(
                          color: isSelected ? green : (isDark ? Colors.transparent : Colors.grey.shade300),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (!isDark) BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                        ]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            sector,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check, color: green, size: 18),
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

  // --- 4. SAYFA: BÜYÜKLÜK VE SONUÇ ---
  Widget _buildResultPage(Color textColor, Color cardColor, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]),
          ),
          const SizedBox(height: 30),

          Text(
            "Şirket Büyüklüğü Tercihi",
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _buildSelectableCard(
            title: "BIST 30",
            subtitle: "En büyük şirketler",
            icon: Icons.apartment,
            value: "bist30",
            groupValue: _selectedSize,
            onTap: (val) => setState(() => _selectedSize = val),
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSelectableCard(
            title: "BIST 100",
            subtitle: "Büyük ve orta ölçekli",
            icon: Icons.domain,
            value: "bist100",
            groupValue: _selectedSize,
            onTap: (val) => setState(() => _selectedSize = val),
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),
          _buildSelectableCard(
            title: "Küçük Şirketler",
            subtitle: "Yüksek potansiyelli",
            icon: Icons.storefront,
            value: "small",
            groupValue: _selectedSize,
            onTap: (val) => setState(() => _selectedSize = val),
            cardColor: cardColor,
            textColor: textColor,
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // PROFİL ÖZETİ KARTI
          // Bu kart özel bir "vurgu" kartı olduğu için Light modda da renkli kalabilir
          // veya hafif yeşil bir ton alabilir.
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              // Dark modda koyu yeşil, Light modda çok açık yeşil
              color: isDark ? const Color(0xFF061D23) : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: green, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Profil Özeti",
                      style: TextStyle(
                        color: green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Orta Risk profiline sahip, kısa vade odaklı bir yatırımcısınız. Havacılık sektörlerinde BIST 100 şirketlerini tercih ediyorsunuz.",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- ORTAK KART BİLEŞENİ ---
  Widget _buildSelectableCard({
    required String title,
    required String subtitle,
    IconData? icon,
    required String value,
    required String? groupValue,
    required Function(String) onTap,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
  }) {
    final isSelected = groupValue == value;
    final iconBgColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100;
    final iconColor = isDark ? Colors.white70 : Colors.grey.shade700;

    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? primary : (isDark ? Colors.transparent : Colors.grey.shade300),
              width: 1.5,
            ),
            boxShadow: [
              if (!isDark) BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
            ]
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check, color: primary, size: 20),
          ],
        ),
      ),
    );
  }
}