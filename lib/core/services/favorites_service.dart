import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/product.dart';

class FavoritesService {
  static const String _keyFavorites = 'favorite_products';

  /// Salva um produto nos favoritos
  static Future<bool> addFavorite(Product product) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();
      
      // Verificar se já está nos favoritos
      if (favorites.any((p) => p.id == product.id)) {
        return false; // Já está nos favoritos
      }
      
      favorites.add(product);
      final jsonList = favorites.map((p) => _productToJson(p)).toList();
      final success = await prefs.setString(_keyFavorites, jsonEncode(jsonList));
      
      debugPrint('=== FavoritesService: Product ${product.id} added to favorites ===');
      return success;
    } catch (e) {
      debugPrint('=== FavoritesService: Error adding favorite: $e ===');
      return false;
    }
  }

  /// Remove um produto dos favoritos
  static Future<bool> removeFavorite(String productId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();
      
      favorites.removeWhere((p) => p.id == productId);
      final jsonList = favorites.map((p) => _productToJson(p)).toList();
      final success = await prefs.setString(_keyFavorites, jsonEncode(jsonList));
      
      debugPrint('=== FavoritesService: Product $productId removed from favorites ===');
      return success;
    } catch (e) {
      debugPrint('=== FavoritesService: Error removing favorite: $e ===');
      return false;
    }
  }

  /// Verifica se um produto está nos favoritos
  static Future<bool> isFavorite(String productId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((p) => p.id == productId);
    } catch (e) {
      debugPrint('=== FavoritesService: Error checking favorite: $e ===');
      return false;
    }
  }

  /// Obtém todos os produtos favoritos
  static Future<List<Product>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyFavorites);
      
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => _productFromJson(json)).toList();
    } catch (e) {
      debugPrint('=== FavoritesService: Error getting favorites: $e ===');
      return [];
    }
  }

  /// Limpa todos os favoritos
  static Future<bool> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyFavorites);
    } catch (e) {
      debugPrint('=== FavoritesService: Error clearing favorites: $e ===');
      return false;
    }
  }

  // Helper para converter Product para JSON
  static Map<String, dynamic> _productToJson(Product product) {
    return {
      'id': product.id,
      'externalId': product.externalId,
      'affiliateSource': product.affiliateSource,
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'currency': product.currency,
      'category': product.category,
      'imageUrl': product.imageUrl,
      'productUrlBase': product.productUrlBase,
      'affiliateUrl': product.affiliateUrl,
      'rating': product.rating,
      'reviewCount': product.reviewCount,
      'tags': product.tags,
    };
  }

  // Helper para converter JSON para Product
  static Product _productFromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      externalId: json['externalId'] as String,
      affiliateSource: json['affiliateSource'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      productUrlBase: json['productUrlBase'] as String,
      affiliateUrl: json['affiliateUrl'] as String,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['reviewCount'] as int?,
      tags: List<String>.from(json['tags'] as List),
    );
  }
}



