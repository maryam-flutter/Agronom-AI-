import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class Product {
  final String id;
  final String title;
  final String price;
  final String imageUrl;
  final String description;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.description,
  });

  // Map'dan Product yaratish
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? map['title'], // ID bo'lmasa, vaqtinchalik title'dan foydalanamiz
      title: map['title'] ?? '',
      price: map['price'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
    );
  }

  // Product'ni Map'ga o'girish (JSON uchun)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class FavoritesProvider with ChangeNotifier {
  static const _favoritesKey = 'favorite_products';
  List<Product> _favoriteProducts = [];

  List<Product> get favoriteProducts => _favoriteProducts;

  FavoritesProvider() {
    // Provider yaratilishi bilan yoqtirganlarni yuklaymiz
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteListJson = prefs.getStringList(_favoritesKey) ?? [];
    _favoriteProducts = favoriteListJson
        .map((jsonString) => Product.fromMap(jsonDecode(jsonString)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteListJson =
        _favoriteProducts.map((product) => jsonEncode(product.toMap())).toList();
    await prefs.setStringList(_favoritesKey, favoriteListJson);
  }

  bool isFavorite(Product product) {
    return _favoriteProducts.contains(product);
  }

  void toggleFavorite(Product product) {
    if (isFavorite(product)) {
      _favoriteProducts.remove(product);
    } else {
      _favoriteProducts.add(product);
    }
    _saveFavorites();
    notifyListeners();
  }
}