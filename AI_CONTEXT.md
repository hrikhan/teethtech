# TeethTech — Dental Supply Marketplace (AI Context & Architecture Guide)

## 1. Project Overview
**TeethTech** is a specialized B2C + B2B dental e-commerce mobile application built in Flutter. It caters to dentists, orthodontic specialists, oral surgeons, and dental clinic procurement managers across Bangladesh.

- **Primary Brand Color**: `#167CD1` (TeethTech Cerulean / Dental Blue)
- **Currency**: `৳` (Bangladeshi Taka, formatted as `৳ 2,450`)
- **Typography**: Serif styling for prominent branding/headlines (Playfair Display font stack) and clean sans-serif for medical product specs, SKU, and pricing.
- **Architecture**: Clean Feature-First Architecture (`lib/src/features/<feature>/domain`, `data`, `presentation`).
- **State Management**: `flutter_bloc` (immutable states and events).
- **Navigation**: `go_router` with `StatefulShellRoute.indexedStack` for bottom navigation tabs.

---

## 2. Completed Foundation (Phase 1)

### A. Design System & Theme
- **Primary Color**: `Color(0xFF167CD1)`
- **Color Palettes**: Light Mode (`#FFFFFF`, slate `#F8FAFC`, navy `#0F172A`) & Dark Mode (`#0B111A`, `#131D2A`, `#F8FAFC`).
- **Theme Persistence**: `ThemeCubit` manages `ThemeMode.system`, `ThemeMode.light`, and `ThemeMode.dark` persisted via `StorageService`.
- **Material 3 Component Theming**: Customized `CardThemeData`, `ElevatedButtonThemeData`, `OutlinedButtonThemeData`, `InputDecorationTheme`, `NavigationBarThemeData`, `TabBarThemeData`.

### B. Startup & Authentication Flow
- **Splash Screen** (`/splash`): Animated TeethTech branding with auto-navigation.
- **Onboarding Page** (`/onboarding`): 3 dental supply marketplace slides with smooth indicator.
- **Welcome Entry** (`/welcome`): Gateway for Sign In, Create Account, or Continue as Guest.
- **Registration** (`/signup`): Supports Personal (B2C) vs Clinic (B2B) account registration.
- **Login** (`/login`): Clean authentication with mock or backend toggling.
- **Password Reset** (`/forgot-password`): Recovery workflow.

### C. Persistent 5-Tab Shell (`MainShellScreen`)
1. **Home Tab** (`/`):
   - TeethTech app bar with search shortcut, wishlist badge, notification badge.
   - Promotional hero banner carousel (`PromoBannerCarousel`).
   - Horizontal categories slider (`CategoryCard`).
   - "Recommended For You" with 3 working filter tabs (*Featured Products*, *Latest Arrivals*, *Best Selling*).
   - Top Dental Brands horizontal slider (`3M ESPE`, `Dentsply Sirona`, `Woodpecker`, `Kerr`, etc.).
   - Special Deals & Flash Offers.
2. **Categories Tab** (`/categories`):
   - Category rail with product counts.
   - Subcategories filter chips with responsive product grid.
3. **Cart Tab** (`/cart`):
   - Item stepper with real-time quantity addition/subtraction.
   - Reactive badge count on the bottom navigation bar.
   - Comprehensive price summary in `৳` (Subtotal, 5% Discount, Medical Courier, 7.5% VAT, Final Total).
   - "Proceed to Checkout" CTA button.
4. **Orders Tab** (`/orders`):
   - Status filters (`All`, `Processing`, `Shipped`, `Delivered`, `Cancelled`).
   - Order cards with status chips, item lists, and total amounts.
5. **Account Tab** (`/account`):
   - Profile header with `B2B Clinic Member` badge.
   - Shopping actions (Orders, Wishlist, Addresses, Reviews).
   - Support actions (Returns, Equipment Warranty, Help Center).
   - App settings (Theme selector modal, Notifications, Language, About).
   - Logout dialog with session reset.

### D. Secondary Route Shells (14 Screens)
- `/search` — `SearchScreen` with instant query matching & trending dental keywords.
- `/products` — `ProductListingScreen` with category/brand filtering & sorting (Popularity, Price, Rating).
- `/product/:id` — `ProductDetailsScreen` with image gallery, SKU, technical specs table, B2B wholesale pricing table, quantity stepper, and bottom purchase bar.
- `/wishlist` — `WishlistScreen` with favorited items grid.
- `/notifications` — `NotificationsScreen` with 8+ clinical alerts.
- `/checkout` — `CheckoutScreen` with address selector, COD/bKash/Card payment options, and placement confirmation.
- `/order/:id` — `OrderDetailsScreen` with invoice items breakdown.
- `/order-tracking/:id` — `OrderTrackingScreen` with multi-stage shipment timeline.
- `/addresses` — `AddressesScreen` with saved clinic addresses.
- `/reviews` — `ReviewsScreen` with verified doctor purchase reviews.
- `/returns` — `ReturnsScreen` with 7-day replacement guarantee & request flow.
- `/warranty` — `WarrantyScreen` with serial number lookup & warranty cards.
- `/settings` — `SettingsScreen` with push notifications and theme switcher.
- `/help-center` — `HelpCenterScreen` with practice support hotline & FAQ accordion.

---

## 3. Mock Data Structure (`CatalogMockDataSource`)
- **25+ Realistic Dental Products**: High-speed handpieces, 1-sec LED curing lights, ceramic brackets, NiTi rotary files, nanohybrid composite resins, alginates, scaler tips, sterilization pouches, and surgical mirrors with real SKUs, B2B bulk pricing, and image URLs.
- **10+ Dental Categories**: Equipment, Materials, Orthodontics, Endodontics, Prosthodontics, Oral Surgery, Implants, Instruments, Sterilization, Consumables.
- **8+ Dental Brands**: 3M ESPE, Dentsply Sirona, Woodpecker, Kerr Dental, Ivoclar Vivadent, GC Dental, Hu-Friedy, Kulzer.
- **5+ Mock Orders**: Multi-item clinic orders with various order statuses.

---

## 4. Key State Management Units (BLoCs & Cubits)
- **`ThemeCubit`**: Local storage persistent theme mode controller.
- **`SessionBloc`**: Authentication state listener.
- **`AuthBloc`**: Login, Registration (B2C/B2B), and Forgot Password events.
- **`HomeBloc`**: Promo banners, categories, recommendation tabs.
- **`CategoriesBloc`**: Category and subcategory product filtering.
- **`CartBloc`**: Reactive cart operations, item count badge, VAT/shipping/total in `৳`.
- **`OrdersBloc`**: Status filtering and order cancellations.
- **`WishlistBloc`**: Instant toggle and persistence of favorite products.

---

## 5. Next Steps for Subsequent Phases
- Connect live REST API endpoints via `AuthRemoteDataSource` and `CatalogRemoteDataSource` by toggling `USE_MOCK_API=false` in `.env`.
- Integrate bKash / SSLCommerz payment gateway SDKs in `CheckoutScreen`.
- Implement barcode / QR code scanning for dental product lookup.
