import 'package:go_router/go_router.dart';
import 'package:teethtech/src/routing/global_navigator.dart';
import 'package:teethtech/src/routing/app_routes.dart';

import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_page.dart';
import '../features/auth/presentation/screens/welcome_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/signup_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';

import '../features/shell/presentation/screens/main_shell_screen.dart';
import '../features/home/presentation/screens/home_page.dart';
import '../features/categories/presentation/screens/categories_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/orders/presentation/screens/orders_screen.dart';
import '../features/account/presentation/screens/account_screen.dart';

import '../features/secondary_shells/search_screen.dart';
import '../features/secondary_shells/product_listing_screen.dart';
import '../features/secondary_shells/product_details_screen.dart';
import '../features/secondary_shells/wishlist_screen.dart';
import '../features/secondary_shells/notifications_screen.dart';
import '../features/secondary_shells/checkout_screen.dart';
import '../features/secondary_shells/order_success_screen.dart';
import '../features/secondary_shells/order_details_screen.dart';
import '../features/secondary_shells/order_tracking_screen.dart';
import '../features/secondary_shells/addresses_screen.dart';
import '../features/secondary_shells/reviews_screen.dart';
import '../features/secondary_shells/returns_screen.dart';
import '../features/secondary_shells/warranty_screen.dart';
import '../features/secondary_shells/settings_screen.dart';
import '../features/secondary_shells/help_center_screen.dart';
import '../features/quotations/presentation/screens/quotations_screen.dart';
import '../features/quotations/presentation/screens/request_quotation_screen.dart';

import '../features/catalog/data/datasources/catalog_mock_datasource.dart';
import '../features/catalog/domain/entities/product.dart';
import '../features/orders/domain/entities/order.dart';

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    // Startup & Auth flow
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      name: 'onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      name: 'welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      name: 'signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      name: 'forgotPassword',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Persistent 5-Tab Shell Navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),

        // Tab 1: Categories
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.categories,
              name: 'categories',
              builder: (context, state) => const CategoriesScreen(),
            ),
          ],
        ),

        // Tab 2: Cart
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.cart,
              name: 'cart',
              builder: (context, state) => const CartScreen(),
            ),
          ],
        ),

        // Tab 3: Orders
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.orders,
              name: 'orders',
              builder: (context, state) => const OrdersScreen(),
            ),
          ],
        ),

        // Tab 4: Account
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.account,
              name: 'account',
              builder: (context, state) => const AccountScreen(),
            ),
          ],
        ),
      ],
    ),

    // Secondary Screen Shells (Pushed over the bottom navigation bar)
    GoRoute(
      path: AppRoutes.search,
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.productListing,
      name: 'productListing',
      builder: (context, state) {
        final catId = state.uri.queryParameters['category'];
        final brandId = state.uri.queryParameters['brand'];
        final title = state.uri.queryParameters['title'] ?? 'Dental Products';
        return ProductListingScreen(
          categoryId: catId,
          brandId: brandId,
          title: title,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.productDetails,
      name: 'productDetails',
      builder: (context, state) {
        final productId = state.pathParameters['id'] ?? '';
        final product = state.extra as Product?;
        return ProductDetailsScreen(
          productId: productId,
          initialProduct: product,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.wishlist,
      name: 'wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: AppRoutes.notifications,
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.checkout,
      name: 'checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: AppRoutes.orderSuccess,
      name: 'orderSuccess',
      builder: (context, state) {
        final order = state.extra as DentalOrder?;
        if (order != null) {
          return OrderSuccessScreen(order: order);
        }
        final fallback = DentalOrder(
          id: 'ord_sample',
          orderNumber: 'TT-893201',
          orderDate: DateTime.now(),
          status: OrderStatus.processing,
          items: const [],
          totalAmount: 2450,
          deliveryAddress: 'House #12, Road #4, Dhanmondi, Dhaka',
          paymentMethod: 'Cash on Delivery',
          trackingNumber: 'DEX-TT-893201',
        );
        return OrderSuccessScreen(order: fallback);
      },
    ),
    GoRoute(
      path: AppRoutes.orderDetails,
      name: 'orderDetails',
      builder: (context, state) {
        final orderId = state.pathParameters['id'] ?? '';
        final order = state.extra as DentalOrder?;
        return OrderDetailsScreen(
          orderId: orderId,
          initialOrder: order,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.orderTracking,
      name: 'orderTracking',
      builder: (context, state) {
        final orderId = state.pathParameters['id'] ?? '';
        final order = state.extra as DentalOrder?;
        return OrderTrackingScreen(
          orderId: orderId,
          order: order,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.addresses,
      name: 'addresses',
      builder: (context, state) => const AddressesScreen(),
    ),
    GoRoute(
      path: AppRoutes.reviews,
      name: 'reviews',
      builder: (context, state) => const ReviewsScreen(),
    ),
    GoRoute(
      path: AppRoutes.returns,
      name: 'returns',
      builder: (context, state) => const ReturnsScreen(),
    ),
    GoRoute(
      path: AppRoutes.warranty,
      name: 'warranty',
      builder: (context, state) => const WarrantyScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.helpCenter,
      name: 'helpCenter',
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: AppRoutes.quotations,
      name: 'quotations',
      builder: (context, state) => const QuotationsScreen(),
    ),
    GoRoute(
      path: AppRoutes.requestQuotation,
      name: 'requestQuotation',
      builder: (context, state) {
        final product = state.extra as Product? ??
            CatalogMockDataSource.instance.products.first;
        return RequestQuotationScreen(product: product);
      },
    ),
  ],
);
