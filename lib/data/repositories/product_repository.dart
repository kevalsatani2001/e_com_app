import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductRepository {
  final String _apiUrl = "https://fakestoreapi.com/products";
  static const String _favKey = "favourite_products";
  static const String _cartKey = "cart_products";

  // Fetch Products from API
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  // Local Persistence: Favourites
  Future<void> saveFavourites(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encoded = products.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList(_favKey, encoded);
  }

  Future<List<Product>> loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encoded = prefs.getStringList(_favKey);
    if (encoded == null) return [];
    return encoded.map((p) => Product.fromJson(json.decode(p))).toList();
  }

  // Local Persistence: Cart
  Future<void> saveCart(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encoded = products.map((p) => json.encode(p.toJson())).toList();
    await prefs.setStringList(_cartKey, encoded);
  }

  Future<List<Product>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? encoded = prefs.getStringList(_cartKey);
    if (encoded == null) return [];
    return encoded.map((p) => Product.fromJson(json.decode(p))).toList();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}