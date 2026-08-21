import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../extensions/context_extension.dart';
import '../../shared/widgets/product_card.dart';
import '../catalog/data/datasources/catalog_mock_datasource.dart';
import '../catalog/domain/entities/product.dart';

class ProductListingScreen extends StatefulWidget {
  final String? categoryId;
  final String? brandId;
  final String title;

  const ProductListingScreen({
    super.key,
    this.categoryId,
    this.brandId,
    this.title = 'Dental Products',
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String _selectedSort = 'Popularity';
  late List<Product> _products;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    var list = List<Product>.from(CatalogMockDataSource.instance.products);

    if (widget.categoryId != null && widget.categoryId!.isNotEmpty) {
      list = list.where((p) => p.categoryId == widget.categoryId).toList();
    }
    if (widget.brandId != null && widget.brandId!.isNotEmpty) {
      list = list.where((p) => p.brandId == widget.brandId).toList();
    }

    if (list.isEmpty) {
      list = CatalogMockDataSource.instance.products;
    }

    _sortList(list, _selectedSort);
    _products = list;
  }

  void _sortList(List<Product> list, String sortOption) {
    if (sortOption == 'Price: Low to High') {
      list.sort((a, b) => a.salePrice.compareTo(b.salePrice));
    } else if (sortOption == 'Price: High to Low') {
      list.sort((a, b) => b.salePrice.compareTo(a.salePrice));
    } else if (sortOption == 'Rating') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter / Sort Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_products.length} Products Found',
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                PopupMenuButton<String>(
                  initialValue: _selectedSort,
                  onSelected: (val) {
                    setState(() {
                      _selectedSort = val;
                      _sortList(_products, val);
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Popularity',
                      child: Text('Popularity'),
                    ),
                    const PopupMenuItem(
                      value: 'Price: Low to High',
                      child: Text('Price: Low to High'),
                    ),
                    const PopupMenuItem(
                      value: 'Price: High to Low',
                      child: Text('Price: High to Low'),
                    ),
                    const PopupMenuItem(
                      value: 'Rating',
                      child: Text('Top Rated'),
                    ),
                  ],
                  child: Row(
                    children: [
                      Icon(Icons.sort_rounded, size: 18, color: cs.primary),
                      const SizedBox(width: 4),
                      Text(
                        _selectedSort,
                        style: tt.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Grid of Products
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 245,
              ),
              itemBuilder: (context, index) {
                final product = _products[index];
                return ProductCard(
                  product: product,
                  onTap: () => context.push(
                    '/product/${product.id}',
                    extra: product,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
