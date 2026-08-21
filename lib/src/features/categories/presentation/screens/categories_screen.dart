import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/widgets/product_card.dart';
import '../bloc/categories_bloc.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Dental Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(AppRoutes.search),
          ),
        ],
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          return Row(
            children: [
              // Left Category Rail
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  border: Border(
                    right: BorderSide(
                      color: cs.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                child: ListView.builder(
                  itemCount: state.categories.length,
                  itemBuilder: (context, index) {
                    final cat = state.categories[index];
                    final isSelected = cat.id == state.selectedCategory.id;

                    return InkWell(
                      onTap: () => context
                          .read<CategoriesBloc>()
                          .add(SelectCategoryEvent(cat)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? cs.surface : Colors.transparent,
                          border: isSelected
                              ? Border(
                                  left: BorderSide(
                                    color: cs.primary,
                                    width: 3.5,
                                  ),
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? cs.primaryContainer
                                    : cs.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: cat.image,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.medical_services_outlined,
                                    size: 18,
                                    color: isSelected
                                        ? cs.primary
                                        : cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: tt.labelSmall?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected ? cs.primary : cs.onSurface,
                                fontSize: 10.5,
                                height: 1.15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Right Subcategories & Products Content
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Category Header Banner Card (Tappable with no overflow)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: InkWell(
                          onTap: () => context.push(
                            '${AppRoutes.productListing}?category=${state.selectedCategory.id}&title=${Uri.encodeComponent(state.selectedCategory.name)}',
                          ),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Thumbnail Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 38,
                                    height: 38,
                                    color: cs.surface,
                                    child: CachedNetworkImage(
                                      imageUrl: state.selectedCategory.image,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Icon(
                                        Icons.medical_services_outlined,
                                        size: 20,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Title & Product Count
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        state.selectedCategory.name,
                                        style: tt.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${state.selectedCategory.productCount} Products available',
                                        style: tt.bodySmall?.copyWith(
                                          color: cs.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 10.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Arrow
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: cs.surface.withValues(alpha: 0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 11,
                                    color: cs.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Subcategory Filter Chips
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subcategories',
                              style: tt.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: state.selectedCategory.subcategories
                                    .map((subcat) {
                                  final isSubSelected =
                                      state.selectedSubcategory == subcat;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: FilterChip(
                                      label: Text(
                                        subcat,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: isSubSelected
                                              ? Colors.white
                                              : cs.onSurface,
                                          fontWeight: isSubSelected
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                      selected: isSubSelected,
                                      onSelected: (_) => context
                                          .read<CategoriesBloc>()
                                          .add(FilterProductsBySubcategory(
                                              subcat)),
                                      selectedColor: cs.primary,
                                      checkmarkColor: Colors.white,
                                      showCheckmark: false,
                                      backgroundColor: cs.surfaceContainerLow,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: isSubSelected
                                              ? cs.primary
                                              : cs.outlineVariant
                                                  .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),

                    // Products in Category (1 Card Per Row)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      sliver: state.categoryProducts.isEmpty
                          ? SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Center(
                                  child: Text(
                                    'No products found in this subcategory.',
                                    style: tt.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final product = state.categoryProducts[index];
                                  return ProductCard(
                                    product: product,
                                    isHorizontal: true,
                                    onTap: () => context.push(
                                      '/product/${product.id}',
                                      extra: product,
                                    ),
                                  );
                                },
                                childCount: state.categoryProducts.length,
                              ),
                            ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
