import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../extensions/context_extension.dart';
import '../../features/catalog/domain/entities/category.dart';

class CategoryCard extends StatelessWidget {
  final DentalCategory category;
  final VoidCallback onTap;
  final bool isSelected;
  final bool compact;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    if (compact) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? cs.primary
                  : cs.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Text(
            category.name,
            style: tt.labelMedium?.copyWith(
              color: isSelected ? cs.onPrimary : cs.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 84,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surfaceContainerLow,
                border: Border.all(
                  color: isSelected
                      ? cs.primary
                      : cs.outlineVariant.withValues(alpha: 0.5),
                  width: isSelected ? 2.2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: category.image,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => ColoredBox(
                    color: cs.primaryContainer.withValues(alpha: 0.3),
                    child: Center(
                      child: Icon(Icons.medical_services_outlined,
                          size: 24, color: cs.primary),
                    ),
                  ),
                  errorWidget: (_, __, ___) => ColoredBox(
                    color: cs.primaryContainer.withValues(alpha: 0.3),
                    child: Center(
                      child: Icon(Icons.medical_services_outlined,
                          size: 24, color: cs.primary),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: tt.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? cs.primary : cs.onSurface,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
