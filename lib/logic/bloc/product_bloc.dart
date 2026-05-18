import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc({required this.repository}) : super(const ProductState()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<ToggleFavouriteEvent>(_onToggleFavourite);
    on<AddToCartEvent>(_onAddToCart);
    on<IncrementCartQuantityEvent>(_onIncrementCartQuantity);
    on<DecrementCartQuantityEvent>(_onDecrementCartQuantity);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<FilterProductsEvent>(_onFilterProducts);
    on<CheckoutCartEvent>(_onCheckoutCart);
  }

  final ProductRepository repository;

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final products = await repository.fetchProducts();
      final favourites = await repository.loadFavourites();
      final cart = await repository.loadCart();
      final catalogMaxPrice = _resolveCatalogMaxPrice(products);

      emit(
        state.copyWith(
          status: ProductStatus.success,
          allProducts: products,
          filteredProducts: products,
          favouriteProducts: favourites,
          cartItems: cart,
          catalogMaxPrice: catalogMaxPrice,
          maxPriceFilter: catalogMaxPrice,
        ),
      );
    } on ProductRepositoryException catch (error) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: 'Something went wrong while loading products',
        ),
      );
    }
  }

  Future<void> _onToggleFavourite(
    ToggleFavouriteEvent event,
    Emitter<ProductState> emit,
  ) async {
    final updated = List<Product>.from(state.favouriteProducts);
    final exists = updated.any((product) => product.id == event.product.id);

    if (exists) {
      updated.removeWhere((product) => product.id == event.product.id);
    } else {
      updated.add(event.product);
    }

    await repository.saveFavourites(updated);
    emit(state.copyWith(favouriteProducts: updated));
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (state.isInCart(event.product.id)) return;

    final updated = List<CartItem>.from(state.cartItems)
      ..add(CartItem(product: event.product, quantity: 1));

    await _persistCart(updated, emit);
  }

  Future<void> _onIncrementCartQuantity(
    IncrementCartQuantityEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (!state.isInCart(event.product.id)) return;

    final updated = state.cartItems
        .map(
          (item) => item.product.id == event.product.id
              ? item.copyWith(quantity: item.quantity + 1)
              : item,
        )
        .toList();

    await _persistCart(updated, emit);
  }

  Future<void> _onDecrementCartQuantity(
    DecrementCartQuantityEvent event,
    Emitter<ProductState> emit,
  ) async {
    final existing = state.cartQuantity(event.product.id);
    if (existing <= 0) return;

    final List<CartItem> updated;
    if (existing == 1) {
      updated = state.cartItems
          .where((item) => item.product.id != event.product.id)
          .toList();
    } else {
      updated = state.cartItems
          .map(
            (item) => item.product.id == event.product.id
                ? item.copyWith(quantity: item.quantity - 1)
                : item,
          )
          .toList();
    }

    await _persistCart(updated, emit);
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<ProductState> emit,
  ) async {
    final updated = state.cartItems
        .where((item) => item.product.id != event.product.id)
        .toList();

    await _persistCart(updated, emit);
  }

  void _onFilterProducts(
    FilterProductsEvent event,
    Emitter<ProductState> emit,
  ) {
    final query = event.query.trim().toLowerCase();
    final maxPrice = event.maxPrice;

    final filtered = state.allProducts.where((product) {
      final matchesQuery =
          query.isEmpty || product.title.toLowerCase().contains(query);
      final matchesPrice = product.price <= maxPrice;
      return matchesQuery && matchesPrice;
    }).toList();

    emit(
      state.copyWith(
        filteredProducts: filtered,
        searchQuery: event.query,
        maxPriceFilter: maxPrice,
      ),
    );
  }

  Future<void> _onCheckoutCart(
    CheckoutCartEvent event,
    Emitter<ProductState> emit,
  ) async {
    await repository.clearCart();
    emit(state.copyWith(cartItems: const []));
  }

  Future<void> _persistCart(
    List<CartItem> items,
    Emitter<ProductState> emit,
  ) async {
    await repository.saveCart(items);
    emit(state.copyWith(cartItems: items));
  }

  double _resolveCatalogMaxPrice(List<Product> products) {
    if (products.isEmpty) return 0;
    return products.map((product) => product.price).reduce((a, b) => a > b ? a : b);
  }
}
