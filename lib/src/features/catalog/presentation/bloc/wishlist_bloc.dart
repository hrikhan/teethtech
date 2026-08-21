import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/catalog_mock_datasource.dart';
import '../../domain/entities/product.dart';

// EVENTS
abstract class WishlistEvent extends Equatable {
  const WishlistEvent();
  @override
  List<Object?> get props => [];
}

class ToggleWishlistProduct extends WishlistEvent {
  final Product product;
  const ToggleWishlistProduct(this.product);

  @override
  List<Object?> get props => [product];
}

// STATE
class WishlistState extends Equatable {
  final List<Product> items;

  const WishlistState({this.items = const []});

  bool isFavorite(String productId) =>
      items.any((item) => item.id == productId);

  @override
  List<Object?> get props => [items];
}

// BLOC
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  WishlistBloc()
      : super(
          WishlistState(
            items: [
              CatalogMockDataSource.instance.products[1], // Handpiece
              CatalogMockDataSource.instance.products[3], // NiTi Files
            ],
          ),
        ) {
    on<ToggleWishlistProduct>(_onToggle);
  }

  void _onToggle(ToggleWishlistProduct event, Emitter<WishlistState> emit) {
    final exists = state.isFavorite(event.product.id);
    if (exists) {
      final updated =
          state.items.where((p) => p.id != event.product.id).toList();
      emit(WishlistState(items: updated));
    } else {
      emit(WishlistState(items: [...state.items, event.product]));
    }
  }
}
