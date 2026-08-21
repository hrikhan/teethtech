import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../extensions/context_extension.dart';
import '../../shared/widgets/rating_view.dart';
import '../catalog/domain/entities/review.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    final mockReviews = [
      DentalReview(
        id: 'rev_1',
        authorName: 'Dr. Tanvir Rahman',
        clinicName: 'Smile Dental Surgery, Gulshan',
        rating: 5,
        comment:
            'The Woodpecker 1-sec LED curing light is genuine and cures composite resins in seconds without excessive thermal pulp irritation. Extremely fast delivery by TeethTech!',
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
      DentalReview(
        id: 'rev_2',
        authorName: 'Dr. Sabrina Chowdhury',
        clinicName: 'Chowdhury Orthodontic Center',
        rating: 4.8,
        comment:
            '3M Ceramic Brackets had great slot accuracy. Bulk ordering discount made this much more cost-effective than physical market dealers.',
        date: DateTime.now().subtract(const Duration(days: 12)),
      ),
      DentalReview(
        id: 'rev_3',
        authorName: 'Dr. Mahmudul Hasan',
        clinicName: 'City Dental Care, Uttara',
        rating: 5,
        comment:
            'Dentsply air turbine handpiece running smoothly at 380,000 RPM with minimal noise. Autoclavable up to 134°C with zero degradation so far.',
        date: DateTime.now().subtract(const Duration(days: 20)),
      ),
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Product Reviews'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockReviews.length,
        itemBuilder: (context, index) {
          final review = mockReviews[index];
          final dateStr = DateFormat('MMMM d, yyyy').format(review.date);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.authorName,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    RatingView(rating: review.rating),
                  ],
                ),
                Text(
                  review.clinicName,
                  style: tt.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  review.comment,
                  style: tt.bodyMedium?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: cs.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Verified Doctor Purchase',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      dateStr,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
