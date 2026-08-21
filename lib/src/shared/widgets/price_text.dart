import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../extensions/context_extension.dart';

class PriceText extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final bool showB2bBadge;
  final bool isB2bPrice;

  const PriceText({
    super.key,
    required this.price,
    this.originalPrice,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w800,
    this.color,
    this.showB2bBadge = false,
    this.isB2bPrice = false,
  });

  static String formatTaka(double amount) {
    final formatter = NumberFormat('#,##,###');
    return '৳ ${formatter.format(amount.round())}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final primaryColor = color ?? cs.primary;

    final hasDiscount = originalPrice != null && originalPrice! > price;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      runSpacing: 2,
      children: [
        Text(
          formatTaka(price),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: primaryColor,
            letterSpacing: -0.3,
          ),
        ),
        if (hasDiscount)
          Text(
            formatTaka(originalPrice!),
            style: TextStyle(
              fontSize: fontSize * 0.78,
              fontWeight: FontWeight.w400,
              decoration: TextDecoration.lineThrough,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        if (showB2bBadge || isB2bPrice)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'B2B Tier',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD97706),
              ),
            ),
          ),
      ],
    );
  }
}
