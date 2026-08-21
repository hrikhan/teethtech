import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class DentalOrder extends Equatable {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final OrderStatus status;
  final List<CartItem> items;
  final double totalAmount;
  final String deliveryAddress;
  final String paymentMethod;
  final String trackingNumber;

  const DentalOrder({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.trackingNumber = 'BD-DEX-89412',
  });

  int get totalItemsCount => items.fold(0, (sum, i) => sum + i.quantity);

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        orderDate,
        status,
        items,
        totalAmount,
        deliveryAddress,
        paymentMethod,
        trackingNumber,
      ];
}
