import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../catalog/data/datasources/catalog_mock_datasource.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';

// EVENTS
abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class AddProductToCart extends CartEvent {
  final Product product;
  final int quantity;
  const AddProductToCart(this.product, {this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

class RemoveProductFromCart extends CartEvent {
  final String productId;
  const RemoveProductFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class IncreaseCartItemQuantity extends CartEvent {
  final String productId;
  const IncreaseCartItemQuantity(this.productId);

  @override
  List<Object?> get props => [productId];
}

class DecreaseCartItemQuantity extends CartEvent {
  final String productId;
  const DecreaseCartItemQuantity(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearAllCartItems extends CartEvent {
  const ClearAllCartItems();
}

// STATE
class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get itemCount => totalItemCount;
  int get uniqueItemCount => items.length;
  bool get isEmpty => items.isEmpty;

  double get subtotal =>
      items.fold<double>(0, (sum, item) => sum + item.totalPrice);

  // Clinic promotional discount 5%
  double get discountAmount => subtotal > 3000 ? subtotal * 0.05 : 0;

  // Free shipping on orders over ৳ 5,000, otherwise ৳ 120
  double get shippingFee =>
      (subtotal == 0 || subtotal >= 5000) ? 0 : 120;

  // 7.5% Medical VAT on net subtotal
  double get vatAmount => (subtotal - discountAmount) * 0.075;

  double get totalAmount =>
      (subtotal - discountAmount) + shippingFee + vatAmount;

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}

// BLOC
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc()
      : super(
          CartState(
            items: [
              CartItem(
                product: CatalogMockDataSource.instance.products[0], // Curing light
                quantity: 1,
              ),
              CartItem(
                product: CatalogMockDataSource.instance.products[2], // Ceramic bracket kit
                quantity: 2,
              ),
              CartItem(
                product: CatalogMockDataSource.instance.products[4], // Composite resin
                quantity: 3,
              ),
            ],
          ),
        ) {
    on<AddProductToCart>(_onAddToCart);
    on<RemoveProductFromCart>(_onRemoveFromCart);
    on<IncreaseCartItemQuantity>(_onIncreaseQuantity);
    on<DecreaseCartItemQuantity>(_onDecreaseQuantity);
    on<ClearAllCartItems>(_onClearCart);
  }

  void _onAddToCart(AddProductToCart event, Emitter<CartState> emit) {
    final currentList = List<CartItem>.from(state.items);
    final index = currentList.indexWhere((i) => i.product.id == event.product.id);

    if (index != -1) {
      final existing = currentList[index];
      currentList[index] = existing.copyWith(
        quantity: existing.quantity + event.quantity,
      );
    } else {
      currentList.add(CartItem(
        product: event.product,
        quantity: event.quantity,
      ));
    }

    emit(state.copyWith(items: currentList));
  }

  void _onRemoveFromCart(RemoveProductFromCart event, Emitter<CartState> emit) {
    final updated =
        state.items.where((i) => i.product.id != event.productId).toList();
    emit(state.copyWith(items: updated));
  }

  void _onIncreaseQuantity(
      IncreaseCartItemQuantity event, Emitter<CartState> emit) {
    final updated = state.items.map((item) {
      if (item.product.id == event.productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();
    emit(state.copyWith(items: updated));
  }

  void _onDecreaseQuantity(
      DecreaseCartItemQuantity event, Emitter<CartState> emit) {
    final updated = <CartItem>[];
    for (final item in state.items) {
      if (item.product.id == event.productId) {
        if (item.quantity > 1) {
          updated.add(item.copyWith(quantity: item.quantity - 1));
        }
        // if quantity == 1, omitting removes the item
      } else {
        updated.add(item);
      }
    }
    emit(state.copyWith(items: updated));
  }

  void _onClearCart(ClearAllCartItems event, Emitter<CartState> emit) {
    emit(const CartState(items: []));
  }
}
