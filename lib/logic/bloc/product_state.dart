import '../../data/models/product_model.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState {
  final ProductStatus status;
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final List<Product> favouriteProducts;
  final List<Product> cartProducts;
  final String errorMessage;
  final String searchQuery;
  final double maxPriceFilter;

  ProductState({
    this.status = ProductStatus.initial,
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.favouriteProducts = const [],
    this.cartProducts = const [],
    this.errorMessage = '',
    this.searchQuery = '',
    this.maxPriceFilter = 1000.0, // High default limit
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    List<Product>? favouriteProducts,
    List<Product>? cartProducts,
    String? errorMessage,
    String? searchQuery,
    double? maxPriceFilter,
  }) {
    return ProductState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      favouriteProducts: favouriteProducts ?? this.favouriteProducts,
      cartProducts: cartProducts ?? this.cartProducts,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      maxPriceFilter: maxPriceFilter ?? this.maxPriceFilter,
    );
  }
}