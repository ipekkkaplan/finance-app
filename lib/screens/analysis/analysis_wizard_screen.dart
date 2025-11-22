// screens/analysis/analysis_wizard_screen.dart
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

  // Renkler
  final Color darkBg = const Color(0xFF0A0F24);
  final Color cardBg = const Color(0xFF0F162C);
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
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                      color: index <= _currentPage ? green : cardBg,
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
              physics:
                  const NeverScrollableScrollPhysics(), // Elle kaydırmayı kapat
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildRiskPage(), // 1. Sayfa: Risk
                _buildDurationPage(), // 2. Sayfa: Vade
                _buildSectorPage(), // 3. Sayfa: Sektörler
                _buildResultPage(), // 4. Sayfa: Sonuç & Büyüklük
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
                        side: BorderSide(color: Colors.grey[800]!),
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
                      child: const Text(
                        "Geri",
                        style: TextStyle(color: Colors.white),
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
                            color: Colors.white,
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
      // Sektörler sayfasına (HomeScreen içindeki 1. index) yönlendir
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder:
              (context) =>
                  const HomeScreen(initialIndex: 1), // 1 = Sektörler Tab'ı
        ),
        (route) => false,
      );
    }
  }

  // --- 1. SAYFA: RİSK SEÇİMİ ---
  Widget _buildRiskPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          const Text(
            "Risk İştahınızı Seçin",
            style: TextStyle(
              color: Colors.white,
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
          ),
          _buildSelectableCard(
            title: "Orta Risk",
            subtitle: "Dengeli büyüme odaklı",
            value: "orta",
            groupValue: _selectedRisk,
            onTap: (val) => setState(() => _selectedRisk = val),
          ),
          _buildSelectableCard(
            title: "Yüksek Risk",
            subtitle: "Agresif, yüksek getiri",
            value: "yuksek",
            groupValue: _selectedRisk,
            onTap: (val) => setState(() => _selectedRisk = val),
          ),
        ],
      ),
    );
  }

  // --- 2. SAYFA: VADE SEÇİMİ ---
  Widget _buildDurationPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          const Text(
            "Yatırım Süreniz",
            style: TextStyle(
              color: Colors.white,
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
          ),
          _buildSelectableCard(
            title: "Orta Vade",
            subtitle: "6-18 ay",
            icon: Icons.show_chart,
            value: "orta",
            groupValue: _selectedDuration,
            onTap: (val) => setState(() => _selectedDuration = val),
          ),
          _buildSelectableCard(
            title: "Uzun Vade",
            subtitle: "2+ yıl",
            icon: Icons.gps_fixed,
            value: "uzun",
            groupValue: _selectedDuration,
            onTap: (val) => setState(() => _selectedDuration = val),
          ),
        ],
      ),
    );
  }

  // --- 3. SAYFA: SEKTÖR SEÇİMİ ---
  Widget _buildSectorPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          const Text(
            "Tercih Ettiğiniz Sektörler",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Birden fazla seçebilirsiniz",
            style: TextStyle(color: Colors.grey, fontSize: 12),
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
                      color: cardBg,
                      border: Border.all(
                        color: isSelected ? green : Colors.transparent,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            sector,
                            style: const TextStyle(
                              color: Colors.white,
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
  Widget _buildResultPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Yatırımcı Profili",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Size özel öneriler için birkaç soru yanıtlayın",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),

          const Text(
            "Şirket Büyüklüğü Tercihi",
            style: TextStyle(
              color: Colors.white,
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
          ),
          _buildSelectableCard(
            title: "BIST 100",
            subtitle: "Büyük ve orta ölçekli",
            icon: Icons.domain,
            value: "bist100",
            groupValue: _selectedSize,
            onTap: (val) => setState(() => _selectedSize = val),
          ),
          _buildSelectableCard(
            title: "Küçük Şirketler",
            subtitle: "Yüksek potansiyelli",
            icon: Icons.storefront,
            value: "small",
            groupValue: _selectedSize,
            onTap: (val) => setState(() => _selectedSize = val),
          ),

          const SizedBox(height: 24),

          // PROFİL ÖZETİ KARTI
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF061D23), // Koyu yeşilimsi arka plan
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
                const Text(
                  "Orta Risk profiline sahip, kısa vade odaklı bir yatırımcısınız. Havacılık sektörlerinde BIST 100 şirketlerini tercih ediyorsunuz.",
                  style: TextStyle(color: Colors.white, height: 1.5),
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
  }) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white70, size: 20),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
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
