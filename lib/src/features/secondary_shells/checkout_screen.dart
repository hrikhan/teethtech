import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../extensions/context_extension.dart';
import '../../routing/app_routes.dart';
import '../../shared/widgets/price_text.dart';
import '../auth/presentation/providers/session_bloc.dart';
import '../cart/presentation/bloc/cart_bloc.dart';
import '../catalog/data/datasources/catalog_mock_datasource.dart';
import '../catalog/domain/entities/review.dart';
import '../orders/domain/entities/order.dart';
import '../orders/presentation/bloc/orders_bloc.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late DeliveryAddress _selectedAddress;
  String _paymentMethod = 'Cash on Delivery (COD)';
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _selectedAddress = CatalogMockDataSource.instance.addresses.first;
  }

  void _handlePlaceOrder(CartState cartState, {required String clinicName}) {
    if (cartState.items.isEmpty) return;

    setState(() => _isPlacingOrder = true);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _isPlacingOrder = false);

      final orderNumber =
          'TT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final newOrder = DentalOrder(
        id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
        orderNumber: orderNumber,
        orderDate: DateTime.now(),
        status: OrderStatus.processing,
        items: List.from(cartState.items),
        totalAmount: cartState.totalAmount,
        deliveryAddress:
            '${_selectedAddress.label}: ${_selectedAddress.fullAddress}',
        paymentMethod: _paymentMethod,
        trackingNumber: 'DEX-$orderNumber',
      );

      // Add to OrdersBloc history
      context.read<OrdersBloc>().add(AddNewOrder(newOrder));

      // Clear the Cart
      context.read<CartBloc>().add(const ClearAllCartItems());

      // Navigate to dedicated Order & Payment Success Screen
      context.go(AppRoutes.orderSuccess, extra: newOrder);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final cartState = context.watch<CartBloc>().state;
    final session = context.watch<SessionBloc>().state;
    final isB2b = session.status == SessionStatus.authenticated &&
        (session.user?.isB2b ?? false);
    final clinicName = session.user?.clinicName ??
        session.user?.name ??
        'ABC Dental Clinic';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Checkout & Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trust Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF131D2A)
                    : const Color(0xFFE8F2FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined, color: cs.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '100% Genuine Supplies • Express Clinical Dispatch',
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Delivery Address Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Address',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.push(AppRoutes.addresses),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...CatalogMockDataSource.instance.addresses.map((addr) {
              final isSel = addr.id == _selectedAddress.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSel
                      ? cs.primaryContainer.withValues(alpha: 0.25)
                      : cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSel
                        ? cs.primary
                        : cs.outlineVariant.withValues(alpha: 0.6),
                    width: isSel ? 1.8 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => setState(() => _selectedAddress = addr),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isSel
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSel ? cs.primary : cs.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    addr.label,
                                    style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (addr.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cs.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Default',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${addr.recipientName} • ${addr.phone}',
                                style: tt.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                addr.fullAddress,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Payment Methods
            Text(
              'Payment / Credit Option',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // B2B Clinic Credit Option
            _buildPaymentTile(
              label: 'Clinic Credit Line (Net 30 Days)',
              subtitle:
                  'Invoice billed to $clinicName account with 30-day payment term',
              icon: Icons.domain_rounded,
              badge: 'B2B ONLY',
            ),
            _buildPaymentTile(
              label: 'Corporate Bank Transfer / BEFTN',
              subtitle:
                  'Direct transfer to TeethTech Bangladesh corporate account',
              icon: Icons.account_balance_rounded,
            ),
            _buildPaymentTile(
              label: 'bKash / Nagad Merchant Pay',
              subtitle: 'Instant secure mobile payment with automated tax receipt',
              icon: Icons.account_balance_wallet_outlined,
            ),
            _buildPaymentTile(
              label: 'Credit / Debit Card',
              subtitle:
                  'Visa, Mastercard & AMEX with 256-bit bank-grade encryption',
              icon: Icons.credit_card_rounded,
            ),
            _buildPaymentTile(
              label: 'Cash on Delivery (COD)',
              subtitle:
                  'Pay cash upon physical parcel inspection at clinic reception',
              icon: Icons.payments_outlined,
            ),

            const SizedBox(height: 20),

            // Business VAT & Tax Invoice Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF131D2A)
                    : const Color(0xFFF1F7FC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long_rounded,
                          color: cs.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Official Business & VAT Tax Invoice',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isB2b
                        ? 'Billed To: $clinicName (Verified B2B Practice)\nBIN: BIN-8809124-CLINIC • NBR Registered\nOfficial 15% VAT Tax Invoice generated with QR verification upon dispatch.'
                        : 'Billed To: $clinicName\nItemized medical receipt with warranty certificates generated upon dispatch.',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Order Total Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Total Breakdown',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildRow('Subtotal (${cartState.itemCount} items)',
                      PriceText.formatTaka(cartState.subtotal)),
                  const SizedBox(height: 6),
                  if (cartState.discountAmount > 0) ...[
                    _buildRow(
                      'Promotional Discount',
                      '- ${PriceText.formatTaka(cartState.discountAmount)}',
                      color: const Color(0xFF00897B),
                    ),
                    const SizedBox(height: 6),
                  ],
                  _buildRow(
                    'Express Clinical Shipping',
                    cartState.shippingFee == 0
                        ? 'FREE'
                        : PriceText.formatTaka(cartState.shippingFee),
                    color: cartState.shippingFee == 0
                        ? const Color(0xFF00897B)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  _buildRow(
                      'Medical VAT / Tax (7.5%)',
                      PriceText.formatTaka(cartState.vatAmount)),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PriceText(
                        price: cartState.totalAmount,
                        fontSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Place Order Button (Pure White Text)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (cartState.isEmpty || _isPlacingOrder)
                    ? null
                    : () => _handlePlaceOrder(cartState, clinicName: clinicName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Confirm & Place Order (${PriceText.formatTaka(cartState.totalAmount)})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTile({
    required String label,
    required String subtitle,
    required IconData icon,
    String? badge,
  }) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isSel = _paymentMethod == label;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSel
            ? cs.primaryContainer.withValues(alpha: 0.25)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSel ? cs.primary : cs.outlineVariant.withValues(alpha: 0.6),
          width: isSel ? 1.8 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => setState(() => _paymentMethod = label),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSel ? cs.primary : cs.onSurfaceVariant,
                size: 20,
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            label,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? color}) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: tt.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }
}
