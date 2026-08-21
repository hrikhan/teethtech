import 'package:equatable/equatable.dart';

class PriceTier extends Equatable {
  final int minQuantity;
  final int? maxQuantity; // null means unlimited (e.g. 50+)
  final double unitPrice;
  final String label;
  final int? discountPercent;

  const PriceTier({
    required this.minQuantity,
    this.maxQuantity,
    required this.unitPrice,
    required this.label,
    this.discountPercent,
  });

  String get rangeLabel {
    if (maxQuantity != null) {
      return '$minQuantity–$maxQuantity';
    }
    return '$minQuantity+';
  }

  @override
  List<Object?> get props => [minQuantity, maxQuantity, unitPrice, label, discountPercent];
}

class Product extends Equatable {
  final String id;
  final String name;
  final String sku;
  final String categoryId;
  final String categoryName;
  final String subcategory;
  final String brandId;
  final String brandName;
  final String image;
  final List<String> images;
  final String description;
  final Map<String, String> specifications;
  final double regularPrice;
  final double salePrice;
  final int discountPercent;
  final double rating;
  final int reviewCount;
  final int stock;
  final String unit; // e.g. "Piece", "Kit", "Box of 100", "Bottle (500ml)"
  final bool isFeatured;
  final bool isBestSeller;
  final bool isNewArrival;
  final double b2bPrice; // Discounted clinic tier price
  final int bulkMinQuantity; // MOQ for B2B price
  final List<PriceTier> priceTiers;

  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.categoryId,
    required this.categoryName,
    required this.subcategory,
    required this.brandId,
    required this.brandName,
    required this.image,
    required this.images,
    required this.description,
    required this.specifications,
    required this.regularPrice,
    required this.salePrice,
    required this.discountPercent,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.unit,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.isNewArrival = false,
    required this.b2bPrice,
    this.bulkMinQuantity = 5,
    this.priceTiers = const [],
  });

  bool get hasDiscount => discountPercent > 0 && salePrice < regularPrice;
  bool get inStock => stock > 0;

  List<PriceTier> get computedPriceTiers {
    if (priceTiers.isNotEmpty) return priceTiers;
    return [
      PriceTier(
        minQuantity: 1,
        maxQuantity: bulkMinQuantity > 1 ? bulkMinQuantity - 1 : 9,
        unitPrice: salePrice,
        label: 'Retail Price',
        discountPercent: 0,
      ),
      PriceTier(
        minQuantity: bulkMinQuantity > 1 ? bulkMinQuantity : 10,
        maxQuantity: (bulkMinQuantity * 5).clamp(10, 49),
        unitPrice: ((salePrice + b2bPrice) / 2).roundToDouble(),
        label: 'Clinic Tier',
        discountPercent: 10,
      ),
      PriceTier(
        minQuantity: (bulkMinQuantity * 5).clamp(10, 49) + 1,
        maxQuantity: null,
        unitPrice: b2bPrice,
        label: 'Wholesale Bulk',
        discountPercent: 20,
      ),
    ];
  }

  double getPriceForQuantity(int quantity, {bool isB2b = true}) {
    if (!isB2b) return salePrice;
    final tiers = computedPriceTiers;
    for (final tier in tiers.reversed) {
      if (quantity >= tier.minQuantity) {
        return tier.unitPrice;
      }
    }
    return salePrice;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        categoryId,
        categoryName,
        subcategory,
        brandId,
        brandName,
        image,
        images,
        description,
        specifications,
        regularPrice,
        salePrice,
        discountPercent,
        rating,
        reviewCount,
        stock,
        unit,
        isFeatured,
        isBestSeller,
        isNewArrival,
        b2bPrice,
        bulkMinQuantity,
        priceTiers,
      ];
}
