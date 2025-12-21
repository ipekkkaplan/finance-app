import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finance_app/screens/portfolio/portfolio_screen.dart'; // Dosya yolunun doğru olduğundan emin olun

class AnalysisWizardScreen extends StatefulWidget {
  const AnalysisWizardScreen({super.key});

  @override
  State<AnalysisWizardScreen> createState() => _AnalysisWizardScreenState();
}

class _AnalysisWizardScreenState extends State<AnalysisWizardScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false; // Firebase işlemi sırasında loading göstermek için

  // --- SABİT MARKA RENKLERİ ---
  final Color primary = const Color(0xFF3D8BFF);
  final Color green = const Color(0xFF00C853);

  // --- SEÇİM DEĞİŞKENLERİ  --
  String? _selectedVade;
  String? _selectedGetiri;
  String? _selectedDusus;
  String? _selectedBilgi;
  String? _selectedRiskYonetimi;

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
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Yükleniyor göstergesi
              : Column(
                children: [
                  // ÜST KISIMDAKİ PROGRESS BAR (İlerleme Çubuğu)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: List.generate(5, (index) {
                        return Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color:
                                  index <= _currentPage
                                      ? green
                                      : progressInactiveColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // SAYFA İÇERİĞİ (PageView)
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      children: [
                        _buildStep1Vade(textColor, cardColor, isDark),
                        _buildStep2Getiri(textColor, cardColor, isDark),
                        _buildStep3Dusus(textColor, cardColor, isDark),
                        _buildStep4Bilgi(textColor, cardColor, isDark),
                        _buildStep5Risk(textColor, cardColor, isDark),
                      ],
                    ),
                  ),

                  // ALT BUTONLAR (Geri / Devam Et)
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
                                  color:
                                      isDark
                                          ? Colors.grey[800]!
                                          : Colors.grey[400]!,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                  _currentPage == 4 ? "Tamamla" : "Devam Et",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
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

  // --- İLERLEME VE MANTIK ---
  void _nextPage() {
    // Mevcut sayfada seçim yapılmamışsa ilerletme
    if (_currentPage == 0 && _selectedVade == null) {
      return _showError("Lütfen vade seçiniz");
    }

    if (_currentPage == 1 && _selectedGetiri == null) {
      return _showError("Lütfen beklentinizi seçiniz");
    }

    if (_currentPage == 2 && _selectedDusus == null) {
      return _showError("Lütfen bir seçenek işaretleyiniz");
    }

    if (_currentPage == 3 && _selectedBilgi == null) {
      return _showError("Lütfen bilgi düzeyinizi seçiniz");
    }

    if (_currentPage == 4 && _selectedRiskYonetimi == null) {
      return _showError("Lütfen risk tercihinizi seçiniz");
    }

    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // SON AŞAMA: Hesapla ve Kaydet
      _calculateAndSaveProfile();
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _calculateAndSaveProfile() async {
    setState(() => _isLoading = true);

    //Puanlama
    double totalScore = 0;

    // Soru 1: Vade
    if (_selectedVade == "0-6 ay") {
      totalScore += 100;
    } else if (_selectedVade == "6-12 ay") {
      totalScore += 75;
    } else if (_selectedVade == "1-3 yıl") {
      totalScore += 50;
    } else if (_selectedVade == "3+ yıl") {
      totalScore += 25;
    }

    // Soru 2: Getiri
    if (_selectedGetiri == "Enflasyondan Korunmak") {
      totalScore += 25;
    } else if (_selectedGetiri == "Enflasyonu Geçmek") {
      totalScore += 50;
    } else if (_selectedGetiri == "Endeksi Geçmek") {
      totalScore += 75;
    } else if (_selectedGetiri == "Diğer Yatırım Araçlarını Geçmek") {
      totalScore += 100;
    }

    // Soru 3: Düşüş
    if (_selectedDusus == "Direkt Satış") {
      totalScore += 25;
    } else if (_selectedDusus == "Kısmi Satış") {
      totalScore += 50;
    } else if (_selectedDusus == "Durağan Pozisyon") {
      totalScore += 75;
    } else if (_selectedDusus == "Alım Fırsatı") {
      totalScore += 100;
    }

    // Soru 4: Bilgi
    if (_selectedBilgi == "Hiç Bilgisi Yok") {
      totalScore += 25;
    } else if (_selectedBilgi == "Başlangıç Seviye Bilgi") {
      totalScore += 50;
    } else if (_selectedBilgi == "Orta Düzey Bilgi") {
      totalScore += 75;
    } else if (_selectedBilgi == "İleri Düzey Bilgi") {
      totalScore += 100;
    }

    // Soru 5: Risk Tercihi
    if (_selectedRiskYonetimi == "Hiç Risk Almam") {
      totalScore += 25;
    } else if (_selectedRiskYonetimi == "Gerektiğinde Risk Alırım") {
      totalScore += 50;
    } else if (_selectedRiskYonetimi == "Risk Almayı Severim") {
      totalScore += 75;
    } else if (_selectedRiskYonetimi == "Çok Yüksek Risk Almayı Severim") {
      totalScore += 100;
    }

    // Ortalama Skor
    int finalScore = (totalScore / 5).round();

    //  Segment Belirleme
    String segment;
    if (finalScore <= 30) {
      segment = "Defansif";
    } else if (finalScore <= 70) {
      segment = "Dengeli";
    } else {
      segment = "Agresif";
    }

    //  Hisse Seçimi
    List<String> recommendedStocks = _getMockStocksForSegment(segment);

    // Firebase Kayıt
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('risk_profile')
            .add({
              'score': finalScore,
              'segment': segment,
              'answers': {
                'vade': _selectedVade,
                'getiri': _selectedGetiri,
                'dusus': _selectedDusus,
                'bilgi': _selectedBilgi,
                'risk': _selectedRiskYonetimi,
              },
              'recommended_stocks': recommendedStocks,
              'createdAt': FieldValue.serverTimestamp(),
            });

        debugPrint("Kayıt Başarılı: Skor $finalScore, Segment: $segment");

        if (mounted) {
          // Loading'i kapat
          setState(() => _isLoading = false);

          // SONUÇ EKRANINI GÖSTER (YENİ EKLENEN KISIM)
          _showResultDialog(finalScore, segment);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
        _showError("Kullanıcı oturumu bulunamadı.");
      }
    } catch (e) {
      debugPrint("Hata: $e");
      if (mounted) setState(() => _isLoading = false);
      _showError("Profil kaydedilirken bir hata oluştu.");
    }
  }

  // --- SONUÇ GÖSTERME POPUP'I ---
  void _showResultDialog(int score, String segment) {
    showDialog(
      context: context,
      barrierDismissible: false, // Boşluğa basınca kapanmasın
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Analiz Tamamlandı"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Yatırımcı Puanınız: $score",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Profil Segmentiniz: $segment",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Bu sonuçlara göre size özel portföy önerileri hazırlanmıştır. Portföy ekranına yönlendiriliyorsunuz.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Dialog'u kapat
                Navigator.of(context).pop();

                // Portföy Ekranına Git ve Geri Dönüşü Engelle
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PortfolioScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text("Portföyüme Git"),
            ),
          ],
        );
      },
    );
  }

  List<String> _getMockStocksForSegment(String segment) {
    switch (segment) {
      case "Defansif":
        return ["ALTINS1", "USDT", "PETKM"];
      case "Dengeli":
        return ["THYAO", "KCHOL", "SISE"];
      case "Agresif":
        return ["SASA", "HEKTS", "KONTR"];
      default:
        return [];
    }
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
          value: "0-6 ay",
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
          ...children,
          const SizedBox(height: 20),
        ],
      ),
    );
  }

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
    final iconBgColor =
        isDark ? Colors.white.withValues(alpha: .05) : Colors.grey.shade100;
    final iconColorCard = isDark ? Colors.white70 : Colors.grey.shade700;

    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? green
                    : (isDark ? Colors.transparent : Colors.grey.shade300),
            width: 1.5,
          ),
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
                child: Icon(icon, color: iconColorCard, size: 20),
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
            if (isSelected) Icon(Icons.check, color: primary, size: 20),
          ],
        ),
      ),
    );
  }
}
