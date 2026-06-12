// screens/settings/settings_screen.dart
import 'package:finance_app/screens/auth_screen/launch_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';
import '../../services/auth_service.dart';
import 'update_profile_screen.dart';

// ── Tema sabitleri ────────────────────────────────────────────────
const _kBgTop = Color(0xFF07111F);
const _kBgMid = Color(0xFF0C1B31);
const _kBgBot = Color(0xFF0F2040);
const _kTeal = Color(0xFF00C9A7);
const _kCard = Color(0xFF132040);
const _kCardInner = Color(0xFF0C1A30);
const _kGlassBorder = Color(0x18FFFFFF);
const _kLoss = Color(0xFFEF5350);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = false;
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LaunchScreen()),
        (_) => false,
      );
    }
  }

  // ── Kart dekorasyonu ─────────────────────────────────────────────
  BoxDecoration _cardDeco(bool isDark) => BoxDecoration(
    color: isDark ? _kCard : Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: isDark ? _kGlassBorder : Colors.grey.shade200),
    boxShadow:
        isDark
            ? null
            : [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
  );

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF102C57);
    final subTextColor = isDark ? Colors.white54 : Colors.grey.shade600;

    final body = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // ── Başlık ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ayarlar",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hesap ve uygulama tercihleri",
                    style: TextStyle(color: subTextColor, fontSize: 13),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kTeal.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isDark
                          ? Border.all(color: _kTeal.withValues(alpha: 0.25))
                          : null,
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: _kTeal,
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Profil Kartı ─────────────────────────────────────────
          _sectionLabel("Profil Bilgileri", Icons.person_outline, textColor),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDeco(isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: _kTeal.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _kTeal.withValues(alpha: 0.40),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: _kTeal,
                          size: 38,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: _kTeal,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _inputField("Ad Soyad", _nameController, isDark, textColor),
                const SizedBox(height: 14),
                _inputField("E-posta", _emailController, isDark, textColor),
                const SizedBox(height: 20),

                // Profil güncelle butonu (teal outlined)
                GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UpdateProfileScreen(),
                        ),
                      ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _kTeal.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _kTeal.withValues(alpha: isDark ? 0.30 : 0.25),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "Bilgileri Güncelle",
                        style: TextStyle(
                          color: _kTeal,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Uygulama Tercihleri ──────────────────────────────────
          _sectionLabel("Uygulama Tercihleri", Icons.tune_rounded, textColor),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDeco(isDark),
            child: Column(
              children: [
                _switchRow(
                  title: "Karanlık Mod",
                  subtitle: isDark ? "Açık" : "Kapalı",
                  icon:
                      isDark
                          ? Icons.dark_mode_outlined
                          : Icons.wb_sunny_outlined,
                  iconColor: isDark ? _kTeal : const Color(0xFFFFC107),
                  value: isDark,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onChange: (v) => themeProvider.toggleTheme(v),
                ),
                const SizedBox(height: 20),
                _switchRow(
                  title: "Bildirimler",
                  subtitle: notifications ? "Açık" : "Kapalı",
                  icon:
                      notifications
                          ? Icons.notifications_none
                          : Icons.notifications_off,
                  iconColor: _kTeal,
                  value: notifications,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  onChange: (v) => setState(() => notifications = v),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(
                    color: isDark ? _kGlassBorder : Colors.grey.shade200,
                  ),
                ),

                // Çıkış butonu
                InkWell(
                  onTap: _handleLogout,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _kLoss.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: _kLoss,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          "Güvenli Çıkış",
                          style: TextStyle(
                            color: _kLoss,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: subTextColor.withValues(alpha: 0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Güvenlik Kartı ───────────────────────────────────────
          _sectionLabel(
            "Güvenlik ve Gizlilik",
            Icons.security_outlined,
            textColor,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _cardDeco(isDark),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: _kTeal.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kTeal.withValues(alpha: 0.20)),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: _kTeal,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: Text(
                    "FinScope AI, kişisel verilerinizi güvenli biçimde saklar. "
                    "Finansal bilgileriniz şifrelenir ve üçüncü taraflarla paylaşılmaz.",
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // ── Alt bilgi ────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? _kCardInner : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? _kGlassBorder : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: _kTeal),
                      const SizedBox(width: 6),
                      Text(
                        "FinScope AI  ·  v1.0.0",
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? _kBgTop : const Color(0xFFF5F5F5),
      body:
          isDark
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
                  SafeArea(child: body),
                ],
              )
              : SafeArea(child: body),
    );
  }

  // ── Helper: Bölüm etiketi ─────────────────────────────────────────
  Widget _sectionLabel(String title, IconData icon, Color textColor) => Row(
    children: [
      Container(
        width: 4,
        height: 18,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: _kTeal,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      Icon(icon, size: 18, color: _kTeal),
      const SizedBox(width: 8),
      Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  // ── Helper: Input alanı ───────────────────────────────────────────
  Widget _inputField(
    String label,
    TextEditingController controller,
    bool isDark,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey.shade600,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? _kCardInner : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? _kGlassBorder : Colors.grey.shade200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kTeal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helper: Switch satırı ─────────────────────────────────────────
  Widget _switchRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required Function(bool) onChange,
    required Color textColor,
    required Color subTextColor,
  }) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(subtitle, style: TextStyle(color: subTextColor, fontSize: 12)),
          ],
        ),
      ),
      Switch(
        value: value,
        activeColor: _kTeal,
        activeTrackColor: _kTeal.withValues(alpha: 0.30),
        onChanged: onChange,
      ),
    ],
  );
}
