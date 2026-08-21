import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final bool isB2bBulkSelected;

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.isB2bBulkSelected = false,
  });

  double get unitPrice =>
      product.getPriceForQuantity(quantity, isB2b: true);

  double get totalPrice => unitPrice * quantity;

  double get regularTotalPrice => product.salePrice * quantity;

  double get bulkSavings =>
      regularTotalPrice > totalPrice ? regularTotalPrice - totalPrice : 0;

  bool get hasBulkDiscount => bulkSavings > 0;

  CartItem copyWith({
    Product? product,
    int? quantity,
    bool? isB2bBulkSelected,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isB2bBulkSelected: isB2bBulkSelected ?? this.isB2bBulkSelected,
    );
  }

  @override
  List<Object?> get props => [product, quantity, isB2bBulkSelected];
}
