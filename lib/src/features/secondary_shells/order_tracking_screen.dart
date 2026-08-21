import 'package:flutter/material.dart';
import '../../extensions/context_extension.dart';
import '../orders/domain/entities/order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;
  final DentalOrder? order;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    final steps = [
      {'title': 'Order Placed & Verified', 'desc': 'Clinic order received and reviewed', 'done': true, 'time': '10:30 AM'},
      {'title': 'Clinical Warehouse Packaged', 'desc': 'Materials verified with batch & expiry certificates', 'done': true, 'time': '02:15 PM'},
      {'title': 'Dispatched via Express Courier', 'desc': 'Tracking ID: ${order?.trackingNumber ?? 'BD-DEX-89412'}', 'done': true, 'time': '05:40 PM'},
      {'title': 'Out for Clinic Delivery', 'desc': 'Courier rider assigned with temperature-controlled transit box', 'done': false, 'time': 'Pending'},
      {'title': 'Delivered & Received', 'desc': 'Signed by practice receiving authority', 'done': false, 'time': 'Pending'},
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Track Shipment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tracking Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: cs.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Express Dental Courier',
                          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'AWB: ${order?.trackingNumber ?? 'BD-DEX-89412'}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Estimated Delivery: Today by 6:00 PM',
                          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Shipment Timeline',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Timeline Steps
            ...List.generate(steps.length, (index) {
              final step = steps[index];
              final isDone = step['done'] as bool;
              final isLast = index == steps.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline icon & connecting line
                  Column(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? cs.primary : cs.surfaceContainerHighest,
                        ),
                        child: Center(
                          child: Icon(
                            isDone ? Icons.check : Icons.circle,
                            size: 14,
                            color: isDone ? Colors.white : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 50,
                          color: isDone
                              ? cs.primary
                              : cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),

                  // Step description
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                step['title'] as String,
                                style: tt.titleSmall?.copyWith(
                                  fontWeight:
                                      isDone ? FontWeight.bold : FontWeight.w500,
                                  color: isDone
                                      ? cs.onSurface
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                step['time'] as String,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            step['desc'] as String,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
