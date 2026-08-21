/// Centralized route path constants for GoRouter in TeethTech.
abstract final class AppRoutes {
  AppRoutes._();

  // Startup & Auth
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';

  // 5 Main Tabs (IndexedStack branches)
  static const String home = '/';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String account = '/account';

  // Secondary Shells & Screens
  static const String search = '/search';
  static const String productListing = '/products';
  static const String productDetails = '/product/:id';
  static const String wishlist = '/wishlist';
  static const String notifications = '/notifications';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orderDetails = '/order/:id';
  static const String orderTracking = '/order-tracking/:id';
  static const String addresses = '/addresses';
  static const String reviews = '/reviews';
  static const String returns = '/returns';
  static const String warranty = '/warranty';
  static const String settings = '/settings';
  static const String helpCenter = '/help-center';
  static const String quotations = '/quotations';
  static const String requestQuotation = '/request-quotation';
}
