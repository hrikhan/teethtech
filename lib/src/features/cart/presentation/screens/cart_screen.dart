import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/price_text.dart';
import '../../../auth/presentation/providers/session_bloc.dart';
import '../bloc/cart_bloc.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  void _onProceedToCheckout(BuildContext context) {
    final sessionState = context.read<SessionBloc>().state;
    final isAuthenticated = sessionState.status == SessionStatus.authenticated;

    if (!isAuthenticated) {
      _showGuestLoginPrompt(context);
    } else {
      context.push(AppRoutes.checkout);
    }
  }

  void _showGuestLoginPrompt(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Lock / Medical icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: cs.primary,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Sign In to Complete Order',
                style: tt.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Marketing / Trust copy
              Text(
                'To ensure verified dental delivery, live courier shipment tracking, and official VAT tax invoice generation, please sign in or register.',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Trust Badges
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF131D2A)
                      : const Color(0xFFE8F2FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      context: ctx,
                      icon: Icons.local_shipping_outlined,
                      text: 'Express Delivery with Live Tracking',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context: ctx,
                      icon: Icons.receipt_long_outlined,
                      text: 'Official VAT & BMDC-compliant Tax Invoices',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      context: ctx,
                      icon: Icons.verified_user_outlined,
                      text: '100% Genuine Certified Clinical Products',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Sign In CTA
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.login);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Sign In to Continue',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Create Account CTA
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.push(AppRoutes.signup);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: cs.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Create New Dental Account',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon,
    required String text,
  }) {
    final cs = context.theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final session = context.watch<SessionBloc>().state;
    final isB2b = session.status == SessionStatus.authenticated &&
        (session.user?.isB2b ?? false);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Dental Cart'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear Cart',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () {
                  context.read<CartBloc>().add(const ClearAllCartItems());
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return Center(
              child: AppEmptyState(
                title: 'Your Dental Cart is Empty',
                subtitle:
                    'Explore 10,000+ certified dental materials, burs, resins, and instruments for your practice.',
                actionLabel: 'Explore Dental Catalog',
                onAction: () => context.go(AppRoutes.home),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart Items Count & B2B Status Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.itemCount} Items Selected',
                      style:
                          tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Express Shipping Available',
                        style: tt.labelSmall?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Cart Items List
                ...state.items.map((cartItem) {
                  final product = cartItem.product;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 72,
                            height: 72,
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
                        const SizedBox(width: 12),

                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.brandName.toUpperCase(),
                                style: tt.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 9.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'SKU: ${product.sku} • Unit: ${product.unit}',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 10.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              PriceText(
                                price: cartItem.unitPrice,
                                fontSize: 14,
                                showB2bBadge: cartItem.quantity >=
                                    product.bulkMinQuantity,
                              ),
                            ],
                          ),
                        ),

                        // Quantity Control + Delete
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded,
                                  size: 20, color: cs.error),
                              constraints: const BoxConstraints(
                                  minWidth: 28, minHeight: 28),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                context
                                    .read<CartBloc>()
                                    .add(RemoveProductFromCart(product.id));
                              },
                            ),
                            const SizedBox(height: 8),

                            // Quantity Stepper
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      context.read<CartBloc>().add(
                                          DecreaseCartItemQuantity(product.id));
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Icon(Icons.remove, size: 15),
                                    ),
                                  ),
                                  Text(
                                    '${cartItem.quantity}',
                                    style: tt.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      context.read<CartBloc>().add(
                                          IncreaseCartItemQuantity(product.id));
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Icon(Icons.add, size: 15),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Order Summary Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Summary',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Subtotal
                      _buildSummaryRow(
                        context: context,
                        label: 'Subtotal',
                        value: PriceText.formatTaka(state.subtotal),
                      ),
                      const SizedBox(height: 8),

                      // Discount
                      if (state.discountAmount > 0) ...[
                        _buildSummaryRow(
                          context: context,
                          label: 'Clinic Promo Discount (5%)',
                          value:
                              '- ${PriceText.formatTaka(state.discountAmount)}',
                          valueColor: const Color(0xFF00897B),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Shipping
                      _buildSummaryRow(
                        context: context,
                        label: 'Medical Courier Delivery',
                        value: state.shippingFee == 0
                            ? 'FREE'
                            : PriceText.formatTaka(state.shippingFee),
                        valueColor: state.shippingFee == 0
                            ? const Color(0xFF00897B)
                            : null,
                      ),
                      const SizedBox(height: 8),

                      // VAT
                      _buildSummaryRow(
                        context: context,
                        label: 'Medical VAT (7.5%)',
                        value: PriceText.formatTaka(state.vatAmount),
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Grand Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Estimated Total',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            PriceText.formatTaka(state.totalAmount),
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Checkout CTA Button with Auth Guard
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _onProceedToCheckout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Proceed to Checkout',
                          style: tt.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 18, color: Colors.white),
                      ],
                    ),
                  ),
                ),

                if (isB2b) ...[
                  const SizedBox(height: 12),
                  // Request Quotation CTA Button (B2B Clinics Only)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final firstProduct = state.items.isNotEmpty
                            ? state.items.first.product
                            : null;
                        if (firstProduct != null) {
                          context.push(
                            AppRoutes.requestQuotation,
                            extra: firstProduct,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.primary,
                        side: BorderSide(color: cs.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.request_quote_rounded, size: 18),
                      label: const Text(
                        'Request Custom Clinic Quotation (RFQ)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}
