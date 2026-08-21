import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/price_text.dart';
import '../../../auth/presentation/providers/session_bloc.dart';
import '../../../catalog/data/datasources/catalog_mock_datasource.dart';
import '../../domain/entities/quotation.dart';
import '../bloc/quotations_bloc.dart';
import 'quotation_details_screen.dart';

class QuotationsScreen extends StatelessWidget {
  const QuotationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final session = context.watch<SessionBloc>().state;
    final isAuthenticated = session.status == SessionStatus.authenticated;
    final isB2b = isAuthenticated && (session.user?.isB2b ?? false);

    if (!isAuthenticated) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(title: const Text('Clinic Quotations & RFQ')),
        body: Center(
          child: AppEmptyState(
            title: 'Sign In to View Quotations',
            subtitle:
                'Custom Quotations (RFQ) and institutional price negotiations are available for registered dental practices and clinics.',
            actionLabel: 'Sign In to Clinic Account',
            onAction: () => context.push(AppRoutes.login),
          ),
        ),
      );
    }

    if (!isB2b) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(title: const Text('Clinic Quotations & RFQ')),
        body: Center(
          child: AppEmptyState(
            title: 'B2B Clinic Feature Only',
            subtitle:
                'Custom Quotations (RFQ) and Net 30 Credit terms are exclusively reserved for verified dental practices, hospitals, and clinics. Submit your clinic license to upgrade.',
            actionLabel: 'Upgrade to B2B Dental Clinic',
            onAction: () => context.push(AppRoutes.signup),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Clinic Quotations & RFQ'),
      ),
      body: BlocBuilder<QuotationsBloc, QuotationsState>(
        builder: (context, state) {
          final quotations = state.filteredQuotations;

          return Column(
            children: [
              // Filter Status Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip(
                      context: context,
                      label: 'All RFQs (${state.allQuotations.length})',
                      isSelected: state.selectedFilter == null,
                      onTap: () => context
                          .read<QuotationsBloc>()
                          .add(const FilterQuotationsByStatus(null)),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context: context,
                      label: 'Quote Ready 🔥',
                      isSelected: state.selectedFilter == QuotationStatus.quoteSent,
                      badgeCount: state.actionRequiredCount,
                      onTap: () => context.read<QuotationsBloc>().add(
                            const FilterQuotationsByStatus(
                                QuotationStatus.quoteSent),
                          ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context: context,
                      label: 'Under Review ⏳',
                      isSelected:
                          state.selectedFilter == QuotationStatus.underReview,
                      onTap: () => context.read<QuotationsBloc>().add(
                            const FilterQuotationsByStatus(
                                QuotationStatus.underReview),
                          ),
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context: context,
                      label: 'Accepted / Ordered ✅',
                      isSelected: state.selectedFilter == QuotationStatus.accepted,
                      onTap: () => context.read<QuotationsBloc>().add(
                            const FilterQuotationsByStatus(
                                QuotationStatus.accepted),
                          ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Quotations List
              Expanded(
                child: quotations.isEmpty
                    ? Center(
                        child: AppEmptyState(
                          title: 'No Quotations Found',
                          subtitle: state.selectedFilter != null
                              ? 'There are currently no RFQs in "${state.selectedFilter!.displayName}" status.'
                              : 'Your practice has not submitted any custom wholesale procurement requests yet.',
                          actionLabel: 'Explore Dental Catalog',
                          onAction: () => context.pop(),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: quotations.length,
                        itemBuilder: (context, index) {
                          final quote = quotations[index];
                          return _buildQuotationCard(
                            context: context,
                            quotation: quote,
                            isDark: isDark,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final defaultProduct = CatalogMockDataSource.instance.products.first;
          context.push(AppRoutes.requestQuotation, extra: defaultProduct);
        },
        backgroundColor: cs.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'New RFQ Request',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
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
        child: Row(
          children: [
            Text(
              label,
              style: tt.labelMedium?.copyWith(
                color: isSelected ? Colors.white : cs.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            if (badgeCount != null && badgeCount > 0 && !isSelected) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuotationCard({
    required BuildContext context,
    required DentalQuotation quotation,
    required bool isDark,
  }) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final formattedDate =
        DateFormat('MMM d, yyyy').format(quotation.dateRequested);

    Color statusColor;
    IconData statusIcon;
    switch (quotation.status) {
      case QuotationStatus.quoteSent:
        statusColor = const Color(0xFF00897B);
        statusIcon = Icons.local_offer_rounded;
        break;
      case QuotationStatus.underReview:
        statusColor = const Color(0xFFD97706);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      case QuotationStatus.accepted:
      case QuotationStatus.ordered:
        statusColor = cs.primary;
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = cs.onSurfaceVariant;
        statusIcon = Icons.info_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: quotation.status == QuotationStatus.quoteSent
              ? const Color(0xFF00897B).withValues(alpha: 0.5)
              : cs.outlineVariant.withValues(alpha: 0.6),
          width: quotation.status == QuotationStatus.quoteSent ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => QuotationDetailsScreen(quotation: quotation),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: RFQ Number & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${quotation.rfqNumber}',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Submitted $formattedDate',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          quotation.status.displayName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Clinic Name & Items
              Text(
                quotation.clinicName,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${quotation.items.length} Product(s): ${quotation.items.map((i) => '${i.requestedQuantity}x ${i.product.name}').join(', ')}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 12),

              // Pricing Summary or Status Callout
              if (quotation.status == QuotationStatus.quoteSent) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF00897B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Special Quoted Total:',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          PriceText(
                            price: quotation.quotedSubtotal,
                            fontSize: 16,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Save ${PriceText.formatTaka(quotation.totalSavings)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // View Details Arrow
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    quotation.status == QuotationStatus.quoteSent
                        ? '⚡ Action Required: Review & Accept'
                        : (quotation.status == QuotationStatus.underReview
                            ? '⏳ Turnaround: Estimated within 2–4 hours'
                            : 'Order Converted & Invoiced'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'View RFQ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 11, color: cs.primary),
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
