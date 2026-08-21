import '../../../catalog/data/datasources/catalog_mock_datasource.dart';
import '../../domain/entities/quotation.dart';

class QuotationsMockDataSource {
  static final QuotationsMockDataSource instance = QuotationsMockDataSource._();
  QuotationsMockDataSource._();

  List<DentalQuotation> getInitialQuotations() {
    final products = CatalogMockDataSource.instance.products;

    final gloves = products.firstWhere(
      (p) => p.id == 'prod_gloves_500',
      orElse: () => products.first,
    );
    final curingLight = products.firstWhere(
      (p) => p.id == 'prod_001',
      orElse: () => products[1],
    );
    final brackets = products.length > 2 ? products[2] : products.first;

    return [
      // 1. Ready Quotation from TeethTech Admin
      DentalQuotation(
        id: 'rfq_001',
        rfqNumber: 'RFQ-TT-8921',
        clinicName: 'ABC Dental Care & Implant Center',
        doctorName: 'Dr. Sarah Jenkins, BDS',
        contactPhone: '+880 1712-345678',
        deliveryAddress: 'Clinic Branch #1, House #12, Road #4, Dhanmondi, Dhaka',
        dateRequested: DateTime.now().subtract(const Duration(days: 1)),
        dateQuoted: DateTime.now().subtract(const Duration(hours: 3)),
        validUntil: DateTime.now().add(const Duration(days: 7)),
        status: QuotationStatus.quoteSent,
        adminNotes:
            'Approved by Procurement Manager. Includes 24% institutional bulk rebate, complimentary calibration certificate, and 2-year on-site equipment warranty.',
        paymentTerms: 'Clinic Net 30 Days Credit Term (Approved)',
        items: [
          QuotationItem(
            product: gloves,
            requestedQuantity: 50,
            regularUnitPrice: 500,
            quotedUnitPrice: 380, // Special negotiated rate
            clinicalNote: 'Sterile surgical batches required for Q3 operations',
          ),
          QuotationItem(
            product: curingLight,
            requestedQuantity: 2,
            regularUnitPrice: 4500,
            quotedUnitPrice: 3900,
            clinicalNote: 'Turbo 1-Sec mode for main operatory and chair #2',
          ),
        ],
      ),

      // 2. Pending Review
      DentalQuotation(
        id: 'rfq_002',
        rfqNumber: 'RFQ-TT-9104',
        clinicName: 'ABC Dental Care & Implant Center',
        doctorName: 'Dr. Sarah Jenkins, BDS',
        contactPhone: '+880 1712-345678',
        deliveryAddress: 'House #12, Road #4, Dhanmondi, Dhaka',
        dateRequested: DateTime.now().subtract(const Duration(hours: 4)),
        validUntil: DateTime.now().add(const Duration(days: 14)),
        status: QuotationStatus.underReview,
        adminNotes:
            'Our institutional procurement team is currently coordinating with European manufacturers for direct import pricing.',
        paymentTerms: 'To be determined upon quote approval',
        items: [
          QuotationItem(
            product: brackets,
            requestedQuantity: 15,
            regularUnitPrice: brackets.salePrice,
            quotedUnitPrice: null,
            clinicalNote: 'Roth 0.022 slot with 3,4,5 hooks',
          ),
        ],
      ),
    ];
  }
}
