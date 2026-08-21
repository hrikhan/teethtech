import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../extensions/context_extension.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/catalog/domain/entities/product.dart';
import '../../features/catalog/presentation/bloc/wishlist_bloc.dart';
import '../helpers/show_toast.dart';
import 'price_text.dart';
import 'rating_view.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isHorizontal;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isFav = context.select<WishlistBloc, bool>(
      (bloc) => bloc.state.isFavorite(product.id),
    );

    if (isHorizontal) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 70,
                    height: 70,
                    color: cs.surface,
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Center(
                        child: Icon(Icons.medical_services_outlined,
                            size: 24, color: cs.primary),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(Icons.medical_services_outlined,
                            size: 24, color: cs.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.brandName.toUpperCase(),
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      RatingView(
                        rating: product.rating,
                        reviewCount: product.reviewCount,
                        starSize: 10,
                      ),
                      const SizedBox(height: 3),
                      PriceText(
                        price: product.salePrice,
                        originalPrice: product.hasDiscount ? product.regularPrice : null,
                        fontSize: 13,
                        showB2bBadge: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Add to cart mini button
                InkWell(
                  onTap: () {
                    context.read<CartBloc>().add(AddProductToCart(product));
                    showToast(
                      context,
                      message: 'Added to Dental Cart',
                      status: 'success',
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image with Badges & Wishlist
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      color: cs.surface,
                      child: CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Center(
                          child: Icon(Icons.medical_services_outlined,
                              size: 28, color: cs.primary),
                        ),
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(Icons.medical_services_outlined,
                              size: 28, color: cs.primary),
                        ),
                      ),
                    ),
                  ),

                  // Discount pill
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: cs.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist button
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        iconSize: 18,
                        constraints: const BoxConstraints(
                            minWidth: 28, minHeight: 28),
                        padding: EdgeInsets.zero,
                        icon: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: cs.surface.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFav ? cs.error : cs.onSurfaceVariant,
                            size: 14,
                          ),
                        ),
                        onPressed: () {
                          context
                              .read<WishlistBloc>()
                              .add(ToggleWishlistProduct(product));
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Product Info Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand & SKU
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  product.brandName.toUpperCase(),
                                  style: tt.labelSmall?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                    letterSpacing: 0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                product.sku,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                                  fontSize: 8.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),

                          // Name
                          Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 3),

                          // Rating
                          RatingView(
                            rating: product.rating,
                            reviewCount: product.reviewCount,
                            starSize: 10.5,
                          ),
                        ],
                      ),

                      // Price & Add to Cart Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: PriceText(
                              price: product.salePrice,
                              originalPrice: product.hasDiscount
                                  ? product.regularPrice
                                  : null,
                              fontSize: 13,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              context
                                  .read<CartBloc>()
                                  .add(AddProductToCart(product));
                              showToast(
                                context,
                                message: 'Added to Cart',
                                status: 'success',
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
