import 'package:flutter/material.dart';
import '../../extensions/context_extension.dart';

class RatingView extends StatelessWidget {
  final double rating;
  final int? reviewCount;
  final double starSize;
  final bool showNumber;

  const RatingView({
    super.key,
    required this.rating,
    this.reviewCount,
    this.starSize = 14,
    this.showNumber = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: starSize,
          color: const Color(0xFFF59E0B), // Amber star
        ),
        const SizedBox(width: 3),
        if (showNumber)
          Text(
            rating.toStringAsFixed(1),
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        if (reviewCount != null) ...[
          const SizedBox(width: 3),
          Text(
            '($reviewCount)',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 10.5,
            ),
          ),
        ],
      ],
    );
  }
}
