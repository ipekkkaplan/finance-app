// widgets/app_card.dart
import 'package:flutter/material.dart';
import '../core/theme/color_scheme.dart';

/// Koyu tema "cam" kart dekorasyonu — tek kaynaktan.
///
/// Önceden her ekranda `_glass()` / `_cardDeco()` olarak kopyalanıyordu.
/// Davranış birebir korundu: koyu kart yüzeyi + ince beyaz border.
BoxDecoration glassCardDecoration({
  double radius = 16,
  Color? borderColor,
}) =>
    BoxDecoration(
      color: AppColors.darkCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.glassBorder, width: 1),
    );

/// Açık tema düz kart dekorasyonu (yumuşak gölge).
BoxDecoration lightCardDecoration(
  Color cardColor, {
  bool withShadow = true,
  double radius = 16,
}) =>
    BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

/// Yeni ekranlar için hazır kart sarmalayıcı. Tema-uyumlu:
/// koyu temada cam dekor, açık temada gölgeli düz kart.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
    this.borderColor,
    this.lightColor = Colors.white,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? borderColor;
  final Color lightColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: isDark
          ? glassCardDecoration(radius: radius, borderColor: borderColor)
          : lightCardDecoration(lightColor, radius: radius),
      child: child,
    );
  }
}
