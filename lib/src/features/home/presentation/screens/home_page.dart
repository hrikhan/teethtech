import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/app_assets.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../shared/widgets/category_card.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../auth/presentation/providers/session_bloc.dart';
import '../../../catalog/domain/entities/brand.dart';
import '../../../catalog/presentation/bloc/wishlist_bloc.dart';
import '../bloc/home_bloc.dart';
import '../widgets/promo_banner_carousel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;
    final isDark = context.theme.brightness == Brightness.dark;
    final wishlistCount =
        context.select<WishlistBloc, int>((b) => b.state.items.length);
    final session = context.watch<SessionBloc>().state;
    final isAuthenticated = session.status == SessionStatus.authenticated;
    final user = session.user;
    final isB2b = isAuthenticated && (user?.isB2b ?? false);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        titleSpacing: 16,
        title: Image.asset(
          AppAssets.logo,
          height: 28,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  text: 'Teeth',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                    letterSpacing: -0.5,
                  ),
                  children: [
                    TextSpan(
                      text: 'Tech',
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Wishlist Action
          IconButton(
            onPressed: () => context.push(AppRoutes.wishlist),
            icon: Badge(
              isLabelVisible: wishlistCount > 0,
              label: Text('$wishlistCount'),
              backgroundColor: cs.error,
              child: const Icon(Icons.favorite_outline_rounded),
            ),
          ),

          // Notifications Action
          IconButton(
            onPressed: () => context.push(AppRoutes.notifications),
            icon: const Badge(
              isLabelVisible: true,
              label: Text('3'),
              backgroundColor: Color(0xFFD97706),
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // User Status & Tier Banner (Dynamic for B2B, B2C, and Guest)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _buildTierHeaderBanner(
                    context: context,
                    isAuthenticated: isAuthenticated,
                    isB2b: isB2b,
                    userName: user?.name,
                    isDark: isDark,
                  ),
                ),
              ),

              // Search Bar Section
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: AppSearchBar(
                    readOnly: true,
                    onTap: () => context.push(AppRoutes.search),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Promo Banner Carousel
              SliverToBoxAdapter(
                child: PromoBannerCarousel(
                  banners: state.banners,
                  onBannerTap: (banner) =>
                      context.push(AppRoutes.productListing),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Shop by Category Header & Horizontal List
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Shop by Category',
                  subtitle: 'Explore clinical materials & equipment',
                  onAction: () => context.push(AppRoutes.categories),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 114,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final cat = state.categories[index];
                      return CategoryCard(
                        category: cat,
                        onTap: () => context.push(
                          '${AppRoutes.productListing}?category=${cat.id}&title=${Uri.encodeComponent(cat.name)}',
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Recommended For You Header + Filter Tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recommended For You',
                        style: tt.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tabs: Latest Products, Featured Products, Best Selling
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTabChip(
                              context: context,
                              label: 'Featured Products',
                              isSelected:
                                  state.activeTab == RecommendationTab.featured,
                              onTap: () => context.read<HomeBloc>().add(
                                    const ChangeRecommendationTab(
                                        RecommendationTab.featured),
                                  ),
                            ),
                            const SizedBox(width: 8),
                            _buildTabChip(
                              context: context,
                              label: 'Latest Arrivals',
                              isSelected:
                                  state.activeTab == RecommendationTab.latest,
                              onTap: () => context.read<HomeBloc>().add(
                                    const ChangeRecommendationTab(
                                        RecommendationTab.latest),
                                  ),
                            ),
                            const SizedBox(width: 8),
                            _buildTabChip(
                              context: context,
                              label: 'Best Selling',
                              isSelected: state.activeTab ==
                                  RecommendationTab.bestSelling,
                              onTap: () => context.read<HomeBloc>().add(
                                    const ChangeRecommendationTab(
                                        RecommendationTab.bestSelling),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Product Grid for Active Tab
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 245,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = state.tabProducts[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push(
                          '/product/${product.id}',
                          extra: product,
                        ),
                      );
                    },
                    childCount: state.tabProducts.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Top Dental Brands
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Top Dental Brands',
                  subtitle: 'Genuine materials from certified manufacturers',
                  actionLabel: 'All Brands',
                  onAction: () => context.push(AppRoutes.productListing),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 95,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: state.topBrands.length,
                    itemBuilder: (context, index) {
                      final brand = state.topBrands[index];
                      return _buildBrandCard(context, brand);
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Special Deals & Clinic Offers Section
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Special Deals & Offers 🔥',
                  subtitle: 'Limited-time discounts on practice supplies',
                  onAction: () => context.push(AppRoutes.productListing),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = state.deals[index];
                      return ProductCard(
                        product: product,
                        isHorizontal: true,
                        onTap: () => context.push(
                          '/product/${product.id}',
                          extra: product,
                        ),
                      );
                    },
                    childCount: state.deals.length.clamp(0, 4),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTierHeaderBanner({
    required BuildContext context,
    required bool isAuthenticated,
    required bool isB2b,
    required String? userName,
    required bool isDark,
  }) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    if (!isAuthenticated) {
      // Guest User Banner
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFD97706).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                color: Color(0xFFD97706),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to TeethTech Marketplace',
                    style: tt.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Browsing mode • Sign in for clinical delivery',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => context.push(AppRoutes.login),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isB2b) {
      // B2B Clinic Active Banner
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          userName ?? 'Apex Dental Care',
                          style: tt.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'B2B WHOLESALE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Tiered clinic wholesale rates active on all supplies',
                    style: tt.bodySmall?.copyWith(
                      color: cs.primary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // B2C Customer Banner
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00897B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF00897B).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF00897B),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${userName ?? "Doctor"}',
                  style: tt.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Retail Account • Single item orders supported',
                  style: TextStyle(
                    color: Color(0xFF00897B),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => context.push(AppRoutes.account),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00897B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF00897B).withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'Get B2B',
                style: TextStyle(
                  color: Color(0xFF00897B),
                  fontWeight: FontWeight.bold,
                  fontSize: 10.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: tt.labelMedium?.copyWith(
            color: isSelected ? Colors.white : cs.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBrandCard(BuildContext context, DentalBrand brand) {
    final cs = context.theme.colorScheme;
    final tt = context.theme.textTheme;

    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        onTap: () => context.push(
          '${AppRoutes.productListing}?brand=${brand.id}&title=${Uri.encodeComponent(brand.name)}',
        ),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_rounded, size: 14, color: cs.primary),
                  const SizedBox(width: 4),
                  Text(
                    brand.origin,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                brand.name,
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${brand.productCount}+ Products',
                style: tt.bodySmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
