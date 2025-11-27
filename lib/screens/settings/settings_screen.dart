import 'package:flutter/material.dart';
import '../../services/auth_service.dart';// AuthService path’ini güncelle
import 'update_profile_screen.dart'; // UpdateProfileScreen dosya yolunu güncelle

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color darkBg = const Color(0xFF0D1117);
  final Color primary = const Color(0xFF3D8BFF); // mavi
  final Color icons_colors = const Color(0xFF4CAF50); // bildirim ikonu rengi

  bool darkMode = false;
  bool notifications = false;

  // TextEditingController'lar
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;

    nameController = TextEditingController(
        text: user != null ? (user.displayName ?? '') : '');
    emailController = TextEditingController(
        text: user != null ? (user.email ?? '') : '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D193F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ayarlar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Hesap ve uygulama tercihlerini yönet.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 26),

              // PROFİL KARTI
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _settingsCard(
                  title: "Profil Bilgileri",
                  icon: Icons.person_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inputField("Ad Soyad", nameController),
                      const SizedBox(height: 10),
                      _inputField("E-posta", emailController),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Yeni sayfaya yönlendirme
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const UpdateProfileScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: icons_colors,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              "Bilgileri Güncelle",
                              style: TextStyle(
                                color: Colors.black,
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
                title: "Uygulama Tercihleri",
                icon: null,
                child: Column(
                  children: [
                    _switchRow(
                      title: "Karanlık Mod",
                      subtitle: darkMode ? "Açık" : "Kapalı",
                      icon: darkMode
                          ? Icons.dark_mode_outlined
                          : Icons.wb_sunny_outlined,
                      iconColor:
                      darkMode ? primary : const Color(0xFFFFC107),
                      value: darkMode,
                      onChange: (v) => setState(() => darkMode = v),
                    ),
                    const SizedBox(height: 20),
                    _switchRow(
                      title: "Bildirimler",
                      subtitle: notifications ? "Açık" : "Kapalı",
                      icon: notifications
                          ? Icons.notifications_none
                          : Icons.notifications_off,
                      value: notifications,
                      onChange: (v) => setState(() => notifications = v),
                      iconColor: icons_colors,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              // GÜVENLİK VE GİZLİLİK KARTI
              _settingsCard(
                title: "Güvenlik ve Gizlilik",
                icon: Icons.security_outlined,
                iconColor: primary,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(
                    "FinScope AI, kişisel verilerinizi güvenli bir şekilde saklar. "
                        "Finansal bilgileriniz şifrelenir ve üçüncü taraflarla paylaşılmaz.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
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
                  children: const [
                    Text(
                      "FinScope AI",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Versiyon 1.0.0",
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F162C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: iconColor ?? icons_colors, size: 22),
                const SizedBox(width: 10),
              ],
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
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
  Widget _inputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0D1117),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: primary,
          onChanged: onChange,
        ),
      ],
    );
  }
}
