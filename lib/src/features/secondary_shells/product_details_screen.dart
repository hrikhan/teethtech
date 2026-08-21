import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../extensions/context_extension.dart';
import '../../routing/app_routes.dart';
import '../../shared/helpers/show_toast.dart';
import '../../shared/widgets/price_text.dart';
import '../../shared/widgets/rating_view.dart';
import '../auth/presentation/providers/session_bloc.dart';
import '../cart/presentation/bloc/cart_bloc.dart';
import '../catalog/data/datasources/catalog_mock_datasource.dart';
import '../catalog/domain/entities/product.dart';
import '../catalog/presentation/bloc/wishlist_bloc.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  final Product? initialProduct;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late Product _product;
  int _selectedImageIndex = 0;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _product = widget.initialProduct!;
    } else {
      _product = CatalogMockDataSource.instance.products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => CatalogMockDataSource.instance.products.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final session = context.watch<SessionBloc>().state;
    final isAuthenticated = session.status == SessionStatus.authenticated;
    final isB2b = isAuthenticated && (session.user?.isB2b ?? false);

    final isFav = context.select<WishlistBloc, bool>(
      (bloc) => bloc.state.isFavorite(_product.id),
    );

    final effectiveUnitPrice =
        _product.getPriceForQuantity(_quantity, isB2b: isB2b);
    final totalPrice = effectiveUnitPrice * _quantity;
    final regularTotal = _product.salePrice * _quantity;
    final bulkSavings =
        regularTotal > totalPrice ? regularTotal - totalPrice : 0.0;

    final tiers = _product.computedPriceTiers;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(_product.brandName),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? cs.error : cs.onSurface,
            ),
            onPressed: () {
              context.read<WishlistBloc>().add(ToggleWishlistProduct(_product));
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              showToast(context, message: 'Product link copied to clipboard');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Product Image Gallery
            Container(
              height: 280,
              width: double.infinity,
              color: cs.surfaceContainerLow,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CachedNetworkImage(
                      imageUrl: _product.images.isNotEmpty
                          ? _product.images[_selectedImageIndex.clamp(
                              0, _product.images.length - 1)]
                          : _product.image,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Center(
                        child: Icon(Icons.medical_services_outlined,
                            size: 64, color: cs.primary),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(Icons.medical_services_outlined,
                            size: 64, color: cs.primary),
                      ),
                    ),
                  ),
                  if (_product.hasDiscount)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: cs.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '-${_product.discountPercent}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Thumbnail Switcher
            if (_product.images.length > 1)
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_product.images.length, (idx) {
                    final isSel = idx == _selectedImageIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedImageIndex = idx),
                      child: Container(
                        width: 48,
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? cs.primary : cs.outlineVariant,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: CachedNetworkImage(
                            imageUrl: _product.images[idx],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

            // Details Container
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand & Stock status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _product.brandName.toUpperCase(),
                          style: tt.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'In Stock (${_product.stock} available)',
                            style: tt.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Product Title
                  Text(
                    _product.name,
                    style: tt.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // SKU & Rating
                  Row(
                    children: [
                      Text(
                        'SKU: ${_product.sku}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('•'),
                      const SizedBox(width: 12),
                      RatingView(
                        rating: _product.rating,
                        reviewCount: _product.reviewCount,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Retail Price Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Retail Single Unit Price',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            PriceText(
                              price: _product.salePrice,
                              originalPrice: _product.hasDiscount
                                  ? _product.regularPrice
                                  : null,
                              fontSize: 20,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Packaging Unit',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _product.unit,
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🏥 CLINIC WHOLESALE TIERED PRICING & RFQ TABLE (B2B ONLY)
                  if (isB2b) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF131D2A)
                            : const Color(0xFFF1F7FC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_hospital_rounded,
                                  color: cs.primary, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Clinic Wholesale Pricing',
                                  style: tt.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: cs.primary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'VERIFIED B2B',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Volume discount automatically calculated by order quantity:',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 11.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 3-Column Tier Table
                          Row(
                            children: tiers.map((tier) {
                              final isActive = (tier.maxQuantity != null)
                                  ? (_quantity >= tier.minQuantity &&
                                      _quantity <= tier.maxQuantity!)
                                  : (_quantity >= tier.minQuantity);

                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 3),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 6),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? cs.primary.withValues(alpha: 0.15)
                                        : (isDark
                                            ? cs.surface
                                            : Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isActive
                                          ? cs.primary
                                          : cs.outlineVariant
                                              .withValues(alpha: 0.5),
                                      width: isActive ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        tier.rangeLabel,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isActive
                                              ? cs.primary
                                              : cs.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        PriceText.formatTaka(tier.unitPrice),
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: isActive
                                              ? cs.primary
                                              : cs.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        tier.discountPercent != null &&
                                                tier.discountPercent! > 0
                                            ? '${tier.discountPercent}% Off'
                                            : 'Standard',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: tier.discountPercent != null &&
                                                  tier.discountPercent! > 0
                                              ? const Color(0xFF00897B)
                                              : cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),

                          // Quick Quantity Selector Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  'Quick Select: ',
                                  style: tt.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                _buildQuickQtyChip(1, '1 Box'),
                                _buildQuickQtyChip(10, '10 Boxes (Tier 2)'),
                                _buildQuickQtyChip(
                                    50, '50 Boxes (20% Bulk 🔥)'),
                                _buildQuickQtyChip(100, '100 Boxes'),
                              ],
                            ),
                          ),

                          // Bulk Savings Callout
                          if (bulkSavings > 0) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00897B)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 15, color: Color(0xFF00897B)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Bulk Price Applied: ${PriceText.formatTaka(effectiveUnitPrice)}/box • You save ${PriceText.formatTaka(bulkSavings)}!',
                                      style: const TextStyle(
                                        color: Color(0xFF00897B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context.push(
                                  AppRoutes.requestQuotation,
                                  extra: _product,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: cs.primary,
                                side: BorderSide(color: cs.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.request_quote_rounded,
                                  size: 16),
                              label: const Text(
                                'Request Custom Clinic Quotation (RFQ)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Product Description
                  Text(
                    'Product Overview',
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product.description,
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Specifications Table
                  Text(
                    'Technical Specifications',
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      children: _product.specifications.entries.map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: cs.outlineVariant
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  e.key,
                                  style: tt.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  e.value,
                                  style: tt.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),

      // Sticky Purchase Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Stepper
              DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                    ),
                    Text(
                      '$_quantity',
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Add to Cart Button (Displays calculated total)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<CartBloc>().add(
                            AddProductToCart(_product, quantity: _quantity),
                          );
                      showToast(
                        context,
                        message:
                            'Added $_quantity item(s) to Cart (${PriceText.formatTaka(totalPrice)})',
                        status: 'success',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add_shopping_cart_rounded,
                        size: 18, color: Colors.white),
                    label: Text(
                      'Add to Cart (${PriceText.formatTaka(totalPrice)})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickQtyChip(int qty, String label) {
    final cs = context.theme.colorScheme;
    final isSelected = _quantity == qty;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _quantity = qty),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary : cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
