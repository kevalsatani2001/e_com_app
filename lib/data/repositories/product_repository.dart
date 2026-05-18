import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';

class ProductRepository {
  static const _productsUrl = 'https://fakestoreapi.com/products';
  static const _favouritesKey = 'favourite_products';
  static const _cartKey = 'cart_products';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse(_productsUrl));

    if (response.statusCode != 200) {
      throw ProductRepositoryException('Could not load catalog');
    }

    final data = json.decode(response.body) as List<dynamic>;
    return data
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveFavourites(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        products.map((p) => json.encode(p.toJson())).toList(growable: false);
    await prefs.setStringList(_favouritesKey, encoded);
  }

  Future<List<Product>> loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_favouritesKey);
    if (encoded == null || encoded.isEmpty) return [];
    return encoded
        .map((entry) => Product.fromJson(json.decode(entry) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        items.map((item) => json.encode(item.toJson())).toList(growable: false);
    await prefs.setStringList(_cartKey, encoded);
  }

  Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_cartKey);
    if (encoded == null || encoded.isEmpty) return [];

    final merged = <int, CartItem>{};

    for (final entry in encoded) {
      final map = json.decode(entry) as Map<String, dynamic>;
      final CartItem item;

      if (map.containsKey('product')) {
        item = CartItem.fromJson(map);
      } else {
        item = CartItem(product: Product.fromJson(map), quantity: 1);
      }

      final existing = merged[item.product.id];
      if (existing == null) {
        merged[item.product.id] = item;
      } else {
        merged[item.product.id] = existing.copyWith(
          quantity: existing.quantity + item.quantity,
        );
      }
    }

    return merged.values.toList();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}

class ProductRepositoryException implements Exception {
  final String message;
  const ProductRepositoryException(this.message);

  @override
  String toString() => message;
}
