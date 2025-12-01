import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../services/auth_service.dart'; // Auth servisini geri açtık
import 'update_profile_screen.dart'; // Profil güncelleme sayfasını geri açtık

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Sabit renkleri buradan kaldırdık, temadan alacağız.
  final Color primary = const Color(0xFF3D8BFF);
  final Color iconsColors = const Color(0xFF4CAF50);

  bool notifications = false;

  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    // AuthService'den gerçek kullanıcıyı çekiyoruz
    final user = AuthService().currentUser;

    nameController = TextEditingController(
      text: user != null ? (user.displayName ?? '') : '',
    );
    emailController = TextEditingController(
      text: user != null ? (user.email ?? '') : '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider'a erişiyoruz
    final themeProvider = Provider.of<ThemeProvider>(context);
    // Renkleri artık Temadan çekiyoruz
    final isDark = themeProvider.isDarkMode;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor, // Dinamik arka plan
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ayarlar",
                style: TextStyle(
                  color: textColor, // Dinamik renk
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Hesap ve uygulama tercihlerini yönet.",
                style: TextStyle(
                  color: subTextColor, // Dinamik renk
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 26),

              // PROFİL KARTI
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _settingsCard(
                  cardColor: cardColor,
                  textColor: textColor,
                  title: "Profil Bilgileri",
                  icon: Icons.person_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inputField("Ad Soyad", nameController, isDark, textColor),
                      const SizedBox(height: 10),
                      _inputField("E-posta", emailController, isDark, textColor),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Yönlendirmeyi geri açtık
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UpdateProfileScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: iconsColors,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Bilgileri Güncelle",
                              style: TextStyle(
                                color: Colors.black, // Buton içi hep siyah kalabilir
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // UYGULAMA TERCİHLERİ KARTI
              _settingsCard(
                cardColor: cardColor,
                textColor: textColor,
                title: "Uygulama Tercihleri",
                icon: null,
                child: Column(
                  children: [
                    _switchRow(
                      title: "Karanlık Mod",
                      subtitle: isDark ? "Açık" : "Kapalı",
                      textColor: textColor,
                      subTextColor: subTextColor,
                      icon: isDark
                          ? Icons.dark_mode_outlined
                          : Icons.wb_sunny_outlined,
                      iconColor: isDark ? primary : const Color(0xFFFFC107),
                      // Burayı Provider'a bağladık:
                      value: isDark,
                      onChange: (v) {
                        themeProvider.toggleTheme(v);
                      },
                    ),
                    const SizedBox(height: 20),
                    _switchRow(
                      title: "Bildirimler",
                      subtitle: notifications ? "Açık" : "Kapalı",
                      textColor: textColor,
                      subTextColor: subTextColor,
                      icon: notifications
                          ? Icons.notifications_none
                          : Icons.notifications_off,
                      value: notifications,
                      onChange: (v) => setState(() => notifications = v),
                      iconColor: iconsColors,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // GÜVENLİK VE GİZLİLİK KARTI
              _settingsCard(
                cardColor: cardColor,
                textColor: textColor,
                title: "Güvenlik ve Gizlilik",
                icon: Icons.security_outlined,
                iconColor: primary,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "FinScope AI, kişisel verilerinizi güvenli bir şekilde saklar. "
                        "Finansal bilgileriniz şifrelenir ve üçüncü taraflarla paylaşılmaz.",
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Alt bilgi
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "FinScope AI",
                      style: TextStyle(color: subTextColor, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Versiyon 1.0.0",
                      style: TextStyle(color: subTextColor.withOpacity(0.5), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------ CARD ------------------
  Widget _settingsCard({
    required String title,
    IconData? icon,
    required Widget child,
    Color? iconColor,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: cardColor, // Dinamik kart rengi
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            // Light modda border görünmesin veya çok silik olsun
            color: textColor.withOpacity(0.05),
          ),
          boxShadow: [
            // Light modda hafif gölge, Dark modda yok
            if (Theme.of(context).brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor ?? iconsColors, size: 22),
                const SizedBox(width: 10),
              ],
              Text(
                title,
                style: TextStyle(
                  color: textColor, // Dinamik başlık rengi
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // ------------------ INPUT ------------------
  Widget _inputField(String label, TextEditingController controller, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            // Input alanı dark modda koyu, light modda hafif gri
            fillColor: isDark ? const Color(0xFF0D1117) : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------ SWITCH ROW ------------------
  Widget _switchRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Function(bool) onChange,
    Color? iconColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: iconColor ?? primary, size: 22),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Switch(
            value: value,
            activeColor: primary,
            onChanged: onChange
        ),
      ],
    );
  }
}