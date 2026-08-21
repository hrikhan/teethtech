import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product.dart';

enum QuotationStatus {
  underReview,
  quoteSent,
  accepted,
  ordered,
  rejected,
  expired,
}

extension QuotationStatusExt on QuotationStatus {
  String get displayName {
    switch (this) {
      case QuotationStatus.underReview:
        return 'Under Review';
      case QuotationStatus.quoteSent:
        return 'Quote Ready';
      case QuotationStatus.accepted:
        return 'Quote Accepted';
      case QuotationStatus.ordered:
        return 'Converted to Order';
      case QuotationStatus.rejected:
        return 'Declined';
      case QuotationStatus.expired:
        return 'Expired';
    }
  }
}

class QuotationItem extends Equatable {
  final Product product;
  final int requestedQuantity;
  final double regularUnitPrice;
  final double? quotedUnitPrice;
  final String? clinicalNote;

  const QuotationItem({
    required this.product,
    required this.requestedQuantity,
    required this.regularUnitPrice,
    this.quotedUnitPrice,
    this.clinicalNote,
  });

  double get regularTotal => regularUnitPrice * requestedQuantity;
  double get quotedTotal => (quotedUnitPrice ?? regularUnitPrice) * requestedQuantity;
  double get savings => regularTotal > quotedTotal ? regularTotal - quotedTotal : 0;

  QuotationItem copyWith({
    Product? product,
    int? requestedQuantity,
    double? regularUnitPrice,
    double? quotedUnitPrice,
    String? clinicalNote,
  }) {
    return QuotationItem(
      product: product ?? this.product,
      requestedQuantity: requestedQuantity ?? this.requestedQuantity,
      regularUnitPrice: regularUnitPrice ?? this.regularUnitPrice,
      quotedUnitPrice: quotedUnitPrice ?? this.quotedUnitPrice,
      clinicalNote: clinicalNote ?? this.clinicalNote,
    );
  }

  @override
  List<Object?> get props => [
        product,
        requestedQuantity,
        regularUnitPrice,
        quotedUnitPrice,
        clinicalNote,
      ];
}

class DentalQuotation extends Equatable {
  final String id;
  final String rfqNumber;
  final String clinicName;
  final String doctorName;
  final String contactPhone;
  final String deliveryAddress;
  final DateTime dateRequested;
  final DateTime? dateQuoted;
  final DateTime validUntil;
  final QuotationStatus status;
  final List<QuotationItem> items;
  final String? adminNotes;
  final String? paymentTerms;
  final String? convertedOrderId;

  const DentalQuotation({
    required this.id,
    required this.rfqNumber,
    required this.clinicName,
    required this.doctorName,
    required this.contactPhone,
    required this.deliveryAddress,
    required this.dateRequested,
    this.dateQuoted,
    required this.validUntil,
    required this.status,
    required this.items,
    this.adminNotes,
    this.paymentTerms,
    this.convertedOrderId,
  });

  int get totalItemsCount => items.fold(0, (sum, item) => sum + item.requestedQuantity);

  double get regularSubtotal =>
      items.fold(0, (sum, item) => sum + item.regularTotal);

  double get quotedSubtotal =>
      items.fold(0, (sum, item) => sum + item.quotedTotal);

  double get totalSavings =>
      regularSubtotal > quotedSubtotal ? regularSubtotal - quotedSubtotal : 0;

  double get vatAmount => quotedSubtotal * 0.075;
  double get finalQuotedTotal => quotedSubtotal + vatAmount;

  DentalQuotation copyWith({
    String? id,
    String? rfqNumber,
    String? clinicName,
    String? doctorName,
    String? contactPhone,
    String? deliveryAddress,
    DateTime? dateRequested,
    DateTime? dateQuoted,
    DateTime? validUntil,
    QuotationStatus? status,
    List<QuotationItem>? items,
    String? adminNotes,
    String? paymentTerms,
    String? convertedOrderId,
  }) {
    return DentalQuotation(
      id: id ?? this.id,
      rfqNumber: rfqNumber ?? this.rfqNumber,
      clinicName: clinicName ?? this.clinicName,
      doctorName: doctorName ?? this.doctorName,
      contactPhone: contactPhone ?? this.contactPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      dateRequested: dateRequested ?? this.dateRequested,
      dateQuoted: dateQuoted ?? this.dateQuoted,
      validUntil: validUntil ?? this.validUntil,
      status: status ?? this.status,
      items: items ?? this.items,
      adminNotes: adminNotes ?? this.adminNotes,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      convertedOrderId: convertedOrderId ?? this.convertedOrderId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        rfqNumber,
        clinicName,
        doctorName,
        contactPhone,
        deliveryAddress,
        dateRequested,
        dateQuoted,
        validUntil,
        status,
        items,
        adminNotes,
        paymentTerms,
        convertedOrderId,
      ];
}
