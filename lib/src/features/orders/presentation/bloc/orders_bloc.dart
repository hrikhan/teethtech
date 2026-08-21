import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../catalog/data/datasources/catalog_mock_datasource.dart';
import '../../domain/entities/order.dart';

// EVENTS
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();
  @override
  List<Object?> get props => [];
}

class LoadOrdersList extends OrdersEvent {
  const LoadOrdersList();
}

class FilterOrdersByStatus extends OrdersEvent {
  final OrderStatus? status; // null for All
  const FilterOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class CancelOrderRequested extends OrdersEvent {
  final String orderId;
  const CancelOrderRequested(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class AddNewOrder extends OrdersEvent {
  final DentalOrder order;
  const AddNewOrder(this.order);

  @override
  List<Object?> get props => [order];
}

// STATE
class OrdersState extends Equatable {
  final List<DentalOrder> allOrders;
  final OrderStatus? selectedFilter;
  final bool isLoading;

  const OrdersState({
    this.allOrders = const [],
    this.selectedFilter,
    this.isLoading = false,
  });

  List<DentalOrder> get filteredOrders {
    if (selectedFilter == null) return allOrders;
    return allOrders.where((o) => o.status == selectedFilter).toList();
  }

  OrdersState copyWith({
    List<DentalOrder>? allOrders,
    OrderStatus? selectedFilter,
    bool clearFilter = false,
    bool? isLoading,
  }) {
    return OrdersState(
      allOrders: allOrders ?? this.allOrders,
      selectedFilter:
          clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [allOrders, selectedFilter, isLoading];
}

// BLOC
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc()
      : super(
          OrdersState(
            allOrders: [
              DentalOrder(
                id: 'ord_1',
                orderNumber: 'TT-98421',
                orderDate: DateTime.now().subtract(const Duration(hours: 4)),
                status: OrderStatus.processing,
                items: [
                  CartItem(
                    product: CatalogMockDataSource.instance.products[2], // Ortho Brackets
                    quantity: 2,
                  ),
                  CartItem(
                    product: CatalogMockDataSource.instance.products[12], // Archwires
                    quantity: 5,
                  ),
                ],
                totalAmount: 11350,
                deliveryAddress: 'Apex Dental Care & Implant Center, Banani, Dhaka',
                paymentMethod: 'Cash on Delivery',
                trackingNumber: 'BD-DEX-984210',
              ),
              DentalOrder(
                id: 'ord_2',
                orderNumber: 'TT-98410',
                orderDate: DateTime.now().subtract(const Duration(days: 2)),
                status: OrderStatus.shipped,
                items: [
                  CartItem(
                    product: CatalogMockDataSource.instance.products[1], // Handpiece
                    quantity: 1,
                  ),
                ],
                totalAmount: 8200,
                deliveryAddress: 'Apex Dental Care & Implant Center, Banani, Dhaka',
                paymentMethod: 'bKash Merchant Pay',
                trackingNumber: 'SA-PARCEL-44912',
              ),
              DentalOrder(
                id: 'ord_3',
                orderNumber: 'TT-98390',
                orderDate: DateTime.now().subtract(const Duration(days: 6)),
                status: OrderStatus.delivered,
                items: [
                  CartItem(
                    product: CatalogMockDataSource.instance.products[5], // Alginate
                    quantity: 4,
                  ),
                  CartItem(
                    product: CatalogMockDataSource.instance.products[10], // Nitrile Gloves
                    quantity: 5,
                  ),
                ],
                totalAmount: 7050,
                deliveryAddress: 'Apex Dental Care Branch 2, Dhanmondi, Dhaka',
                paymentMethod: 'Visa / Mastercard',
                trackingNumber: 'REDX-DH-22019',
              ),
              DentalOrder(
                id: 'ord_4',
                orderNumber: 'TT-98315',
                orderDate: DateTime.now().subtract(const Duration(days: 14)),
                status: OrderStatus.delivered,
                items: [
                  CartItem(
                    product: CatalogMockDataSource.instance.products[0], // Curing Light
                    quantity: 1,
                  ),
                  CartItem(
                    product: CatalogMockDataSource.instance.products[7], // Sterilization Pouches
                    quantity: 2,
                  ),
                ],
                totalAmount: 6200,
                deliveryAddress: 'Apex Dental Care & Implant Center, Banani, Dhaka',
                paymentMethod: 'Cash on Delivery',
                trackingNumber: 'REDX-DH-19820',
              ),
              DentalOrder(
                id: 'ord_5',
                orderNumber: 'TT-98204',
                orderDate: DateTime.now().subtract(const Duration(days: 28)),
                status: OrderStatus.cancelled,
                items: [
                  CartItem(
                    product: CatalogMockDataSource.instance.products[13], // Titanium Implant
                    quantity: 1,
                  ),
                ],
                totalAmount: 11000,
                deliveryAddress: 'Apex Dental Care Branch 2, Dhanmondi, Dhaka',
                paymentMethod: 'bKash Online',
                trackingNumber: 'CANCELLED-REFUNDED',
              ),
            ],
          ),
        ) {
    on<LoadOrdersList>((event, emit) {});
    on<FilterOrdersByStatus>(_onFilter);
    on<CancelOrderRequested>(_onCancelOrder);
    on<AddNewOrder>(_onAddNewOrder);
  }

  void _onFilter(FilterOrdersByStatus event, Emitter<OrdersState> emit) {
    if (event.status == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(selectedFilter: event.status));
    }
  }

  void _onAddNewOrder(AddNewOrder event, Emitter<OrdersState> emit) {
    final updated = [event.order, ...state.allOrders];
    emit(state.copyWith(allOrders: updated));
  }

  void _onCancelOrder(CancelOrderRequested event, Emitter<OrdersState> emit) {
    final updated = state.allOrders.map((o) {
      if (o.id == event.orderId) {
        return DentalOrder(
          id: o.id,
          orderNumber: o.orderNumber,
          orderDate: o.orderDate,
          status: OrderStatus.cancelled,
          items: o.items,
          totalAmount: o.totalAmount,
          deliveryAddress: o.deliveryAddress,
          paymentMethod: o.paymentMethod,
          trackingNumber: o.trackingNumber,
        );
      }
      return o;
    }).toList();
    emit(state.copyWith(allOrders: updated));
  }
}
