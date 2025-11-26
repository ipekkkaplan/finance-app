import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_app/screens/auth_screen/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/core/theme/theme_provider.dart';
import 'package:finance_app/services/auth_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool twoFactorEnabled = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      twoFactorEnabled = prefs.getBool("twoFactor") ?? false;
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool("twoFactor", twoFactorEnabled);
  }

  bool isValidPassword(String s) {
    final hasUpper = s.contains(RegExp(r'[A-Z]'));
    final hasLower = s.contains(RegExp(r'[a-z]'));
    final hasNumber = s.contains(RegExp(r'[0-9]'));
    final longEnough = s.length >= 8;
    return hasUpper && hasLower && hasNumber && longEnough;
  }

  void showChangePasswordDialog() {
    final theme = Theme.of(context);

    TextEditingController oldPass = TextEditingController();
    TextEditingController newPass = TextEditingController();
    TextEditingController confirmPass = TextEditingController();

    ValueNotifier<bool> isNewValid = ValueNotifier(false);
    ValueNotifier<bool> isConfirmValid = ValueNotifier(false);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text(
            "Kullanıcı Şifresini Yenile",
            style: TextStyle(color: theme.textTheme.bodyMedium!.color),
          ),
          content: StatefulBuilder(
            builder: (context, setStatePopup) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _passwordField(
                    controller: oldPass,
                    label: "Eski Şifre",
                    theme: theme,
                    borderColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder(
                    valueListenable: isNewValid,
                    builder: (context, valid, _) {
                      return _passwordField(
                        controller: newPass,
                        label: "Yeni Şifre",
                        theme: theme,
                        borderColor: valid ? Colors.green : Colors.redAccent,
                        icon:
                            valid
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(
                                  Icons.close,
                                  color: Colors.redAccent,
                                ),
                        onChanged: (val) {
                          final v = isValidPassword(val) && val != oldPass.text;
                          isNewValid.value = v;
                          isConfirmValid.value = (confirmPass.text == val && v);
                          setStatePopup(() {});
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder(
                    valueListenable: isConfirmValid,
                    builder: (context, valid, _) {
                      return _passwordField(
                        controller: confirmPass,
                        label: "Yeni Şifre (Tekrar)",
                        theme: theme,
                        borderColor: valid ? Colors.green : Colors.redAccent,
                        icon:
                            valid
                                ? const Icon(Icons.check, color: Colors.green)
                                : const Icon(
                                  Icons.close,
                                  color: Colors.redAccent,
                                ),
                        onChanged: (val) {
                          isConfirmValid.value =
                              (val == newPass.text && isNewValid.value);
                          setStatePopup(() {});
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "İptal",
                style: TextStyle(color: theme.textTheme.bodySmall!.color),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (newPass.text == oldPass.text) {
                  _error("Yeni şifre eski şifreyle aynı olamaz.");
                  return;
                }
                if (newPass.text != confirmPass.text) {
                  _error("Yeni şifreler eşleşmiyor.");
                  return;
                }
                if (!isValidPassword(newPass.text)) {
                  _error("Şifre kurallarına uymuyor.");
                  return;
                }

                final result = await _authService.changePassword(
                  oldPassword: oldPass.text,
                  newPassword: newPass.text,
                );

                if (!mounted) return;

                if (result['success'] == false) {
                  _error(result['message']);
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Şifre başarıyla değiştirildi."),
                    ),
                  );
                }
              },
              child: Text(
                "Kaydet",
                style: TextStyle(color: theme.colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required ThemeData theme,
    required Color borderColor,
    Icon? icon,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      onChanged: onChanged,
      style: TextStyle(color: theme.textTheme.bodyMedium!.color),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textTheme.bodySmall!.color),
        suffixIcon: icon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 2),
        ),
      ),
    );
  }

  void showDeleteAccountDialog() {
    final theme = Theme.of(context);
    final TextEditingController pass = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: const Text(
            "Hesabı Sil",
            style: TextStyle(color: Colors.redAccent),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Devam etmek için hesabınızın şifresini girin:",
                style: TextStyle(color: theme.textTheme.bodyMedium!.color),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pass,
                obscureText: true,
                style: TextStyle(color: theme.textTheme.bodyMedium!.color),
                decoration: const InputDecoration(
                  labelText: "Şifre",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.redAccent, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "İptal",
                style: TextStyle(color: theme.textTheme.bodySmall!.color),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (pass.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Şifre boş olamaz.")),
                  );
                  return;
                }

                final result = await _authService.deleteAccount(
                  password: pass.text,
                );

                if (!mounted) return;

                if (result['success'] == false) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result['message'])));
                  return;
                }

                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hesap başarıyla silindi.")),
                );
              },
              child: const Text(
                "Sil",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void logoutUser() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  Widget settingCard({required Widget child}) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "Ayarlar",
          style: TextStyle(
            color: theme.textTheme.bodyMedium!.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          settingCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Kullanıcı Şifresini Yenile",
                style: TextStyle(color: theme.textTheme.bodyMedium!.color),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: theme.textTheme.bodyMedium!.color,
                size: 16,
              ),
              onTap: showChangePasswordDialog,
            ),
          ),

          // İKİ ADIMLI DOĞRULAMA
          settingCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "İki Adımlı Doğrulama",
                  style: TextStyle(color: theme.textTheme.bodyMedium!.color),
                ),
                Switch(
                  value: twoFactorEnabled,
                  onChanged: (v) async {
                    setState(() => twoFactorEnabled = v);
                    await saveSettings();

                    if (v) {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: theme.cardColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 60,
                                    height: 5,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(.4),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                Text(
                                  "İki Adımlı Doğrulama Aktif",
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium!.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Giriş yaparken email adresinize 6 haneli bir kod gönderilecek. "
                                  "Bu kodu girerek oturum açabileceksiniz.",
                                  style: TextStyle(
                                    color: theme.textTheme.bodySmall!.color,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "Tamam",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          settingCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Uygulama Teması",
                  style: TextStyle(color: theme.textTheme.bodyMedium!.color),
                ),
                GestureDetector(
                  onTap: () => themeProvider.toggleTheme(),
                  child: Icon(
                    themeProvider.isDarkMode
                        ? Icons.nightlight_round
                        : Icons.wb_sunny,
                    color:
                        themeProvider.isDarkMode
                            ? Colors.yellowAccent
                            : theme.textTheme.bodyMedium!.color,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          settingCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                "Hesaptan Çık",
                style: TextStyle(color: theme.textTheme.bodyMedium!.color),
              ),
              trailing: Icon(
                Icons.logout,
                color: theme.textTheme.bodyMedium!.color,
              ),
              onTap: logoutUser,
            ),
          ),

          const SizedBox(height: 40),

          settingCard(
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text(
                "Hesabı Sil",
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: showDeleteAccountDialog,
            ),
          ),
        ],
      ),
    );
  }
}
