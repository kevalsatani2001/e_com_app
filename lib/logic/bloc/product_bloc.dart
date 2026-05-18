import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/models/product_model.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(ProductState()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<ToggleFavouriteEvent>(_onToggleFavourite);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<FilterProductsEvent>(_onFilterProducts);
    on<CheckoutCartEvent>(_onCheckoutCart);
  }

  Future<void> _onLoadProducts(LoadProductsEvent event, Emitter<ProductState> emit) async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final products = await repository.fetchProducts();
      final favourites = await repository.loadFavourites();
      final cart = await repository.loadCart();

      emit(state.copyWith(
        status: ProductStatus.success,
        allProducts: products,
        filteredProducts: products,
        favouriteProducts: favourites,
        cartProducts: cart,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleFavourite(ToggleFavouriteEvent event, Emitter<ProductState> emit) async {
    final updatedFavs = List<Product>.from(state.favouriteProducts);
    final isFav = updatedFavs.any((p) => p.id == event.product.id);

    if (isFav) {
      updatedFavs.removeWhere((p) => p.id == event.product.id);
    } else {
      updatedFavs.add(event.product);
    }

    await repository.saveFavourites(updatedFavs);
    emit(state.copyWith(favouriteProducts: updatedFavs));
  }

  Future<void> _onAddToCart(AddToCartEvent event, Emitter<ProductState> emit) async {
    final updatedCart = List<Product>.from(state.cartProducts)..add(event.product);
    await repository.saveCart(updatedCart);
    emit(state.copyWith(cartProducts: updatedCart));
  }

  Future<void> _onRemoveFromCart(RemoveFromCartEvent event, Emitter<ProductState> emit) async {
    final updatedCart = List<Product>.from(state.cartProducts);
    updatedCart.removeWhere((p) => p.id == event.product.id);
    await repository.saveCart(updatedCart);
    emit(state.copyWith(cartProducts: updatedCart));
  }

  void _onFilterProducts(FilterProductsEvent event, Emitter<ProductState> emit) {
    final filtered = state.allProducts.where((product) {
      final matchesTitle = product.title.toLowerCase().contains(event.query.toLowerCase());
      final matchesPrice = product.price <= event.maxPrice;
      return matchesTitle && matchesPrice;
    }).toList();

    emit(state.copyWith(
      filteredProducts: filtered,
      searchQuery: event.query,
      maxPriceFilter: event.maxPrice,
    ));
  }

  Future<void> _onCheckoutCart(CheckoutCartEvent event, Emitter<ProductState> emit) async {
    await repository.clearCart();
    emit(state.copyWith(cartProducts: const []));
  }
}