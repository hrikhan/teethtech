import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/helpers/show_toast.dart';
import '../../../../shared/widgets/price_text.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/presentation/bloc/orders_bloc.dart';
import '../../domain/entities/quotation.dart';
import '../bloc/quotations_bloc.dart';

class QuotationDetailsScreen extends StatefulWidget {
  final DentalQuotation quotation;

  const QuotationDetailsScreen({
    super.key,
    required this.quotation,
  });

  @override
  State<QuotationDetailsScreen> createState() => _QuotationDetailsScreenState();
}

class _QuotationDetailsScreenState extends State<QuotationDetailsScreen> {
  late DentalQuotation _quotation;

  @override
  void initState() {
    super.initState();
    _quotation = widget.quotation;
  }

  void _handleAcceptAndOrder() {
    context.read<QuotationsBloc>().add(AcceptQuotation(_quotation.id));

    final orderNumber =
        'TT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    // Convert quotation items into CartItem format for the Order
    final orderItems = _quotation.items.map((item) {
      return CartItem(
        product: item.product,
        quantity: item.requestedQuantity,
        isB2bBulkSelected: true,
      );
    }).toList();

    final newOrder = DentalOrder(
      id: 'ord_rfq_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNumber,
      orderDate: DateTime.now(),
      status: OrderStatus.processing,
      items: orderItems,
      totalAmount: _quotation.finalQuotedTotal,
      deliveryAddress: _quotation.deliveryAddress,
      paymentMethod:
          _quotation.paymentTerms ?? 'Clinic Credit Line (Net 30 Days)',
      trackingNumber: 'DEX-$orderNumber',
    );

    // Register into orders
    context.read<OrdersBloc>().add(AddNewOrder(newOrder));

    showToast(
      context,
      message: 'Quotation Accepted! Clinical order created successfully.',
      status: 'success',
    );

    // Navigate to Order Success
    context.go(AppRoutes.orderSuccess, extra: newOrder);
  }

  void _handleDecline() {
    context.read<QuotationsBloc>().add(RejectQuotation(_quotation.id));
    setState(() {
      _quotation = _quotation.copyWith(status: QuotationStatus.rejected);
    });
    showToast(context, message: 'Quotation declined.');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;

    final dateRequestedStr =
        DateFormat('MMMM d, yyyy • hh:mm a').format(_quotation.dateRequested);
    final validUntilStr =
        DateFormat('MMMM d, yyyy').format(_quotation.validUntil);

    final isQuoteReady = _quotation.status == QuotationStatus.quoteSent;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text('RFQ #${_quotation.rfqNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isQuoteReady
                      ? const Color(0xFF00897B).withValues(alpha: 0.5)
                      : cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quotation Status',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isQuoteReady
                              ? const Color(0xFF00897B).withValues(alpha: 0.15)
                              : cs.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _quotation.status.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isQuoteReady
                                ? const Color(0xFF00897B)
                                : cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Submitted: $dateRequestedStr',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (isQuoteReady) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Quote Valid Until: $validUntilStr',
                      style: tt.bodySmall?.copyWith(
                        color: const Color(0xFF00897B),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // TeethTech Admin Quotation Decision & Notes
            if (_quotation.adminNotes != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF131D2A)
                      : const Color(0xFFEBF4FC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified_user_rounded,
                            color: cs.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'TeethTech Procurement Review',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _quotation.adminNotes!,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface,
                        height: 1.4,
                      ),
                    ),
                    if (_quotation.paymentTerms != null) ...[
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.credit_card_rounded,
                              size: 16, color: Color(0xFF00897B)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Payment Terms: ${_quotation.paymentTerms}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00897B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Quoted Products List
            Text(
              'Quoted Products & Quantities',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ..._quotation.items.map((item) {
              final product = item.product;
              final hasSpecialPrice = item.quotedUnitPrice != null;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 56,
                            height: 56,
                            color: cs.surface,
                            child: CachedNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Center(
                                child: Icon(Icons.medical_services_outlined,
                                    size: 20, color: cs.primary),
                              ),
                              errorWidget: (_, __, ___) => Center(
                                child: Icon(Icons.medical_services_outlined,
                                    size: 20, color: cs.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.brandName.toUpperCase(),
                                style: tt.labelSmall?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                product.name,
                                style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Requested: ${item.requestedQuantity} ${product.unit}',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // Price Breakdown (Responsive Row)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Standard: ${PriceText.formatTaka(item.regularUnitPrice)}/unit',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                hasSpecialPrice
                                    ? 'Approved: ${PriceText.formatTaka(item.quotedUnitPrice!)}/unit'
                                    : 'Rate: Under Review',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: hasSpecialPrice
                                      ? const Color(0xFF00897B)
                                      : cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Item Total',
                              style:
                                  TextStyle(fontSize: 10.5, color: Colors.grey),
                            ),
                            Text(
                              PriceText.formatTaka(item.quotedTotal),
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (item.clinicalNote != null &&
                        item.clinicalNote!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Clinic Note: ${item.clinicalNote}',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: cs.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Clinic & Destination Info Card
            Container(
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
                  Text(
                    'Practice & Delivery Destination',
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow('Clinic Name:', _quotation.clinicName),
                  const SizedBox(height: 6),
                  _buildDetailRow('Doctor / Contact:', _quotation.doctorName),
                  const SizedBox(height: 6),
                  _buildDetailRow('Phone:', _quotation.contactPhone),
                  const SizedBox(height: 6),
                  _buildDetailRow('Delivery Address:', _quotation.deliveryAddress),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quotation Total Summary
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
                children: [
                  _buildSummaryRow(
                      'Standard Catalog Value',
                      PriceText.formatTaka(_quotation.regularSubtotal)),
                  const SizedBox(height: 6),
                  if (_quotation.totalSavings > 0) ...[
                    _buildSummaryRow(
                      'Institutional Discount Approved',
                      '- ${PriceText.formatTaka(_quotation.totalSavings)}',
                      color: const Color(0xFF00897B),
                    ),
                    const SizedBox(height: 6),
                  ],
                  _buildSummaryRow(
                    'Special Quoted Subtotal',
                    PriceText.formatTaka(_quotation.quotedSubtotal),
                    isBold: true,
                  ),
                  const SizedBox(height: 6),
                  _buildSummaryRow('Medical VAT (7.5%)',
                      PriceText.formatTaka(_quotation.vatAmount)),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable / Invoiced',
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        PriceText.formatTaka(_quotation.finalQuotedTotal),
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

            // Action Buttons (Pure White Button Text)
            if (isQuoteReady) ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _handleAcceptAndOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_rounded,
                      size: 20, color: Colors.white),
                  label: const Text(
                    'Accept Quotation & Place Clinical Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _handleDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error,
                    side: BorderSide(color: cs.error.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Decline Quotation'),
                ),
              ),
            ] else if (_quotation.status == QuotationStatus.underReview) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFD97706).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_bottom_rounded,
                        color: Color(0xFFD97706)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This RFQ is being reviewed by TeethTech Procurement. You will receive an in-app notification when the official quotation is ready.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 115,
          child: Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
