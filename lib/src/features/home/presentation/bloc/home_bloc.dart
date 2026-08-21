import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../catalog/data/datasources/catalog_mock_datasource.dart';
import '../../../catalog/domain/entities/brand.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';

enum RecommendationTab { latest, featured, bestSelling }

// EVENTS
abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class ChangeRecommendationTab extends HomeEvent {
  final RecommendationTab tab;
  const ChangeRecommendationTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

// STATE
class HomeState extends Equatable {
  final List<PromoBanner> banners;
  final List<DentalCategory> categories;
  final List<DentalBrand> topBrands;
  final List<Product> deals;
  final List<Product> newArrivals;
  final RecommendationTab activeTab;
  final List<Product> tabProducts;

  const HomeState({
    required this.banners,
    required this.categories,
    required this.topBrands,
    required this.deals,
    required this.newArrivals,
    required this.activeTab,
    required this.tabProducts,
  });

  HomeState copyWith({
    List<PromoBanner>? banners,
    List<DentalCategory>? categories,
    List<DentalBrand>? topBrands,
    List<Product>? deals,
    List<Product>? newArrivals,
    RecommendationTab? activeTab,
    List<Product>? tabProducts,
  }) {
    return HomeState(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      topBrands: topBrands ?? this.topBrands,
      deals: deals ?? this.deals,
      newArrivals: newArrivals ?? this.newArrivals,
      activeTab: activeTab ?? this.activeTab,
      tabProducts: tabProducts ?? this.tabProducts,
    );
  }

  @override
  List<Object?> get props => [
        banners,
        categories,
        topBrands,
        deals,
        newArrivals,
        activeTab,
        tabProducts,
      ];
}

// BLOC
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc()
      : super(
          HomeState(
            banners: CatalogMockDataSource.instance.promoBanners,
            categories: CatalogMockDataSource.instance.categories,
            topBrands: CatalogMockDataSource.instance.brands,
            deals: CatalogMockDataSource.instance.products
                .where((p) => p.hasDiscount)
                .toList(),
            newArrivals: CatalogMockDataSource.instance.products
                .where((p) => p.isNewArrival)
                .toList(),
            activeTab: RecommendationTab.featured,
            tabProducts: CatalogMockDataSource.instance.products
                .where((p) => p.isFeatured)
                .toList(),
          ),
        ) {
    on<ChangeRecommendationTab>(_onChangeTab);
  }

  void _onChangeTab(ChangeRecommendationTab event, Emitter<HomeState> emit) {
    List<Product> prods;
    switch (event.tab) {
      case RecommendationTab.latest:
        prods = CatalogMockDataSource.instance.products
            .where((p) => p.isNewArrival)
            .toList();
        if (prods.isEmpty) prods = CatalogMockDataSource.instance.products.take(6).toList();
        break;
      case RecommendationTab.featured:
        prods = CatalogMockDataSource.instance.products
            .where((p) => p.isFeatured)
            .toList();
        break;
      case RecommendationTab.bestSelling:
        prods = CatalogMockDataSource.instance.products
            .where((p) => p.isBestSeller)
            .toList();
        break;
    }

    emit(state.copyWith(
      activeTab: event.tab,
      tabProducts: prods,
    ));
  }
}
