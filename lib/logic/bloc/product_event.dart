import '../../data/models/product_model.dart';

sealed class ProductEvent {}

final class LoadProductsEvent extends ProductEvent {}

final class ToggleFavouriteEvent extends ProductEvent {
  final Product product;
  ToggleFavouriteEvent(this.product);
}

final class AddToCartEvent extends ProductEvent {
  final Product product;
  AddToCartEvent(this.product);
}

final class IncrementCartQuantityEvent extends ProductEvent {
  final Product product;
  IncrementCartQuantityEvent(this.product);
}

final class DecrementCartQuantityEvent extends ProductEvent {
  final Product product;
  DecrementCartQuantityEvent(this.product);
}

final class RemoveFromCartEvent extends ProductEvent {
  final Product product;
  RemoveFromCartEvent(this.product);
}

final class FilterProductsEvent extends ProductEvent {
  final String query;
  final double maxPrice;
  FilterProductsEvent({required this.query, required this.maxPrice});
}

final class CheckoutCartEvent extends ProductEvent {}
