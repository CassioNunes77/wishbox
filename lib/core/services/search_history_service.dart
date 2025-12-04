import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/gift_search_session.dart';
import '../../domain/entities/recipient_profile.dart';

class SearchHistoryService {
  static const String _keySearchHistory = 'search_history';

  /// Salva uma pesquisa no histórico
  static Future<bool> saveSearch({
    required String query,
    required bool isSelfGift,
    double? minPrice,
    double? maxPrice,
    List<String>? giftTypes,
    String? relationType,
    String? occasion,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_keySearchHistory);
      List<Map<String, dynamic>> history = [];

      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(historyJson);
        history = decodedList.cast<Map<String, dynamic>>();
      }

      // Criar nova entrada de histórico
      final newEntry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'query': query,
        'isSelfGift': isSelfGift,
        'minPrice': minPrice ?? 0.0,
        'maxPrice': maxPrice ?? 1000.0,
        'giftTypes': giftTypes ?? [],
        'relationType': relationType,
        'occasion': occasion,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Adicionar no início da lista
      history.insert(0, newEntry);

      // Limitar a 50 pesquisas mais recentes
      if (history.length > 50) {
        history = history.take(50).toList();
      }

      final success = await prefs.setString(_keySearchHistory, json.encode(history));
      debugPrint('=== SearchHistoryService: Saved search. Success: $success ===');
      return success;
    } catch (e) {
      debugPrint('=== SearchHistoryService: Error saving search: $e ===');
      return false;
    }
  }

  /// Carrega todo o histórico de pesquisas
  static Future<List<Map<String, dynamic>>> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_keySearchHistory);
      
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(historyJson);
        return decodedList.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      debugPrint('=== SearchHistoryService: Error getting search history: $e ===');
      return [];
    }
  }

  /// Remove uma pesquisa do histórico
  static Future<bool> removeSearch(String searchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_keySearchHistory);
      
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(historyJson);
        List<Map<String, dynamic>> history = decodedList.cast<Map<String, dynamic>>();
        
        history.removeWhere((item) => item['id'] == searchId);
        
        final success = await prefs.setString(_keySearchHistory, json.encode(history));
        debugPrint('=== SearchHistoryService: Removed search $searchId. Success: $success ===');
        return success;
      }
      return false;
    } catch (e) {
      debugPrint('=== SearchHistoryService: Error removing search: $e ===');
      return false;
    }
  }

  /// Limpa todo o histórico
  static Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.remove(_keySearchHistory);
      debugPrint('=== SearchHistoryService: Cleared history. Success: $success ===');
      return success;
    } catch (e) {
      debugPrint('=== SearchHistoryService: Error clearing history: $e ===');
      return false;
    }
  }

  /// Converte histórico para GiftSearchSession (compatibilidade)
  static GiftSearchSession? historyToSession(Map<String, dynamic> historyEntry) {
    try {
      return GiftSearchSession(
        id: historyEntry['id'] ?? '',
        userId: 'local_user',
        recipientProfile: RecipientProfile(
          id: 'profile_${historyEntry['id']}',
          userId: 'local_user',
          isSelfGift: historyEntry['isSelfGift'] ?? false,
          relationType: historyEntry['relationType'],
          ageRange: null,
          gender: null,
          occasion: historyEntry['occasion'],
          descriptionRaw: historyEntry['query'] ?? '',
          interests: [],
          personalityTags: [],
          giftStylePriority: 'Geral', // Campo obrigatório
          constraints: [],
          createdAt: DateTime.parse(historyEntry['createdAt'] ?? DateTime.now().toIso8601String()),
        ),
        priceMin: (historyEntry['minPrice'] ?? 0.0).toDouble(),
        priceMax: (historyEntry['maxPrice'] ?? 1000.0).toDouble(),
        preferredStores: [],
        createdAt: DateTime.parse(historyEntry['createdAt'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      debugPrint('=== SearchHistoryService: Error converting to session: $e ===');
      return null;
    }
  }
}

