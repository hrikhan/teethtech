import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/helpers/show_toast.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/price_text.dart';
import '../../../auth/presentation/providers/session_bloc.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/quotation.dart';
import '../bloc/quotations_bloc.dart';

class RequestQuotationScreen extends StatefulWidget {
  final Product product;
  final int initialQuantity;

  const RequestQuotationScreen({
    super.key,
    required this.product,
    this.initialQuantity = 50,
  });

  @override
  State<RequestQuotationScreen> createState() => _RequestQuotationScreenState();
}

class _RequestQuotationScreenState extends State<RequestQuotationScreen> {
  final _formKey = GlobalKey<FormState>();
  late int _quantity;
  late final TextEditingController _clinicController;
  late final TextEditingController _doctorController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _noteController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;

    final sessionUser = context.read<SessionBloc>().state.user;

    _clinicController = TextEditingController(
      text: sessionUser?.clinicName ?? 'ABC Dental Care & Implant Center',
    );
    _doctorController = TextEditingController(
      text: sessionUser?.name ?? 'Dr. Sarah Jenkins, BDS',
    );
    _phoneController = TextEditingController(
      text: sessionUser?.phone ?? '+880 1712-345678',
    );
    _addressController = TextEditingController(
      text: 'Clinic Branch #1, House #12, Road #4, Dhanmondi, Dhaka',
    );
    _noteController = TextEditingController(
      text: 'Institutional procurement request for Q3 clinic operations.',
    );
  }

  @override
  void dispose() {
    _clinicController.dispose();
    _doctorController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmitRFQ() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      final rfqNumber =
          'RFQ-TT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      final newQuotation = DentalQuotation(
        id: 'rfq_${DateTime.now().millisecondsSinceEpoch}',
        rfqNumber: rfqNumber,
        clinicName: _clinicController.text.trim(),
        doctorName: _doctorController.text.trim(),
        contactPhone: _phoneController.text.trim(),
        deliveryAddress: _addressController.text.trim(),
        dateRequested: DateTime.now(),
        validUntil: DateTime.now().add(const Duration(days: 14)),
        status: QuotationStatus.underReview,
        adminNotes:
            'TeethTech procurement team has received your clinic RFQ. An institutional quote with customized bulk discount will be sent within 2–4 hours.',
        paymentTerms: 'Subject to procurement review (Net 30 eligible)',
        items: [
          QuotationItem(
            product: widget.product,
            requestedQuantity: _quantity,
            regularUnitPrice: widget.product.salePrice,
            clinicalNote: _noteController.text.trim(),
          ),
        ],
      );

      context.read<QuotationsBloc>().add(SubmitNewQuotation(newQuotation));

      showToast(
        context,
        message: 'Quotation Request #$rfqNumber submitted successfully!',
        status: 'success',
      );

      context.pushReplacement(AppRoutes.quotations);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;

    final estimatedStandardTotal = widget.product.salePrice * _quantity;
    final estimatedWholesaleTotal =
        widget.product.getPriceForQuantity(_quantity, isB2b: true) * _quantity;
    final estimatedSavings = estimatedStandardTotal - estimatedWholesaleTotal;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Request Clinic Quotation (RFQ)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // B2B RFQ Header Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF131D2A)
                      : const Color(0xFFEBF4FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.request_quote_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Institutional Procurement & RFQ',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Direct wholesale pricing negotiation with TeethTech Procurement for registered clinics.',
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Product Info Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 64,
                        height: 64,
                        color: cs.surface,
                        child: CachedNetworkImage(
                          imageUrl: widget.product.image,
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.brandName.toUpperCase(),
                            style: tt.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.product.name,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Standard Price: ${PriceText.formatTaka(widget.product.salePrice)} / ${widget.product.unit}',
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
              ),

              const SizedBox(height: 20),

              // Quantity Selector
              Text(
                'Target Order Quantity',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              DecoratedBox(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Requested Units (${widget.product.unit}):',
                        style: tt.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              if (_quantity > 5) {
                                setState(() => _quantity -= 5);
                              }
                            },
                          ),
                          Text(
                            '$_quantity',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              setState(() => _quantity += 5);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Estimated Savings Callout
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00897B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF00897B).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.savings_outlined,
                        size: 18, color: Color(0xFF00897B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Baseline Bulk Estimate: ${PriceText.formatTaka(estimatedWholesaleTotal)} (Est. savings ~${PriceText.formatTaka(estimatedSavings)})',
                        style: const TextStyle(
                          color: Color(0xFF00897B),
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Clinic & Procurement Details Form
              Text(
                'Clinic & Contact Details',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              AppTextField(
                controller: _clinicController,
                label: 'Dental Clinic / Practice Name',
                prefixIcon: const Icon(Icons.apartment_rounded),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Clinic name is required'
                    : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                controller: _doctorController,
                label: 'Procurement Doctor / Contact Person',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Doctor name is required'
                    : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                controller: _phoneController,
                label: 'Direct Contact Phone Number',
                prefixIcon: const Icon(Icons.phone_outlined),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Contact phone is required'
                    : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                controller: _addressController,
                label: 'Clinic Delivery Address & Branch',
                prefixIcon: const Icon(Icons.location_on_outlined),
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Delivery address is required'
                    : null,
              ),
              const SizedBox(height: 12),

              AppTextField(
                controller: _noteController,
                label: 'Special Clinical Notes / Delivery Timeline',
                prefixIcon: const Icon(Icons.notes_rounded),
                maxLines: 2,
              ),

              const SizedBox(height: 28),

              // Submit Button (Pure White Text)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _handleSubmitRFQ,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox.shrink()
                      : const Icon(Icons.send_rounded,
                          size: 18, color: Colors.white),
                  label: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit RFQ to TeethTech Procurement',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
