import 'package:flutter/material.dart';

import '../core/theme/color_scheme.dart';
import '../models/sentiment_model.dart';
import '../models/signal_model.dart';

/// Renkli, kompakt durum rozeti. Hem sinyal hem de sentiment için kullanılır.
///
/// Stil tek bir yerden yönetilir; tutarlılık için bütün uygulamada bu widget
/// tercih edilir.
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
    this.compact = false,
  });

  /// Sinyal türünden otomatik olarak rozet oluşturur.
  factory StatusBadge.fromSignal(SignalType type, {bool compact = false}) {
    final (label, color, icon) = _signalStyle(type);
    return StatusBadge(
      text: compact ? type.shortLabel : label,
      color: color,
      icon: icon,
      compact: compact,
    );
  }

  /// Sentiment türünden otomatik olarak rozet oluşturur.
  factory StatusBadge.fromSentiment(SentimentType type, {bool compact = false}) {
    final (color, icon) = _sentimentStyle(type);
    return StatusBadge(
      text: type.label,
      color: color,
      icon: icon,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pad = compact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);

    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 11 : 13, color: color),
            SizedBox(width: compact ? 3 : 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  static (String, Color, IconData) _signalStyle(SignalType type) {
    switch (type) {
      case SignalType.strongBuy:
        return ('GÜÇLÜ AL', AppColors.profitLight, Icons.trending_up);
      case SignalType.buy:
        return ('AL', const Color(0xFF4CAF50), Icons.arrow_upward);
      case SignalType.hold:
        return ('BEKLE', const Color(0xFFFFA726), Icons.pause_circle_outline);
      case SignalType.sell:
        return ('SAT', AppColors.lossDark, Icons.arrow_downward);
    }
  }

  static (Color, IconData) _sentimentStyle(SentimentType type) {
    switch (type) {
      case SentimentType.positive:
        return (AppColors.profitLight, Icons.sentiment_satisfied);
      case SentimentType.neutral:
        return (const Color(0xFF78909C), Icons.sentiment_neutral);
      case SentimentType.negative:
        return (AppColors.lossDark, Icons.sentiment_dissatisfied);
    }
  }
}
