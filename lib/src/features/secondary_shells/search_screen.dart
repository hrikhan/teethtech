import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../extensions/context_extension.dart';
import '../../shared/widgets/app_search_bar.dart';
import '../../shared/widgets/product_card.dart';
import '../catalog/data/datasources/catalog_mock_datasource.dart';
import '../catalog/domain/entities/product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Product> _results = [];
  String _query = '';

  final List<String> _trendingSearches = const [
    'LED Curing Light',
    'Handpiece',
    'Orthodontic Brackets',
    'Composite Resin A2',
    'Root Canal Files',
    'Alginate',
    'Nitrile Gloves',
    'Sterilization Pouches',
  ];

  @override
  void initState() {
    super.initState();
    _results = CatalogMockDataSource.instance.products.take(6).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _query = query.trim().toLowerCase();
      if (_query.isEmpty) {
        _results = CatalogMockDataSource.instance.products.take(6).toList();
      } else {
        _results = CatalogMockDataSource.instance.products.where((p) {
          return p.name.toLowerCase().contains(_query) ||
              p.sku.toLowerCase().contains(_query) ||
              p.brandName.toLowerCase().contains(_query) ||
              p.categoryName.toLowerCase().contains(_query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: AppSearchBar(
            controller: _searchController,
            autoFocus: true,
            onChanged: _onSearch,
            trailing: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _onSearch('');
                    },
                  )
                : null,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trending Keywords
            if (_query.isEmpty) ...[
              Text(
                'Trending Searches 🔥',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _trendingSearches.map((kw) {
                  return ActionChip(
                    label: Text(kw),
                    backgroundColor: cs.surfaceContainerLow,
                    labelStyle: tt.bodySmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: () {
                      _searchController.text = kw;
                      _onSearch(kw);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Results Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _query.isEmpty ? 'Suggested Products' : 'Search Results',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_results.length} found',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Products Grid
            if (_results.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.search_off_rounded,
                          size: 48, color: cs.onSurfaceVariant),
                      const SizedBox(height: 12),
                      Text(
                        'No dental products found for "$_query"',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _results.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.67,
                ),
                itemBuilder: (context, index) {
                  final product = _results[index];
                  return ProductCard(
                    product: product,
                    onTap: () => context.push(
                      '/product/${product.id}',
                      extra: product,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
