import 'package:flutter/material.dart';
import '../../extensions/context_extension.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    final faqs = [
      {
        'q': 'How do I unlock B2B clinic wholesale pricing?',
        'a': 'Register with your Dental Clinic name or Doctor BDS/DDS license number. Bulk prices will automatically apply on orders matching the minimum order quantity (MOQ).'
      },
      {
        'q': 'What are the delivery timelines for dental supplies?',
        'a': 'Dhaka City: Same day or within 24 hours. Outside Dhaka: 48 to 72 hours via insured medical courier with temperature-controlled packaging for sensitive materials.'
      },
      {
        'q': 'Are all equipment and materials certified genuine?',
        'a': 'Yes. All products are sourced directly from authorized brand distributors (3M ESPE, Dentsply Sirona, Woodpecker, Kerr, GC, Hu-Friedy) with batch certificates.'
      },
      {
        'q': 'What payment methods are supported for practices?',
        'a': 'We accept Cash on Delivery (COD), bKash Merchant Pay, Nagad, Visa/Mastercard/Amex, and monthly clinic invoicing for verified B2B partners.'
      },
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Help Center & FAQs'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Emergency clinical support card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.support_agent_rounded, size: 36, color: cs.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dental Practice Support Hotline',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+880 9612-TEETH (83384) • support@teethtech.io',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onPrimaryContainer.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Frequently Asked Questions',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...faqs.map((faq) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: ExpansionTile(
                title: Text(
                  faq['q']!,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      faq['a']!,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
