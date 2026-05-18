import '../../data/models/product_model.dart';

abstract class ProductEvent {}

class LoadProductsEvent extends ProductEvent {}

class ToggleFavouriteEvent extends ProductEvent {
  final Product product;
  ToggleFavouriteEvent(this.product);
}

class AddToCartEvent extends ProductEvent {
  final Product product;
  AddToCartEvent(this.product);
}

class RemoveFromCartEvent extends ProductEvent {
  final Product product;
  RemoveFromCartEvent(this.product);
}

class FilterProductsEvent extends ProductEvent {
  final String query;
  final double maxPrice;
  FilterProductsEvent({required this.query, required this.maxPrice});
}

class CheckoutCartEvent extends ProductEvent {}