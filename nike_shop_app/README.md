# nike_shop_app

A small demo Flutter shopping app intended for learning and quick iteration.
This README documents how the project is organized, how to run it, and
the key patterns you should follow when changing or extending the app.

## Quick start

Prerequisites:

- Flutter SDK (see <https://docs.flutter.dev/get-started/install>)
- A connected device or emulator (Android/iOS) for `flutter run`

From the project root:

```bash
flutter pub get
flutter run    # launches on the default device; use -d <deviceId> to target a specific device
```

Run tests:

```bash
flutter test
```

Notes for Windows (bash): the standard `flutter` commands work in bash.exe as long as Flutter is on your PATH.

## Project overview and architecture

This is a small single-module Flutter app. It uses Provider + ChangeNotifier for app state and simple, file-based UI pages.

- Entry point: `lib/main.dart`
  - Wraps the app with `ChangeNotifierProvider(create: (_) => Cart())`.
  - Initial route: `IntroPage` (in `lib/pages/intro_page.dart`).

- Models: `lib/models/`
  - `shoe.dart` — Plain data model for product items (fields: `name`, `price`, `imagePath`, `description`, `count`).
  - `cart.dart` — `ChangeNotifier` storing `shoeShop` (catalog) and `userCart` (items added). Methods: `getShoesList`, `getUserCart`, `addToCart`, `removeFromCart`.

- UI:
  - `lib/pages/` — screens: `intro_page.dart`, `shop_page.dart`, `cart_page.dart`.
  - `lib/components/` — reusable widgets such as `bottom_nav_bar.dart`, `shoe_tile.dart`, `cart_item.dart`.

- Assets: `assets/images/` and `assets/logo/` — declared in `pubspec.yaml`.

Design rationale / data flow

- Global state is intentionally minimal and stored in `Cart` (a `ChangeNotifier`). UI listens with `Provider.of<Cart>(context)` or `Consumer<Cart>`.
- The app uses simple object references for cart items (no deduplication or quantity merging). `userCart` is a list of `Shoe` objects; calling `addToCart` appends the object as-is and calls `notifyListeners()`.

Implication: if you need cart aggregation (combine same item quantities), update `lib/models/cart.dart` to track quantities and adapt UI accordingly.

## Conventions & gotchas

- Price values are stored as `String` in `Shoe.price` (e.g., `'240'`). Convert to `num`/`double` before arithmetic.
- `Shoe.count` exists but is not currently used to merge or limit quantities — code assumes `userCart` holds item entries directly.
- Widgets are typically `StatelessWidget`s that accept callbacks (see `BottomNavBar.onTabChange`). Keep callbacks nullable-safe.
- Asset paths are hard-coded in `cart.dart` (e.g., `assets/images/shoe.png`). If you rename images, update both `assets/` and `pubspec.yaml`.

## Developer workflows

- Hot reload: use `r` in the `flutter run` terminal or hot reload button in your IDE.
- Building release APK (Android):

```bash
flutter build apk --release
```

- iOS: build from macOS with Xcode or `flutter build ios` (requires Xcode and signing setup).

## Testing

- There is a basic widget test in `test/widget_test.dart`. Run `flutter test` to execute it.
- When adding functionality, include at least one unit or widget test for the new behavior (e.g., cart add/remove, page navigation).

## Files worth reading first

- `lib/main.dart` — provider wiring and starting point.
- `lib/models/cart.dart` — core state management and sample product list.
- `lib/pages/shop_page.dart` and `lib/components/shoe_tile.dart` — demonstrates product list UI and add-to-cart flow.

## How to change important parts

- Add products: edit `shoeShop` list in `lib/models/cart.dart` (this is the simple demo dataset).
- Change global state shape: update `Cart` class and then `lib/main.dart` provider creation if constructor changes.
- Change navigation: update pages in `lib/pages/` and the `BottomNavBar` callback wiring (see `lib/components/bottom_nav_bar.dart`).

## Dependencies

Key dependencies are in `pubspec.yaml`:

- `provider` — state management via `ChangeNotifier`.
- `google_nav_bar` — bottom navigation UI.

Run `flutter pub outdated` to inspect newer versions when updating dependencies.

## Troubleshooting

- Missing assets / white boxes: confirm images exist under `assets/images/` and `pubspec.yaml` lists that directory, then run `flutter pub get`.
- Hot reload not reflecting code changes: try a full restart (`R`) or stop and re-run `flutter run`.

## Contributing & PR checklist

- Run `flutter analyze` and `flutter test` locally before opening a PR.
- Verify assets load and main screens render.
- Keep changes small and targeted; this repo is used for learning and UI experimentation.

## License

This is a small demo project — no license file is included. Add one if you plan to publish or share widely.

---

If you want, I can also:

- Add a CONTRIBUTING.md with a PR checklist.
- Add a CI workflow (GitHub Actions) that runs `flutter analyze` and `flutter test` on PRs.

Tell me which of those you'd like and I will implement it.
