import 'package:flutter/material.dart';

/// Boş veri / hata / yükleniyor durumları için tutarlı placeholder kartı.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  factory EmptyState.error({String? message}) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Bir sorun oluştu',
      subtitle: message ?? 'Bağlantınızı kontrol edip tekrar deneyin.',
    );
  }

  factory EmptyState.noData({String? message}) {
    return EmptyState(
      icon: Icons.inbox_outlined,
      title: 'Veri bulunamadı',
      subtitle: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey.withValues(alpha: 0.3);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: subTextColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: TextStyle(color: subTextColor, fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
