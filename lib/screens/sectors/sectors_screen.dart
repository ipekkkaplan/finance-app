import 'package:flutter/material.dart';
import '../../models/sector_model.dart'; // Modeli import etmek için
import '../../services/data_service.dart'; // Servisini import etmek için
import 'company_detail_screen.dart';

class SectorsScreen extends StatefulWidget {
  const SectorsScreen({super.key});

  @override
  State<SectorsScreen> createState() => _SectorsScreenState();
}

class _SectorsScreenState extends State<SectorsScreen> {
  int _selectedFilterIndex = 0; // Filtre butonu için

  // Servis ve Future Tanımları
  final DataService _dataService = DataService();
  Future<List<SectorModel>>? _sectorsFuture;

  // Marka Renkleri (Sabit)
  final Color primary = const Color(0xFF3D8BFF);
  final Color green = const Color(0xFF00C853);
  final Color red = const Color(0xFFFF5252); // Düşük performans için ekledim

  @override
  void initState() {
    super.initState();
    _sectorsFuture = _dataService.loadSectorData();
  }

  // --- Filtreleme mantığı (Gerçek Veri İle) ---
  List<SectorModel> getFilteredSectors(List<SectorModel> allSectors) {
    switch (_selectedFilterIndex) {
      case 0: // Tümü
        return allSectors;
      case 1: // Yüksek Potansiyel (Değişim > %2.0)
        return allSectors.where((s) => s.dailyChange > 2.0).toList();
      case 2: // Orta Potansiyel (0 < Değişim <= 2.0)
        return allSectors
            .where((s) => s.dailyChange > 0 && s.dailyChange <= 2.0)
            .toList();
      case 3: // Düşük Potansiyel (Negatif)
        return allSectors.where((s) => s.dailyChange <= 0).toList();
      default:
        return allSectors;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema verilerini alıyoruz
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Dinamik renkler
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = isDark ? Colors.grey : Colors.grey[600];

    // Kart kenarlığı
    final borderColor = isDark
        ? Colors.transparent
        : Colors.grey.withValues(alpha: 0.2);
    // Metrik kutucukları rengi
    final metricCardBg =
    isDark ? const Color(0xFF1A2038) : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        // FutureBuilder ile asenkron veri yönetimi
        child: FutureBuilder<List<SectorModel>>(
          future: _sectorsFuture,
          builder: (context, snapshot) {
            // 1. Durum: Veri yükleniyor
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: primary));
            }
            // 2. Durum: Hata var
            else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: red, size: 40),
                    const SizedBox(height: 10),
                    Text("Veri yüklenemedi", style: TextStyle(color: textColor)),
                  ],
                ),
              );
            }
            // 3. Durum: Veri yok veya boş
            else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("Veri bulunamadı", style: TextStyle(color: textColor)));
            }

            // Veri başarıyla geldi
            final allSectors = snapshot.data!;
            final filteredList = getFilteredSectors(allSectors);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Başlık ve filtre ikonu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Sektör Analizi",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.filter_list, color: primary),
                    ],
                  ),
                  Text(
                    "Güncel piyasa performansı",
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // --- GRAPHIIC PLACEHOLDER (Senin tasarımın korundu) ---
                  _buildChartPlaceholder(
                    title: "Sektör Performans Karşılaştırması",
                    bgColor: cardColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: allSectors.take(6).map((sector) {
                        // Basit bir bar yüksekliği hesaplaması (Görsel amaçlı)
                        // Değişim oranına göre bar boyunu ve rengini ayarlıyoruz
                        double height = (sector.dailyChange.abs() * 10).clamp(10, 100);
                        return _buildBar(
                            sector.name.length > 3 ? sector.name.substring(0,3) : sector.name,
                            height,
                            sector.dailyChange >= 0 ? green : red,
                            subTextColor
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildChartPlaceholder(
                    title: "Sektör Trendleri (2025)",
                    bgColor: cardColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    child: Container(
                      height: 150,
                      alignment: Alignment.center,
                      child: Text(
                        "Grafik verileri hazırlanıyor...",
                        style: TextStyle(color: subTextColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Sektörler",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filtre Butonları
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _filterButton("Tümü", 0, cardColor, textColor, isDark),
                        _filterButton("Yüksek Potansiyel", 1, cardColor, textColor, isDark),
                        _filterButton("Orta Potansiyel", 2, cardColor, textColor, isDark),
                        _filterButton("Düşük Potansiyel", 3, cardColor, textColor, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sektör kartları (Dinamik Listeleme)
                  filteredList.isEmpty
                      ? Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: Text(
                      "Kriterlere uygun sektör yok",
                      style: TextStyle(color: subTextColor, fontSize: 16),
                    ),
                  )
                      : Column(
                    children: filteredList
                        .map((sector) => _buildSectorCard(
                      sector, // Artık SectorModel gönderiyoruz
                      cardColor,
                      textColor,
                      subTextColor,
                      metricCardBg,
                      borderColor,
                      isDark,
                    ))
                        .toList(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder({
    required String title,
    required Widget child,
    required Color bgColor,
    required Color textColor,
    required Color? subTextColor,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 180, child: child),
          const SizedBox(height: 8),
          Center(
            child: Text(
              "Piyasa değeri değişimi (%)",
              style: TextStyle(color: subTextColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
      String label, double height, Color color, Color? labelColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: height, // Dinamik yükseklik
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: labelColor, fontSize: 10)),
      ],
    );
  }

  Widget _filterButton(
      String text, int index, Color cardColor, Color textColor, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    final unselectedBg = isDark ? cardColor : Colors.grey.shade200;
    final unselectedText = isDark ? Colors.white70 : Colors.black87;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilterIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? green : unselectedBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.black : unselectedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // Sektör Kartı Oluşturucu - Model Entegrasyonu Yapıldı
  Widget _buildSectorCard(
      SectorModel sector, // ARTIK MODEL ALIYOR
      Color cardColor,
      Color textColor,
      Color? subTextColor,
      Color metricBgColor,
      Color borderColor,
      bool isDark,
      ) {
    // Dinamik Etiket Hesaplama
    String tag = "Nötr";
    Color tagColor = Colors.grey;
    if (sector.dailyChange > 2.0) {
      tag = "Yüksek";
      tagColor = green;
    } else if (sector.dailyChange > 0) {
      tag = "Orta";
      tagColor = primary;
    } else {
      tag = "Düşük";
      tagColor = red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    sector.name,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(color: tagColor, fontSize: 12),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${sector.dailyChange >= 0 ? '+' : ''}${sector.dailyChange}%",
                    style: TextStyle(
                        color: sector.dailyChange >= 0 ? green : red,
                        fontSize: 16),
                  ),
                  Text(
                    // Grade JSON'da yoksa sembolik hesaplama
                    sector.dailyChange > 1.5 ? "A+" : (sector.dailyChange > 0 ? "B" : "C"),
                    style: TextStyle(color: subTextColor, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text("${sector.name} Endeks Şirketleri",
              style: TextStyle(color: subTextColor)),
          const SizedBox(height: 20),

          // METRİKLER - Gerçek verilerle güncellendi
          Row(
            children: [
              _metricItem("Günlük", "%${sector.dailyChange}", metricBgColor, textColor,
                  subTextColor, isGrowth: sector.dailyChange > 0),
              const SizedBox(width: 12),
              _metricItem("Haftalık", "%${sector.weeklyChange}", metricBgColor, textColor,
                  subTextColor, isGrowth: sector.weeklyChange > 0),
              const SizedBox(width: 12),
              _metricItem("Aylık", "%${sector.monthlyChange}", metricBgColor, textColor,
                  subTextColor, isGrowth: sector.monthlyChange > 0),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompanyDetailScreen(
                      companyName: "${sector.name} Şirketleri",
                      ticker: "X${sector.name.substring(0, (sector.name.length > 3 ? 3 : sector.name.length)).toUpperCase()}",
                      sector: sector.name,
                    ),
                  ),
                );
              },
              icon: const Text(
                "Şirketleri İncele",
                style: TextStyle(color: Colors.greenAccent),
              ),
              label: const Icon(
                Icons.arrow_forward,
                color: Colors.greenAccent,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricItem(String label, String value, Color bgColor, Color textColor,
      Color? labelColor,
      {bool isGrowth = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: labelColor, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: isGrowth ? green : (value.contains('-') ? red : textColor),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}