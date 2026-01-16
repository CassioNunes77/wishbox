import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/affiliate_store.dart';

class AffiliateStoreService {
  static const String _keyAffiliateStores = 'affiliate_stores';
  static const String _adminPassword = 'admin123'; // Senha simples para demo

  /// Verifica se a senha do admin está correta
  static Future<bool> verifyAdminPassword(String password) async {
    return password == _adminPassword;
  }

  /// Obtém todas as lojas afiliadas
  static Future<List<AffiliateStore>> getAffiliateStores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? storesJson = prefs.getString(_keyAffiliateStores);

      if (storesJson == null || storesJson.isEmpty) {
        // Retornar lojas padrão
        return _getDefaultStores();
      }

      final List<dynamic> decodedList = json.decode(storesJson);
      return decodedList.map((json) => AffiliateStore.fromJson(json)).toList();
    } catch (e) {
      debugPrint('=== AffiliateStoreService: Error getting stores: $e ===');
      return _getDefaultStores();
    }
  }

  /// Obtém apenas lojas ativas
  static Future<List<AffiliateStore>> getActiveStores() async {
    final allStores = await getAffiliateStores();
    final activeStores = allStores.where((store) => store.isActive).toList();
    debugPrint('=== AffiliateStoreService: Active stores: ${activeStores.map((s) => '${s.name} (${s.displayName})').toList()} ===');
    return activeStores;
  }

  /// Obtém uma loja por ID
  static Future<AffiliateStore?> getStoreById(String id) async {
    final stores = await getAffiliateStores();
    try {
      return stores.firstWhere((store) => store.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtém uma loja por nome (affiliateSource)
  static Future<AffiliateStore?> getStoreByName(String name) async {
    final stores = await getAffiliateStores();
    debugPrint('=== AffiliateStoreService: Searching for store: $name ===');
    debugPrint('=== AffiliateStoreService: Available stores: ${stores.map((s) => '${s.name} (${s.displayName})').toList()} ===');
    try {
      final store = stores.firstWhere((store) => store.name.toLowerCase() == name.toLowerCase());
      debugPrint('=== AffiliateStoreService: Store found: ${store.displayName} (${store.name}) - Active: ${store.isActive} ===');
      return store;
    } catch (e) {
      debugPrint('=== AffiliateStoreService: Store not found: $name ===');
      return null;
    }
  }

  /// Adiciona uma nova loja afiliada
  static Future<bool> addStore(AffiliateStore store) async {
    try {
      final stores = await getAffiliateStores();
      
      // Verificar se já existe
      if (stores.any((s) => s.id == store.id || s.name == store.name)) {
        debugPrint('=== AffiliateStoreService: Store already exists ===');
        return false;
      }

      stores.add(store);
      return await _saveStores(stores);
    } catch (e) {
      debugPrint('=== AffiliateStoreService: Error adding store: $e ===');
      return false;
    }
  }

  /// Atualiza uma loja afiliada
  static Future<bool> updateStore(AffiliateStore updatedStore) async {
    try {
      final stores = await getAffiliateStores();
      final index = stores.indexWhere((s) => s.id == updatedStore.id);
      
      if (index == -1) {
        debugPrint('=== AffiliateStoreService: Store not found ===');
        return false;
      }

      stores[index] = updatedStore;
      return await _saveStores(stores);
    } catch (e) {
      debugPrint('=== AffiliateStoreService: Error updating store: $e ===');
      return false;
    }
  }

  /// Remove uma loja afiliada
  static Future<bool> removeStore(String id) async {
    try {
      final stores = await getAffiliateStores();
      stores.removeWhere((s) => s.id == id);
      return await _saveStores(stores);
    } catch (e) {
      debugPrint('=== AffiliateStoreService: Error removing store: $e ===');
      return false;
    }
  }

  /// Ativa/desativa uma loja
  static Future<bool> toggleStoreStatus(String id) async {
    try {
      final stores = await getAffiliateStores();
      final index = stores.indexWhere((s) => s.id == id);
      
      if (index == -1) return false;

      final store = stores[index];
      final updatedStore = AffiliateStore(
        id: store.id,
        name: store.name,
        displayName: store.displayName,
        affiliateUrlTemplate: store.affiliateUrlTemplate,
        apiEndpoint: store.apiEndpoint,
        isActive: !store.isActive,
        createdAt: store.createdAt,
        updatedAt: DateTime.now(),
      );

      stores[index] = updatedStore;
      return await _saveStores(stores);
    } catch (e) {
      debugPrint('=== AffiliateStoreService: Error toggling store: $e ===');
      return false;
    }
  }

  /// Salva lista de lojas
  static Future<bool> _saveStores(List<AffiliateStore> stores) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = stores.map((store) => store.toJson()).toList();
      return await prefs.setString(_keyAffiliateStores, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('=== AffiliateStoreService: Error saving stores: $e ===');
      return false;
    }
  }

  /// Lojas padrão (para inicialização)
  static List<AffiliateStore> _getDefaultStores() {
    return [
      AffiliateStore(
        id: 'amazon',
        name: 'amazon',
        displayName: 'Amazon',
        affiliateUrlTemplate: 'https://amazon.com.br/dp/{productId}?tag=wishbox-20',
        createdAt: DateTime.now(),
      ),
      AffiliateStore(
        id: 'mercado_livre',
        name: 'mercado_livre',
        displayName: 'Mercado Livre',
        affiliateUrlTemplate: 'https://produto.mercadolivre.com.br/{productId}?matt_tool=wishbox',
        createdAt: DateTime.now(),
      ),
      AffiliateStore(
        id: 'shopee',
        name: 'shopee',
        displayName: 'Shopee',
        affiliateUrlTemplate: 'https://shopee.com.br/product/{productId}?affiliate=wishbox',
        createdAt: DateTime.now(),
      ),
      AffiliateStore(
        id: 'aliexpress',
        name: 'aliexpress',
        displayName: 'AliExpress',
        affiliateUrlTemplate: 'https://pt.aliexpress.com/item/{productId}.html?affiliate=wishbox',
        createdAt: DateTime.now(),
      ),
    ];
  }
}

