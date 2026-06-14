// screens/algo_trade/algo_setup_view.dart
import 'package:flutter/material.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/di/locator.dart';

const _sektorler = [
  'Araci Kurum',
  'Bankacilik',
  'Cimento',
  'Dayanikli Tuketim',
  'Enerji',
  'GYO',
  'Gida',
  'Holding',
  'Metal Ana Sanayi',
  'Otomotiv',
  'Perakende',
  'Sanayi',
  'Savunma',
  'Teknoloji',
  'Tekstil',
  'Telekom',
  'Ulastirma',
];

// ── Ortak renk sabitleri ──────────────────────────────────────────
const _kTeal = AppColors.accentTeal;
const _kTeal2 = AppColors.tealDark;
const _kGlass = AppColors.glassFill;
const _kGlassBorder = AppColors.glassBorder;
const _kInnerGlass = AppColors.glassFillInner;

class AlgoSetupView extends StatefulWidget {
  final VoidCallback onBasladi;
  const AlgoSetupView({super.key, required this.onBasladi});

  @override
  State<AlgoSetupView> createState() => _AlgoSetupViewState();
}

class _AlgoSetupViewState extends State<AlgoSetupView> {
  final _servis = locator.algoTrade;
  final _sermayeCtrl = TextEditingController(text: '100000');
  final _beyazCtrl = TextEditingController();
  final _karaCtrl = TextEditingController();

  String _riskProfili = 'Dengeli';
  String _mod = 'AUTO';
  final Set<String> _secilenSektorler = {};
  bool _gonderiliyor = false;

  @override
  void initState() {
    super.initState();
    _servis.riskProfiliGetir().then((p) {
      if (mounted) setState(() => _riskProfili = p);
    });
  }

  @override
  void dispose() {
    _sermayeCtrl.dispose();
    _beyazCtrl.dispose();
    _karaCtrl.dispose();
    super.dispose();
  }

  List<String> _virgulluListe(String s) =>
      s
          .split(',')
          .map((e) => e.trim().toUpperCase())
          .where((e) => e.isNotEmpty)
          .toList();

  Future<void> _baslat() async {
    final sermaye = double.tryParse(_sermayeCtrl.text.trim());
    if (sermaye == null || sermaye <= 0) {
      _uyari('Geçerli bir sermaye girin.');
      return;
    }
    if (_mod == 'SECTOR' && _secilenSektorler.isEmpty) {
      _uyari('En az bir sektör seçin.');
      return;
    }
    if (_mod == 'WHITELIST' && _virgulluListe(_beyazCtrl.text).isEmpty) {
      _uyari('En az bir hisse girin.');
      return;
    }

    setState(() => _gonderiliyor = true);
    try {
      await _servis.oturumBaslat(
        sermaye: sermaye,
        riskProfili: _riskProfili,
        mod: _mod,
        izinliSektorler: _secilenSektorler.toList(),
        beyazListe: _virgulluListe(_beyazCtrl.text),
        karaListe: _virgulluListe(_karaCtrl.text),
      );
      widget.onBasladi();
    } catch (e) {
      _uyari('Başlatılamadı: $e');
    } finally {
      if (mounted) setState(() => _gonderiliyor = false);
    }
  }

  void _uyari(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ── Dekorasyon yardımcıları ─────────────────────────────────────
  BoxDecoration _glassCard({Color? accent}) => BoxDecoration(
    color: _kGlass,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: accent?.withValues(alpha: 0.25) ?? _kGlassBorder,
      width: 1,
    ),
  );

  InputDecoration _inputDeco(String hint, {String? prefix}) => InputDecoration(
    hintText: hint,
    prefixText: prefix,
    hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
    prefixStyle: const TextStyle(color: Colors.white60),
    filled: true,
    fillColor: _kInnerGlass,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kGlassBorder, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kTeal, width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        // ── Başlık ───────────────────────────────────────────────
        if (isDark) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kTeal.withValues(alpha: 0.25)),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: _kTeal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Algo Trade',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Yapay Zeka Destekli İşlem Sistemi',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // ── Sanal Sermaye ────────────────────────────────────────
        _glassSection(
          isDark,
          icon: Icons.account_balance_wallet_outlined,
          title: 'Sanal Sermaye',
          subtitle:
              'Gerçek para değil — sistem bu tutarla kağıt üzerinde işlem yapar.',
          accent: _kTeal,
          child: TextField(
            controller: _sermayeCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            decoration:
                isDark
                    ? _inputDeco('100000', prefix: '₺ ')
                    : InputDecoration(
                      prefixText: '₺ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
          ),
        ),

        // ── Risk Profili ─────────────────────────────────────────
        _glassSection(
          isDark,
          icon: Icons.shield_outlined,
          title: 'Risk Profili',
          subtitle: 'Mevcut risk anketinden alındı, tekrar sorulmaz.',
          accent: const Color(0xFFFFC107),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration:
                isDark
                    ? BoxDecoration(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFC107).withValues(alpha: 0.2),
                      ),
                    )
                    : null,
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: Color(0xFFFFC107),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  _riskProfili,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Kontrol Modu ─────────────────────────────────────────
        _glassSection(
          isDark,
          icon: Icons.tune_rounded,
          title: 'Kontrol Modu',
          subtitle: 'Algoritmanın hangi hisselerde işlem yapacağını belirle.',
          child: Column(
            children: [
              _modSecenek(
                isDark,
                'AUTO',
                'Tam Otomatik',
                'Algoritma BIST içinden kendi seçer.',
                Icons.flash_auto_rounded,
              ),
              _modSecenek(
                isDark,
                'SECTOR',
                'Sektör Tercihi',
                'Sadece seçtiğin sektörlerde işlem yapar.',
                Icons.domain_rounded,
              ),
              _modSecenek(
                isDark,
                'WHITELIST',
                'Hisse Listesi',
                'Sadece beyaz listedeki hisselerde işlem yapar.',
                Icons.list_alt_rounded,
              ),
            ],
          ),
        ),

        // ── Sektör seçimi ────────────────────────────────────────
        if (_mod == 'SECTOR')
          _glassSection(
            isDark,
            icon: Icons.grid_view_rounded,
            title: 'İzinli Sektörler',
            subtitle: 'Birden fazla seçebilirsin.',
            accent: _kTeal,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _sektorler.map((s) {
                    final secili = _secilenSektorler.contains(s);
                    return GestureDetector(
                      onTap:
                          () => setState(
                            () =>
                                secili
                                    ? _secilenSektorler.remove(s)
                                    : _secilenSektorler.add(s),
                          ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          gradient:
                              secili && isDark
                                  ? const LinearGradient(
                                    colors: [_kTeal, _kTeal2],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  )
                                  : null,
                          color:
                              secili
                                  ? (isDark ? null : _kTeal)
                                  : (isDark
                                      ? _kInnerGlass
                                      : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: secili ? Colors.transparent : _kGlassBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            color:
                                secili
                                    ? (isDark ? Colors.black87 : Colors.white)
                                    : (isDark
                                        ? Colors.white60
                                        : Colors.black54),
                            fontSize: 12,
                            fontWeight:
                                secili ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),

        // ── Beyaz Liste ──────────────────────────────────────────
        if (_mod == 'WHITELIST')
          _glassSection(
            isDark,
            icon: Icons.check_circle_outline_rounded,
            title: 'Beyaz Liste (Al)',
            subtitle:
                'Hisse kodlarını virgülle ayır.  Örnek: THYAO, ASELS, GARAN',
            accent: const Color(0xFF00C853),
            child: TextField(
              controller: _beyazCtrl,
              style: const TextStyle(color: Colors.white),
              decoration:
                  isDark
                      ? _inputDeco('THYAO, ASELS, GARAN...')
                      : InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
            ),
          ),

        // ── Kara Liste ───────────────────────────────────────────
        _glassSection(
          isDark,
          icon: Icons.block_rounded,
          title: 'Kara Liste (İsteğe Bağlı)',
          subtitle:
              'Bu hisselerde hiçbir modda işlem yapılmaz.  Örnek: SASA, KRDMD',
          accent: const Color(0xFFEF5350),
          child: TextField(
            controller: _karaCtrl,
            style: const TextStyle(color: Colors.white),
            decoration:
                isDark
                    ? _inputDeco('SASA, KRDMD...')
                    : InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
          ),
        ),

        const SizedBox(height: 8),

        // ── Başlat Butonu ────────────────────────────────────────
        Container(
          height: 54,
          decoration: BoxDecoration(
            gradient:
                isDark
                    ? const LinearGradient(
                      colors: [_kTeal, _kTeal2],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                    : null,
            color: isDark ? null : _kTeal,
            borderRadius: BorderRadius.circular(14),
            boxShadow:
                isDark
                    ? [
                      BoxShadow(
                        color: _kTeal.withValues(alpha: 0.30),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ]
                    : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _gonderiliyor ? null : _baslat,
              child: Center(
                child:
                    _gonderiliyor
                        ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black54,
                          ),
                        )
                        : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.black87,
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Sistemi Başlat',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Cam kart bölümü ─────────────────────────────────────────────
  Widget _glassSection(
    bool isDark, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
    Color? accent,
  }) {
    final accentColor = accent ?? _kTeal;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration:
          isDark
              ? _glassCard(accent: accent)
              : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.white30 : Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ── Mod radio item ───────────────────────────────────────────────
  Widget _modSecenek(
    bool isDark,
    String deger,
    String baslik,
    String aciklama,
    IconData icon,
  ) {
    final selected = _mod == deger;
    return GestureDetector(
      onTap: () => setState(() => _mod = deger),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color:
              selected
                  ? (isDark
                      ? _kTeal.withValues(alpha: 0.12)
                      : _kTeal.withValues(alpha: 0.08))
                  : (isDark ? _kInnerGlass : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _kTeal.withValues(alpha: 0.4) : _kGlassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  selected ? _kTeal : (isDark ? Colors.white38 : Colors.grey),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    aciklama,
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      selected
                          ? _kTeal
                          : (isDark ? Colors.white24 : Colors.grey.shade300),
                  width: 2,
                ),
                color: selected ? _kTeal : Colors.transparent,
              ),
              child:
                  selected
                      ? const Icon(Icons.check, color: Colors.white, size: 11)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
