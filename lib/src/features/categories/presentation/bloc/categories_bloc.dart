import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../catalog/data/datasources/catalog_mock_datasource.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';

// EVENTS
abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();
  @override
  List<Object?> get props => [];
}

class SelectCategoryEvent extends CategoriesEvent {
  final DentalCategory category;
  const SelectCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class FilterProductsBySubcategory extends CategoriesEvent {
  final String subcategory;
  const FilterProductsBySubcategory(this.subcategory);

  @override
  List<Object?> get props => [subcategory];
}

// STATE
class CategoriesState extends Equatable {
  final List<DentalCategory> categories;
  final DentalCategory selectedCategory;
  final String? selectedSubcategory;
  final List<Product> categoryProducts;

  const CategoriesState({
    required this.categories,
    required this.selectedCategory,
    this.selectedSubcategory,
    required this.categoryProducts,
  });

  CategoriesState copyWith({
    List<DentalCategory>? categories,
    DentalCategory? selectedCategory,
    String? selectedSubcategory,
    bool clearSubcategory = false,
    List<Product>? categoryProducts,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubcategory: clearSubcategory
          ? null
          : (selectedSubcategory ?? this.selectedSubcategory),
      categoryProducts: categoryProducts ?? this.categoryProducts,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        selectedCategory,
        selectedSubcategory,
        categoryProducts,
      ];
}

// BLOC
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc()
      : super(
          CategoriesState(
            categories: CatalogMockDataSource.instance.categories,
            selectedCategory: CatalogMockDataSource.instance.categories.first,
            categoryProducts: CatalogMockDataSource.instance.products
                .where((p) =>
                    p.categoryId ==
                    CatalogMockDataSource.instance.categories.first.id)
                .toList(),
          ),
        ) {
    on<SelectCategoryEvent>(_onSelectCategory);
    on<FilterProductsBySubcategory>(_onFilterSubcategory);
  }

  void _onSelectCategory(
      SelectCategoryEvent event, Emitter<CategoriesState> emit) {
    final prods = CatalogMockDataSource.instance.products
        .where((p) => p.categoryId == event.category.id)
        .toList();

    emit(state.copyWith(
      selectedCategory: event.category,
      clearSubcategory: true,
      categoryProducts: prods,
    ));
  }

  void _onFilterSubcategory(
      FilterProductsBySubcategory event, Emitter<CategoriesState> emit) {
    final allInCat = CatalogMockDataSource.instance.products
        .where((p) => p.categoryId == state.selectedCategory.id)
        .toList();

    if (state.selectedSubcategory == event.subcategory) {
      // Toggle off
      emit(state.copyWith(
        clearSubcategory: true,
        categoryProducts: allInCat,
      ));
    } else {
      final filtered =
          allInCat.where((p) => p.subcategory == event.subcategory).toList();
      emit(state.copyWith(
        selectedSubcategory: event.subcategory,
        categoryProducts: filtered.isNotEmpty ? filtered : allInCat,
      ));
    }
  }
}
