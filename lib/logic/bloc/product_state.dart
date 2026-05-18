import '../../data/models/product_model.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState {
  final ProductStatus status;
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final List<Product> favouriteProducts;
  final List<CartItem> cartItems;
  final String errorMessage;
  final String searchQuery;
  final double maxPriceFilter;
  final double catalogMaxPrice;

  const ProductState({
    this.status = ProductStatus.initial,
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.favouriteProducts = const [],
    this.cartItems = const [],
    this.errorMessage = '',
    this.searchQuery = '',
    this.maxPriceFilter = 0,
    this.catalogMaxPrice = 0,
  });

  bool isFavourite(int productId) =>
      favouriteProducts.any((product) => product.id == productId);

  int cartQuantity(int productId) {
    for (final item in cartItems) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  bool isInCart(int productId) => cartQuantity(productId) > 0;

  double get cartTotal =>
      cartItems.fold<double>(0, (sum, item) => sum + item.lineTotal);

  int get cartItemCount =>
      cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    List<Product>? favouriteProducts,
    List<CartItem>? cartItems,
    String? errorMessage,
    String? searchQuery,
    double? maxPriceFilter,
    double? catalogMaxPrice,
  }) {
    return ProductState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      favouriteProducts: favouriteProducts ?? this.favouriteProducts,
      cartItems: cartItems ?? this.cartItems,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      maxPriceFilter: maxPriceFilter ?? this.maxPriceFilter,
      catalogMaxPrice: catalogMaxPrice ?? this.catalogMaxPrice,
    );
  }
}
