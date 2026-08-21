import 'package:flutter/material.dart';
import '../../extensions/context_extension.dart';
import '../../features/orders/domain/entities/order.dart';

class StatusChip extends StatelessWidget {
  final OrderStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final tt = context.theme.textTheme;

    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case OrderStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFF92400E);
        label = 'Pending';
        icon = Icons.schedule_rounded;
        break;
      case OrderStatus.confirmed:
        bg = const Color(0xFFE1F0FB);
        fg = const Color(0xFF083C66);
        label = 'Confirmed';
        icon = Icons.check_circle_outline_rounded;
        break;
      case OrderStatus.processing:
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF5B21B6);
        label = 'Processing';
        icon = Icons.sync_rounded;
        break;
      case OrderStatus.shipped:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF075985);
        label = 'Shipped';
        icon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.delivered:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF166534);
        label = 'Delivered';
        icon = Icons.task_alt_rounded;
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFF991B1B);
        label = 'Cancelled';
        icon = Icons.cancel_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
