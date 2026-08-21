import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/price_text.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../../auth/presentation/providers/session_bloc.dart';
import '../../domain/entities/order.dart';
import '../bloc/orders_bloc.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final session = context.watch<SessionBloc>().state;
    final isAuthenticated = session.status == SessionStatus.authenticated;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: !isAuthenticated
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 38,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sign In to View Orders',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Track live clinical courier shipments, download official VAT tax invoices, and view past dental orders.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => context.push(AppRoutes.login),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sign In to Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => context.push(AppRoutes.signup),
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
              ),
            )
          : BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                final orders = state.filteredOrders;

                return Column(
                  children: [
                    // Filter status chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context: context,
                            label: 'All Orders',
                            isSelected: state.selectedFilter == null,
                            onTap: () => context
                                .read<OrdersBloc>()
                                .add(const FilterOrdersByStatus(null)),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Processing',
                            isSelected:
                                state.selectedFilter == OrderStatus.processing,
                            onTap: () => context.read<OrdersBloc>().add(
                                  const FilterOrdersByStatus(
                                      OrderStatus.processing),
                                ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Shipped',
                            isSelected:
                                state.selectedFilter == OrderStatus.shipped,
                            onTap: () => context.read<OrdersBloc>().add(
                                  const FilterOrdersByStatus(
                                      OrderStatus.shipped),
                                ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Delivered',
                            isSelected:
                                state.selectedFilter == OrderStatus.delivered,
                            onTap: () => context.read<OrdersBloc>().add(
                                  const FilterOrdersByStatus(
                                      OrderStatus.delivered),
                                ),
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            context: context,
                            label: 'Cancelled',
                            isSelected:
                                state.selectedFilter == OrderStatus.cancelled,
                            onTap: () => context.read<OrdersBloc>().add(
                                  const FilterOrdersByStatus(
                                      OrderStatus.cancelled),
                                ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Orders List
                    Expanded(
                      child: orders.isEmpty
                          ? Center(
                              child: AppEmptyState(
                                title: 'No Orders Found',
                                subtitle: state.selectedFilter != null
                                    ? 'There are currently no orders in "${state.selectedFilter!.name.toUpperCase()}" status.'
                                    : 'You have not placed any clinic supply orders yet.',
                                actionLabel: 'Explore Dental Catalog',
                                onAction: () => context.go(AppRoutes.home),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                return _buildOrderCard(
                                    context, order, isDark);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: tt.labelMedium?.copyWith(
            color: isSelected ? Colors.white : cs.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, DentalOrder order, bool isDark) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final formattedDate = DateFormat('MMM d, yyyy').format(order.orderDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: InkWell(
        onTap: () => context.push(
          '/order/${order.id}',
          extra: order,
        ),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order Number & Status Chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.orderNumber}',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Placed on $formattedDate',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  StatusChip(status: order.status),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Items Summary
              Text(
                '${order.items.length} ${order.items.length == 1 ? 'Item' : 'Items'}: ${order.items.map((i) => '${i.quantity}x ${i.product.name}').join(', ')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              // Total & Action Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Payable',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      PriceText(
                        price: order.totalAmount,
                        fontSize: 15,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (order.status == OrderStatus.processing ||
                          order.status == OrderStatus.shipped)
                        OutlinedButton(
                          onPressed: () => context.push(
                            '/order-tracking/${order.id}',
                            extra: order,
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            side: BorderSide(color: cs.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Track',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
