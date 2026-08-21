import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../extensions/context_extension.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/product_card.dart';
import '../catalog/presentation/bloc/wishlist_bloc.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Wishlist'),
      ),
      body: BlocBuilder<WishlistBloc, WishlistState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: AppEmptyState(
                title: 'Your Wishlist is Empty',
                subtitle:
                    'Tap the heart icon on any dental product to save it for your next clinic order.',
                actionLabel: 'Explore Dental Catalog',
                onAction: () => context.pop(),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 245,
            ),
            itemBuilder: (context, index) {
              final product = state.items[index];
              return ProductCard(
                product: product,
                onTap: () => context.push(
                  '/product/${product.id}',
                  extra: product,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
