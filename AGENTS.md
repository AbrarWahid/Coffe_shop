# Coffee Shop (Flutter)

## Commands
- Run: `flutter run -d chrome`
- Tests: `flutter test` (unit tests for pricing/search/validators/auth/orders + end-to-end widget flow at 320/390/1280 px)
- Analyze: `flutter analyze` (remaining "info" items are the Flutter 3.50 `material.dart` deprecation notice)
- Build: `flutter build web`

## Structure
- `lib/theme/app_theme.dart` – design tokens (AppColors, AppText, AppRadius, AppMotion, AppShadows) and ThemeData. Use these instead of hard-coded colors/fonts.
- `lib/state/app_state.dart` – AppState (session, basket, favourites, orders, delivery profile, home tab) via `AppScope.of/read`. Persists per user through `LocalStore`.
- `lib/data/` – `coffee.dart` (menu), `order.dart` (Order, Fulfilment, PaymentMethod, OrderStatus, `Pricing` rules), `menu_query.dart` (search/filter/sort), `auth_repository.dart` (device-local accounts, salted SHA-256), `local_store.dart` (shared_preferences JSON).
- Pages: `login_page`, `register_page`, `home_page` (Menu/Saved tabs + shell), `basket_page`, `checkout_sheet`, `orders_page` (list + `OrderDetailPage`), `account_page`, `detail_page`.
- `lib/widgets/` – shared components; user feedback goes through `widgets/feedback.dart` (`showToast`, `addToBasketWithFeedback`, `reorderWithFeedback`).
- Navigation: `main.dart` picks Splash/Login/Home from session state; never push Home manually after auth.

## Notes
- Auth and ordering are device-local simulations (no backend). Replace `AuthRepository` / `AppState.placeOrder` with API calls before production. Order status is time-simulated in `Order.statusAt`.
- Prices are `int` Rupiah; format with `formatRupiah`. Free delivery threshold and fee live in `Pricing`.
- `device_preview` is overridden to a patched local copy in `packages/device_preview` (Flutter 3.50 `resetInternalState` fix). Remove the override once upstream publishes a fix.
- Widget tests set `GoogleFonts.config.allowRuntimeFetching = false` and `SharedPreferences.setMockInitialValues({})`; inject `AppState(latency: Duration.zero)` into `MyApp`.
