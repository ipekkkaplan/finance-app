import 'package:flutter/material.dart';
import 'package:finance_app/screens/portfolio/portfolio_screen.dart';

class AnalysisWizardScreen extends StatefulWidget {
  const AnalysisWizardScreen({super.key});

  @override
  State<AnalysisWizardScreen> createState() => _AnalysisWizardScreenState();
}

class _AnalysisWizardScreenState extends State<AnalysisWizardScreen> {
  //sayfalar arası geçişi yönetir.
  final PageController _pageController = PageController();

  int _currentPage = 0;

  // --- SABİT MARKA RENKLERİ ---
  // Uygulamanın ana renkleri, tema bağımsız olarak burada tanımlanmıştır.
  final Color primary = const Color(0xFF3D8BFF);
  final Color green = const Color(0xFF00C853);

  // --- SEÇİM DEĞİŞKENLERİ  --

  String? _selectedVade; // 1. Soru: Vade Beklentisi
  String? _selectedGetiri; // 2. Soru: Getiri Beklentisi
  String? _selectedDusus; // 3. Soru: Düşüşe Bakış Açısı
  String? _selectedBilgi; // 4. Soru: Finansal Bilgi Düzeyi
  String? _selectedRiskYonetimi; // 5. Soru: Risk Yönetimi Tercihi

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final iconColor = theme.iconTheme.color ?? textColor;

    final progressInactiveColor =
        isDark ? const Color(0xFF0F162C) : Colors.grey.shade300;

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

        title: Text(
          "Yatırımcı Profil Analizi",
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: List.generate(5, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color:
                          index <= _currentPage ? green : progressInactiveColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: PageView(
              controller: _pageController,
              // Kullanıcı sadece butonla geçsin
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildStep1Vade(textColor, cardColor, isDark), // 1. Sayfa
                _buildStep2Getiri(textColor, cardColor, isDark), // 2. Sayfa
                _buildStep3Dusus(textColor, cardColor, isDark), // 3. Sayfa
                _buildStep4Bilgi(textColor, cardColor, isDark), // 4. Sayfa
                _buildStep5Risk(textColor, cardColor, isDark), // 5. Sayfa
              ],
            ),
          ),

          // --- ALT BUTONLAR (GERİ / DEVAM ET) ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Geri Butonu (Sadece 1. sayfadan sonra görünür)
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
                      child: Text("Geri", style: TextStyle(color: textColor)),
                    ),
                  ),

                // Aradaki boşluk (Geri butonu varsa)
                if (_currentPage > 0) const SizedBox(width: 16),

                // İleri / Tamamla Butonu
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
                          // Son sayfadaysak "Tamamla", değilse "Devam Et"
                          _currentPage == 4 ? "Tamamla" : "Devam Et",
                          style: const TextStyle(
                            color: Colors.white, // Buton içi hep beyaz
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Son sayfada değilsek ok ikonu göster
                        if (_currentPage != 4)
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

  // --- İLERLEME VE TAMAMLAMA MANTIĞI ---
  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _logUserSelections();

      // 2. Yönlendir (PortfolioScreen'e git)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PortfolioScreen()),
        (route) => false, // Geri tuşuyla sihirbaza dönülmesin
      );
    }
  }

  // --- SEÇİMLERİ LOGLAMA ---
  void _logUserSelections() {
    debugPrint("--- RİSK PROFİL ANALİZİ SEÇİMLERİ ---");
    debugPrint("1. Vade Beklentisi: $_selectedVade");
    debugPrint("2. Getiri Beklentisi: $_selectedGetiri");
    debugPrint("3. Düşüşe Bakış Açısı: $_selectedDusus");
    debugPrint("4. Finans Piyasalarına Hakimiyet: $_selectedBilgi");
    debugPrint("5. Risk Yönetimi: $_selectedRiskYonetimi");
    debugPrint("---------------------------------------");
    // Not: İlerleyen aşamada burada ağırlıklı puan hesaplaması yapılıcak.
  }

  // 1. ADIM: VADE BEKLENTİSİ
  Widget _buildStep1Vade(Color textColor, Color cardColor, bool isDark) {
    return _buildQuestionPage(
      title: "Vade Beklentisi",
      subtitle: "Yatırımınızı ne kadar süreyle değerlendirmeyi planlıyorsunuz?",
      children: [
        _buildSelectableCard(
          title: "0 - 6 Ay",
          subtitle: "Kısa vadeli nakit ihtiyacı",
          value: "0-6 ay", // Arka planda tutulacak değer
          groupValue: _selectedVade,
          onTap: (val) => setState(() => _selectedVade = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "6 - 12 Ay",
          subtitle: "Orta-Kısa vade",
          value: "6-12 ay",
          groupValue: _selectedVade,
          onTap: (val) => setState(() => _selectedVade = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "1 - 3 Yıl",
          subtitle: "Orta-Uzun vade",
          value: "1-3 yıl",
          groupValue: _selectedVade,
          onTap: (val) => setState(() => _selectedVade = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "3+ Yıl",
          subtitle: "Uzun vadeli birikim",
          value: "3+ yıl",
          groupValue: _selectedVade,
          onTap: (val) => setState(() => _selectedVade = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
      ],
      textColor: textColor,
      isDark: isDark,
    );
  }

  // 2. ADIM: GETİRİ BEKLENTİSİ
  Widget _buildStep2Getiri(Color textColor, Color cardColor, bool isDark) {
    return _buildQuestionPage(
      title: "Getiri Beklentisi",
      subtitle: "Yatırımınızdan birincil beklentiniz nedir?",
      children: [
        _buildSelectableCard(
          title: "Enflasyondan Korunmak",
          subtitle: "Paramın değeri erimesin yeter",
          value: "Enflasyondan Korunmak",
          groupValue: _selectedGetiri,
          onTap: (val) => setState(() => _selectedGetiri = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Enflasyonu Geçmek",
          subtitle: "Reel bir getiri elde etmek",
          value: "Enflasyonu Geçmek",
          groupValue: _selectedGetiri,
          onTap: (val) => setState(() => _selectedGetiri = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Endeksi Geçmek",
          subtitle: "Borsa ortalamasından iyi kazanmak",
          value: "Endeksi Geçmek",
          groupValue: _selectedGetiri,
          onTap: (val) => setState(() => _selectedGetiri = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Diğer Araçları Geçmek",
          subtitle: "Maksimum getiri hedefi",
          value: "Diğer Yatırım Araçlarını Geçmek",
          groupValue: _selectedGetiri,
          onTap: (val) => setState(() => _selectedGetiri = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
      ],
      textColor: textColor,
      isDark: isDark,
    );
  }

  // 3. ADIM: DÜŞÜŞE BAKIŞ AÇISI
  Widget _buildStep3Dusus(Color textColor, Color cardColor, bool isDark) {
    return _buildQuestionPage(
      title: "Düşüşe Bakış Açısı",
      subtitle: "Piyasa sert düştüğünde tepkiniz ne olur?",
      children: [
        _buildSelectableCard(
          title: "Direkt Satış",
          subtitle: "Panik yaparım, hemen satarım",
          value: "Direkt Satış",
          groupValue: _selectedDusus,
          onTap: (val) => setState(() => _selectedDusus = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Kısmi Satış",
          subtitle: "Riskimi azaltmak için biraz satarım",
          value: "Kısmi Satış",
          groupValue: _selectedDusus,
          onTap: (val) => setState(() => _selectedDusus = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Durağan Pozisyon",
          subtitle: "Beklerim, ellemem",
          value: "Durağan Pozisyon",
          groupValue: _selectedDusus,
          onTap: (val) => setState(() => _selectedDusus = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Alım Fırsatı",
          subtitle: "Düşüşü fırsat bilip ekleme yaparım",
          value: "Alım Fırsatı",
          groupValue: _selectedDusus,
          onTap: (val) => setState(() => _selectedDusus = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
      ],
      textColor: textColor,
      isDark: isDark,
    );
  }

  // 4. ADIM: FİNANS PİYASALARINA HAKİMİYET
  Widget _buildStep4Bilgi(Color textColor, Color cardColor, bool isDark) {
    return _buildQuestionPage(
      title: "Finansal Bilgi",
      subtitle: "Piyasalar hakkındaki bilginiz ne düzeyde?",
      children: [
        _buildSelectableCard(
          title: "Hiç Bilgisi Yok",
          subtitle: "Yatırıma yeni başlıyorum",
          value: "Hiç Bilgisi Yok",
          groupValue: _selectedBilgi,
          onTap: (val) => setState(() => _selectedBilgi = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Başlangıç Seviye Bilgi",
          subtitle: "Temel kavramları biliyorum",
          value: "Başlangıç Seviye Bilgi",
          groupValue: _selectedBilgi,
          onTap: (val) => setState(() => _selectedBilgi = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Orta Düzey Bilgi",
          subtitle: "Analiz yapabilirim, takip ederim",
          value: "Orta Düzey Bilgi",
          groupValue: _selectedBilgi,
          onTap: (val) => setState(() => _selectedBilgi = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "İleri Düzey Bilgi",
          subtitle: "Profesyonel düzeyde hakimim",
          value: "İleri Düzey Bilgi",
          groupValue: _selectedBilgi,
          onTap: (val) => setState(() => _selectedBilgi = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
      ],
      textColor: textColor,
      isDark: isDark,
    );
  }

  // 5. ADIM: RİSK YÖNETİMİ
  Widget _buildStep5Risk(Color textColor, Color cardColor, bool isDark) {
    return _buildQuestionPage(
      title: "Risk Yönetimimiz Nasıldır",
      subtitle: "Yatırım karakteriniz hangisine daha yakın?",
      children: [
        _buildSelectableCard(
          title: "Hiç Risk Almam",
          subtitle: "Ana param garantide olsun",
          value: "Hiç Risk Almam",
          groupValue: _selectedRiskYonetimi,
          onTap: (val) => setState(() => _selectedRiskYonetimi = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Gerektiğinde Risk Alırım",
          subtitle: "Makul getiri için makul risk",
          value: "Gerektiğinde Risk Alırım",
          groupValue: _selectedRiskYonetimi,
          onTap: (val) => setState(() => _selectedRiskYonetimi = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Risk Almayı Severim",
          subtitle: "Yüksek getiri hedeflerim",
          value: "Risk Almayı Severim",
          groupValue: _selectedRiskYonetimi,
          onTap: (val) => setState(() => _selectedRiskYonetimi = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
        _buildSelectableCard(
          title: "Çok Yüksek Risk Almayı Severim",
          subtitle: "Kazanmak için her şeyi göze alırım",
          value: "Çok Yüksek Risk Almayı Severim",
          groupValue: _selectedRiskYonetimi,
          onTap: (val) => setState(() => _selectedRiskYonetimi = val),
          cardColor: cardColor,
          textColor: textColor,
          isDark: isDark,
        ),
      ],
      textColor: textColor,
      isDark: isDark,
    );
  }

  Widget _buildQuestionPage({
    required String title,
    required String subtitle,
    required List<Widget> children,
    required Color textColor,
    required bool isDark,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: isDark ? Colors.grey : Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ...children, // Seçenekleri buraya ekle
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- ORTAK KART BİLEŞENİ ---
  // Seçenek kartlarını oluşturur
  Widget _buildSelectableCard({
    required String title,
    required String subtitle,
    required String value,
    required String? groupValue,
    required Function(String) onTap,
    required Color cardColor,
    required Color textColor,
    required bool isDark,
    IconData? icon,
  }) {
    final isSelected = groupValue == value;

    // İkon arka plan rengi
    final iconBgColor =
        isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100;
    // İkon rengi
    final iconColor = isDark ? Colors.white70 : Colors.grey.shade700;

    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          // Seçili ise yeşil çerçeve, değilse silik çerçeve
          border: Border.all(
            color:
                isSelected
                    ? green
                    : (isDark ? Colors.transparent : Colors.grey.shade300),
            width: 1.5,
          ),
          // Hafif gölge efekti (Sadece light modda)
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
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
                    style: TextStyle(
                      color: isDark ? Colors.grey : Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Seçili ise sağ tarafta yeşil tik işareti
            if (isSelected) Icon(Icons.check, color: primary, size: 20),
          ],
        ),
      ),
    );
  }
}
