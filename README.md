# e_com_app — Flutter E-Commerce Store

Production-ready Flutter e-commerce client powered by **BLoC**, **SharedPreferences**, and
the [Fake Store API](https://fakestoreapi.com). Browse products, search with live filters, manage
favourites, and control cart quantities with offline persistence across app restarts.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Data Flow](#data-flow)
- [Screens & UX](#screens--ux)
- [Persistence](#persistence)
- [API Contract & Response Changes](#api-contract--response-changes)
- [Getting Started](#getting-started)
- [App Analysis](#app-analysis)
- [AI Reproduction Prompt](#ai-reproduction-prompt)

---

## Features

| Area               | Capability                                                                |
|--------------------|---------------------------------------------------------------------------|
| **Catalog**        | Fetches products from `https://fakestoreapi.com/products`                 |
| **Home**           | 2-column grid, favourite toggle, context-aware cart controls on each card |
| **Search**         | Real-time title filter + price slider (both applied together)             |
| **Cart**           | Add, increment, decrement, remove; quantity × price line totals           |
| **Favourites**     | Save/remove products; persisted locally                                   |
| **Product detail** | Category chip, rating badge, description, Hero image, bottom cart action  |
| **Checkout**       | Clears in-memory cart state and removes cart key from SharedPreferences   |
| **Cold start**     | Rehydrates cart (with quantities) and favourites from disk                |

---

## Tech Stack

| Package              | Purpose                                 |
|----------------------|-----------------------------------------|
| `flutter_bloc`       | State management (events → bloc → UI)   |
| `http`               | REST API calls                          |
| `shared_preferences` | Local persistence for cart & favourites |
| Material 3           | Theming via `ColorScheme.fromSeed`      |

**SDK:** Dart `^3.11.5`

---

## Project Structure

```
lib/
├── main.dart                          # App entry, RepositoryProvider + BlocProvider
├── core/
│   └── theme/
│       └── app_theme.dart             # Material 3 theme (radii, borders, inputs)
├── data/
│   ├── models/
│   │   └── product_model.dart         # Product, Rating, CartItem
│   └── repositories/
│       └── product_repository.dart    # API + SharedPreferences I/O
├── logic/
│   └── bloc/
│       ├── product_bloc.dart
│       ├── product_event.dart
│       └── product_state.dart
├── presentation/
│   └── screens/
│       ├── main_navigation_screen.dart
│       ├── home_screen.dart
│       ├── search_screen.dart
│       ├── cart_screen.dart
│       ├── favourite_screen.dart
│       └── product_detail_screen.dart
└── widgets/
    ├── product_card.dart
    ├── cart_quantity_selector.dart
    └── rating_badge.dart
```

---

## Architecture

Clean layered structure:

```
┌─────────────────────────────────────────┐
│  UI (Screens + Widgets)                 │
│  BlocBuilder / context.read<ProductBloc>│
└──────────────────┬──────────────────────┘
                   │ events / state
┌──────────────────▼──────────────────────┐
│  ProductBloc                            │
│  Load, Filter, Favourite, Cart, Checkout│
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│  ProductRepository                      │
│  HTTP (catalog) + SharedPreferences     │
└─────────────────────────────────────────┘
```

- **Single bloc** (`ProductBloc`) owns catalog, search filters, favourites, and cart.
- **Repository pattern** isolates network and storage from business logic.
- **No comments** in source — naming and structure are self-documenting.

---

## Data Flow

### App launch

1. `MainNavigationScreen.initState` dispatches `LoadProductsEvent`.
2. Bloc fetches products from API, loads favourites and cart from prefs.
3. `catalogMaxPrice` is computed from the catalog; search slider max is set accordingly.
4. UI shows loading → success or failure with retry.

### Cart with quantity

- State holds `List<CartItem>` where each item = `Product` + `quantity`.
- Persisted JSON shape: `{ "product": { ... }, "quantity": n }`.
- Legacy cart rows (product-only JSON) are migrated on load and merged by `product.id`.

### Events

| Event                        | Effect                                            |
|------------------------------|---------------------------------------------------|
| `LoadProductsEvent`          | Fetch catalog + rehydrate favourites & cart       |
| `ToggleFavouriteEvent`       | Add/remove favourite + save prefs                 |
| `AddToCartEvent`             | Add line at quantity 1 (no-op if already in cart) |
| `IncrementCartQuantityEvent` | `quantity + 1`                                    |
| `DecrementCartQuantityEvent` | `quantity - 1`; remove line at 0                  |
| `RemoveFromCartEvent`        | Remove entire line                                |
| `FilterProductsEvent`        | Apply `query` + `maxPrice` to `allProducts`       |
| `CheckoutCartEvent`          | `clearCart()` in prefs + empty `cartItems`        |

Every cart/favourite mutation writes to SharedPreferences **before** emitting new state.

---

## Screens & UX

### Navigation

- `NavigationBar` (Material 3) + `IndexedStack` preserves tab state.
- Tabs: **Home**, **Search**, **Cart**, **Favourite**.

### Design system (`AppTheme`)

- Border radius: **12–16px**
- Cards/surfaces: **subtle `BorderSide`**, not heavy elevation
- Background: `#F8F7FC`, seed color `#5C4DFF`

### Home / Search / Favourites — `ProductCard`

- Bordered card, network image with **Hero** tag `product-image-{id}`.
- Heart icon synced with `state.isFavourite(id)`.
- **Cart-aware footer:**
    - Not in cart → full-width **Add to Cart**
    - In cart → compact **− / count / +** (`CartQuantitySelector`)
- Tap image/title → `ProductDetailScreen` with fade transition.

### Search

- `TextField.onChanged` and `Slider.onChanged` both dispatch `FilterProductsEvent` with the *
  *current** value of the other control.
- Filter: `title.contains(query)` AND `price <= maxPrice`.

### Product detail

- Hero image, category chip, title, `RatingBadge`, description.
- Fixed bottom bar: price + **Add to Cart** or full-width quantity selector.

### Cart

- Line items show unit price, line total, quantity selector, remove (×).
- Summary: total amount, item count, **Checkout** clears everything.

---

## Persistence

| Key                  | Content                                 |
|----------------------|-----------------------------------------|
| `favourite_products` | `StringList` of JSON-encoded `Product`  |
| `cart_products`      | `StringList` of JSON-encoded `CartItem` |

**Safe parsing:** `price` and `rating.rate` use `num → double` casting to avoid runtime parse
crashes.

> Local cart/favourites JSON is **your app’s format**, not the API’s. It only breaks if you change
> `Product.toJson()` / `fromJson()` without a migration.

---

## API Contract & Response Changes

### What the app expects today (Fake Store API)

**Request:** `GET https://fakestoreapi.com/products`

**Response:** HTTP `200` with a **JSON array** at the root (not wrapped in `{ "data": [...] }`).

```json
[
  {
    "id": 1,
    "title": "…",
    "price": 109.95,
    "description": "…",
    "category": "…",
    "image": "https://…",
    "rating": { "rate": 3.9, "count": 120 }
  }
]
```

Parsing lives in `product_model.dart` (`Product.fromJson`, `Rating.fromJson`) and
`product_repository.dart` (`fetchProducts`).

### If the API or response structure changes

| Change | What happens now | What you should do |
|--------|------------------|-------------------|
| **URL / method changes** | Request fails or 404 → `ProductRepositoryException` → Home shows error + Retry | Update `_productsUrl` in `product_repository.dart` |
| **Non-200 status** | Same error path (generic message) | Map status codes to clearer messages in repository |
| **Root is object instead of array** e.g. `{ "products": [...] }` | `as List<dynamic>` **throws** → Bloc shows *"Something went wrong…"* | Parse wrapper: `json['products'] as List` |
| **Field renamed** e.g. `name` instead of `title` | `as String` on missing key → **crash at parse** | Update `fromJson` keys (or add fallbacks: `json['title'] ?? json['name']`) |
| **Field removed** e.g. no `rating` | `Rating.fromJson` throws | Default rating or make `rating` nullable in model + UI |
| **Type change** e.g. `id` as String | `as int` throws | Use safe parser: `int.tryParse(json['id'].toString())` |
| **`price` / `rate` as String** | Partially OK (`_toDouble` parses string); `as int` elsewhere may still fail | Extend safe helpers for all numeric fields |
| **Extra fields** | Ignored (no problem) | Nothing required |
| **Empty array `[]`** | App loads with empty catalog | OK by design |
| **Invalid JSON** | `json.decode` throws → generic failure | Catch `FormatException`, show “Invalid server response” |

### What does **not** break when only the API changes

- **Cart** and **favourites** on disk — stored with `toJson()` from your models, not raw API bodies.
- **BLoC / UI** — unchanged as long as `Product` and `CartItem` stay the same shape internally.

### Where to edit (checklist)

1. `lib/data/repositories/product_repository.dart` — URL, status handling, unwrap response envelope.
2. `lib/data/models/product_model.dart` — field names, types, defaults, nullable fields.
3. Run `flutter analyze` and test with a real response (or mock JSON file).

### Hardening options (recommended for production)

- **DTO layer:** `ProductDto.fromJson(apiMap)` → `toDomain()` so API shape ≠ app model.
- **`json_serializable` + `@JsonKey`:** code-gen when schema is stable but versioned.
- **Versioned prefs:** `cart_products_v2` if local `Product` JSON changes.
- **Contract tests:** commit a sample `fixtures/products.json` and unit-test `fromJson`.

### User-visible behaviour today

```
API OK + valid JSON  →  Home grid loads
API error / bad JSON →  ProductStatus.failure + Retry on Home
Cart / Favourites    →  Still load from SharedPreferences (independent of API)
```

---

## Getting Started

### Prerequisites

- Flutter SDK (stable, 3.x+)
- Android Studio / VS Code with Flutter extension

### Run

```bash
git clone <your-repo-url>
cd e_com_app
flutter pub get
flutter run
```

### Analyze & test

```bash
flutter analyze
flutter test
```

### Build release APK

```bash
flutter build apk --release
```

> **Note:** Requires internet on first load to fetch the product catalog.

---

## App Analysis

### Strengths

1. **Clear separation of concerns** — data, logic, and UI live in dedicated folders.
2. **Predictable state** — one bloc, immutable `ProductState`, explicit events.
3. **Offline cart & favourites** — survives process death and cold starts.
4. **Quantity-aware cart** — single source of truth; UI stays in sync
   via `BlocBuilder` + `buildWhen` where needed.
5. **Polished UX** — context-aware controls on grid and detail reduce navigation friction.
6. **Defensive JSON** — handles `int`/`double` from API for numeric fields.
7. **Backward-compatible storage** — old cart format migrates without user action.

### Trade-offs & possible extensions

| Topic           | Current choice           | Future idea                           |
|-----------------|--------------------------|---------------------------------------|
| State scope     | One global `ProductBloc` | Split cart/catalog blocs if app grows |
| API errors      | Generic user message     | Typed failures, retry with backoff    |
| Cart duplicates | One line per product ID  | Variants/SKUs would need model change |
| Images          | `Image.network` only     | `cached_network_image`, placeholders  |
| Auth / orders   | Not implemented          | Fake Store has no real checkout API   |
| Tests           | Smoke widget test        | Bloc unit tests + repository mocks    |

### File responsibility map

| File                                        | Responsibility                                 |
|---------------------------------------------|------------------------------------------------|
| `product_model.dart`                        | Domain models + JSON serialization             |
| `product_repository.dart`                   | API + prefs read/write/clear                   |
| `product_bloc.dart`                         | All business rules and persistence triggers    |
| `product_event.dart` / `product_state.dart` | Bloc contract                                  |
| `product_card.dart`                         | Grid tile + cart/favourite interactions        |
| `cart_quantity_selector.dart`               | Reusable −/count/+ control (compact & regular) |
| `product_detail_screen.dart`                | Full product view + bottom action              |
| `main_navigation_screen.dart`               | Tab shell + initial load event                 |
| `app_theme.dart`                            | Global Material 3 styling                      |

### Quality checklist

- [x] BLoC pattern
- [x] SharedPreferences persistence
- [x] Fake Store API integration
- [x] Material 3 bordered UI
- [x] Hero transitions
- [x] Combined search filters
- [x] Cart quantity increment/decrement
- [x] Checkout wipes storage
- [x] Zero template comments in `lib/`
- [x] `flutter analyze` clean

---

## AI Reproduction Prompt

Copy everything inside the block below and paste it into Cursor, ChatGPT, Claude, or any coding AI
to regenerate this application from scratch.

````
Act as a Staff Flutter Developer. Build a production-ready, highly polished, modular E-commerce Flutter app using the BLoC pattern and SharedPreferences.

CRITICAL: Code must look human-written. NO template comments (e.g. "// Fetch products", "// States"), NO placeholders, NO AI boilerplate. Self-documenting names only. Zero comments in all Dart files under lib/.

---

## 1. API & Data Layer

- Endpoint: https://fakestoreapi.com/products
- Models in `lib/data/models/product_model.dart`:
  - `Product`: id, title, price, description, category, image, rating
  - `Rating`: rate, count
  - `CartItem`: product + quantity, with `lineTotal` getter
- Safe `num` → `double` casting for `price` and `rating.rate` (and int for count) to prevent parse crashes
- Repository `lib/data/repositories/product_repository.dart`:
  - `fetchProducts()`, `saveFavourites` / `loadFavourites`, `saveCart` / `loadCart`, `clearCart`
  - Cart persistence stores `{ "product": {...}, "quantity": n }` per entry
  - On load, migrate legacy cart entries (product-only JSON) as quantity 1 and merge duplicate product IDs

SharedPreferences keys:
- `favourite_products` → List<String> of Product JSON
- `cart_products` → List<String> of CartItem JSON

---

## 2. BLoC (`lib/logic/bloc/`)

Files: `product_bloc.dart`, `product_event.dart`, `product_state.dart`

**ProductStatus:** initial, loading, success, failure

**ProductState fields:**
- allProducts, filteredProducts, favouriteProducts, cartItems (List<CartItem>)
- searchQuery, maxPriceFilter, catalogMaxPrice, errorMessage

**Helpers:** `isFavourite(id)`, `cartQuantity(id)`, `isInCart(id)`, `cartTotal`, `cartItemCount`

**Events:**
- LoadProductsEvent — fetch API + rehydrate favourites & cart; set catalogMaxPrice and maxPriceFilter from catalog max price
- ToggleFavouriteEvent — toggle + persist favourites immediately
- AddToCartEvent — add CartItem qty 1 if not in cart
- IncrementCartQuantityEvent — qty + 1
- DecrementCartQuantityEvent — qty - 1, remove line at 0
- RemoveFromCartEvent — remove entire line
- FilterProductsEvent(query, maxPrice) — filter allProducts where title contains query (case-insensitive) AND price <= maxPrice; update filteredProducts
- CheckoutCartEvent — repository.clearCart() + emit empty cartItems

Persist cart and favourites on every mutation before emit.

---

## 3. App Entry & Theme

- `lib/main.dart`: WidgetsFlutterBinding.ensureInitialized(), RepositoryProvider(ProductRepository), BlocProvider(ProductBloc), MaterialApp with AppTheme
- `lib/core/theme/app_theme.dart`: Material 3, ColorScheme.fromSeed(#5C4DFF), scaffold #F8F7FC, card elevation 0 with outline borders, radius 12–16px, styled inputs and NavigationBar

---

## 4. Navigation

`lib/presentation/screens/main_navigation_screen.dart`:
- StatefulWidget, initState dispatches LoadProductsEvent
- IndexedStack with 4 children: Home, Search, Cart, Favourite
- Material 3 NavigationBar (not legacy BottomNavigationBar)

---

## 5. Screens

### home_screen.dart
- AppBar "Discover"
- BlocBuilder: loading, error with retry, empty, or GridView 2 columns (childAspectRatio ~0.52)
- ProductCard per item with isFavourite from state

### search_screen.dart
- TextField: onChanged → FilterProductsEvent(query, state.maxPriceFilter)
- Slider: min 0, max catalogMaxPrice, onChanged → FilterProductsEvent(state.searchQuery, value)
- GridView of filteredProducts (same ProductCard)

### cart_screen.dart
- Empty state with icon
- List of cart lines: image, title, unit price, line total (price × qty), remove button, CartQuantitySelector
- Bottom bar: total, item count, Checkout → CheckoutCartEvent + snackbar

### favourite_screen.dart
- Grid of favourite ProductCards (isFavourite: true)

### product_detail_screen.dart
- Hero image tag: `product-image-{id}` (must match ProductCard)
- Category chip, title, RatingBadge, description
- Favourite toggle in app bar
- Fixed bottom bar: price + Add to Cart OR CartQuantitySelector (regular size) based on cartQuantity

---

## 6. Widgets

### product_card.dart
- Bordered Material card (no heavy shadow)
- Heart toggles ToggleFavouriteEvent
- BlocBuilder on cart quantity: if 0 → compact FilledButton "Add to Cart"; else CartQuantitySelector compact
- Tap image/title navigates to ProductDetailScreen (PageRouteBuilder fade)
- showCartActions parameter (default true)

### cart_quantity_selector.dart
- Sizes: compact (grid cards), regular (detail/cart)
- Minus → DecrementCartQuantityEvent, Plus → IncrementCartQuantityEvent, center shows quantity

### rating_badge.dart
- Star icon + rate (1 decimal) + (count)

---

## 7. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_bloc:
  shared_preferences:
  http:
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

---

## 8. UX Rules

- Material 3, subtle BorderSide instead of elevated card shadows
- Sophisticated spacing, typography (w600–w700 titles)
- Hero animation from grid image to detail image
- Cart controls on Home cards must NOT trigger navigation (separate tap targets)
- Search filters must work together in real time
- Checkout must clear both Bloc state AND SharedPreferences cart key

---

## 9. Deliverables Checklist

Ensure these exact files exist with complete implementations:
- product_model.dart
- product_repository.dart
- product_bloc.dart, product_event.dart, product_state.dart
- product_card.dart, cart_quantity_selector.dart, rating_badge.dart
- main_navigation_screen.dart, home_screen.dart, search_screen.dart, cart_screen.dart, favourite_screen.dart, product_detail_screen.dart
- app_theme.dart, main.dart

Run `flutter analyze` with zero issues. Add a minimal widget_test that pumps StoreApp and finds navigation labels.
````

---

## License

This project is for learning and portfolio use. Product data
© [Fake Store API](https://fakestoreapi.com).
