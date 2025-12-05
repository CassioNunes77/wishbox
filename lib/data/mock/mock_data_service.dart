import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/gift_suggestion.dart';
import '../../domain/entities/gift_search_session.dart';
import '../../domain/entities/recipient_profile.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/affiliate_store_service.dart';
import '../../core/services/magazine_luiza_api_service.dart';

class MockDataService {
  // NOTA: Produtos mockados pré-definidos REMOVIDOS
  // A partir de agora, apenas produtos reais das lojas afiliadas serão exibidos

  // Produtos mockados filtrados por lojas ativas - DEPRECADO
  @Deprecated('Não usar mais - apenas produtos reais')
  Future<List<Product>> getMockProducts() async {
    // Retornar lista vazia - não usar mais produtos mockados pré-definidos
    return [];
  }

  // Sugestões de presentes - APENAS PRODUTOS REAIS
  Future<List<GiftSuggestion>> getGiftSuggestions({String? query}) async {
    // Debug: verificar query recebida
    debugPrint('=== MockDataService: getGiftSuggestions called with query: "$query" ===');
    
    // Obter todas as lojas ativas
    final activeStores = await AffiliateStoreService.getActiveStores();
    
    // Debug: verificar lojas ativas
    debugPrint('=== MockDataService: Active stores: ${activeStores.map((s) => '${s.name} (${s.displayName}) - Active: ${s.isActive}').toList()} ===');
    
    if (activeStores.isEmpty) {
      debugPrint('=== MockDataService: No active stores found ===');
      return [];
    }
    
    // Gerar produtos REAIS para TODAS as lojas ativas
    final allProducts = <Product>[];
    for (final store in activeStores) {
      debugPrint('=== MockDataService: Processing store: ${store.name} (${store.displayName}) ===');
      
      // Verificar se é Magazine Luiza (várias formas de identificar)
      final isMagazineLuiza = store.name.toLowerCase().contains('magazine') || 
          store.name.toLowerCase().contains('magalu') ||
          store.displayName.toLowerCase().contains('magazine') ||
          store.displayName.toLowerCase().contains('magalu') ||
          store.affiliateUrlTemplate.contains('magazinevoce.com.br') ||
          store.affiliateUrlTemplate.contains('magazineluiza.com.br');
      
      debugPrint('=== MockDataService: Is Magazine Luiza? $isMagazineLuiza ===');
      
      if (isMagazineLuiza) {
        // Buscar produtos da Magazine Luiza
        debugPrint('=== MockDataService: Fetching products from Magazine Luiza ===');
        debugPrint('=== Query: "${query ?? 'presentes'}" ===');
        debugPrint('=== Store affiliate URL: ${store.affiliateUrlTemplate} ===');
        try {
          final realProducts = await MagazineLuizaApiService.searchProducts(
            query: query ?? 'presentes',
            limit: 15,
            affiliateUrl: store.affiliateUrlTemplate,
          );
          debugPrint('=== MockDataService: API returned ${realProducts.length} products ===');
          if (realProducts.isNotEmpty) {
            debugPrint('=== MockDataService: Found ${realProducts.length} products from Magazine Luiza ===');
            for (var product in realProducts) {
              debugPrint('  - Product: ${product.name} (${product.affiliateSource}) - R\$ ${product.price}');
            }
            allProducts.addAll(realProducts);
            continue; // Pular geração mockada padrão
          } else {
            debugPrint('=== MockDataService: No products returned from Magazine Luiza API ===');
          }
        } catch (e, stackTrace) {
          debugPrint('=== MockDataService: Error fetching real products: $e ===');
          debugPrint('=== Stack trace: $stackTrace ===');
        }
      }
      
      // APENAS PRODUTOS REAIS - não gerar produtos mockados
      debugPrint('=== MockDataService: Store ${store.name} não tem API real implementada - pulando ===');
      // Não gerar produtos mockados - apenas produtos reais
    }
    
    debugPrint('=== MockDataService: Total products: ${allProducts.length} ===');
    
    // Priorizar produtos da Magazine Luiza (se houver)
    final magazineLuizaProducts = allProducts.where((p) => 
      p.affiliateSource.toLowerCase().contains('magazine') ||
      p.affiliateSource.toLowerCase().contains('magalu')
    ).toList();
    
    final otherProducts = allProducts.where((p) => 
      !p.affiliateSource.toLowerCase().contains('magazine') &&
      !p.affiliateSource.toLowerCase().contains('magalu')
    ).toList();
    
    // Reordenar: Magazine Luiza primeiro, depois outros
    final sortedProducts = [...magazineLuizaProducts, ...otherProducts].take(30).toList();
    
    debugPrint('=== MockDataService: Magazine Luiza products: ${magazineLuizaProducts.length} ===');
    debugPrint('=== MockDataService: Other products: ${otherProducts.length} ===');
    debugPrint('=== MockDataService: Total sorted: ${sortedProducts.length} ===');
    
    // Criar sugestões com todos os produtos disponíveis
    final suggestions = <GiftSuggestion>[];
    final reasonTexts = [
      'Este produto combina perfeitamente com o perfil pesquisado, oferecendo qualidade e praticidade.',
      'Excelente escolha que atende às preferências e necessidades identificadas.',
      'Produto ideal para o momento e ocasião, com boa relação custo-benefício.',
      'Opção versátil e bem avaliada, perfeita para presentear.',
      'Produto de qualidade que certamente será apreciado pelo destinatário.',
      'Excelente opção que combina funcionalidade e estilo.',
      'Produto cuidadosamente selecionado para atender às expectativas.',
      'Opção premium que oferece valor e satisfação.',
    ];
    
    for (int i = 0; i < sortedProducts.length; i++) {
      final product = sortedProducts[i];
      // Produtos da Magazine Luiza têm relevância maior
      final baseScore = magazineLuizaProducts.contains(product) ? 0.98 : 0.95;
      final relevanceScore = baseScore - (i * 0.02);
      
      suggestions.add(GiftSuggestion(
        id: 'sug-${i + 1}',
        giftSearchSessionId: 'session-1',
        product: product,
        relevanceScore: relevanceScore.clamp(0.5, 1.0),
        reasonText: reasonTexts[i % reasonTexts.length],
        position: i + 1,
      ));
    }
    
    return suggestions;
  }

  // Sessões de busca mockadas
  List<GiftSearchSession> getSearchSessions() {
    return [
      GiftSearchSession(
        id: 'session-1',
        userId: 'user-1',
        recipientProfile: RecipientProfile(
          id: 'profile-1',
          userId: 'user-1',
          isSelfGift: false,
          relationType: 'Namorado(a)',
          ageRange: '26-40 anos',
          gender: 'Feminino',
          occasion: 'Aniversário',
          descriptionRaw: 'Gosta de café, leitura, é caseira, trabalha com tecnologia',
          interests: ['café', 'leitura', 'tecnologia'],
          personalityTags: ['caseira', 'romântica', 'prática'],
          giftStylePriority: 'Romântico',
          constraints: [],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        priceMin: 50.0,
        priceMax: 500.0,
        preferredStores: ['Amazon', 'Mercado Livre'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      GiftSearchSession(
        id: 'session-2',
        userId: 'user-1',
        recipientProfile: RecipientProfile(
          id: 'profile-2',
          userId: 'user-1',
          isSelfGift: true,
          relationType: null,
          ageRange: null,
          gender: null,
          occasion: null,
          descriptionRaw: 'Gosto de tecnologia, jogos, coisas úteis',
          interests: ['tecnologia', 'jogos'],
          personalityTags: ['prático', 'tecnológico'],
          giftStylePriority: 'Tecnológico',
          constraints: [],
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        priceMin: 100.0,
        priceMax: 400.0,
        preferredStores: ['Shopee', 'AliExpress'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  // Buscar produto por ID - busca em todas as lojas ativas
  Future<Product?> getProductById(String id) async {
    try {
      // Buscar em todas as lojas ativas
      final activeStores = await AffiliateStoreService.getActiveStores();
      final allProducts = <Product>[];
      
      for (final store in activeStores) {
        // Verificar se é Magazine Luiza
        final isMagazineLuiza = store.name.toLowerCase().contains('magazine') || 
            store.name.toLowerCase().contains('magalu') ||
            store.affiliateUrlTemplate.contains('magazinevoce.com.br');
        
        if (isMagazineLuiza) {
          try {
            final products = await MagazineLuizaApiService.searchProducts(
              query: 'presentes',
              limit: 50,
              affiliateUrl: store.affiliateUrlTemplate,
            );
            allProducts.addAll(products);
          } catch (e) {
            debugPrint('=== MockDataService: Error fetching products: $e ===');
          }
        } else {
          // APENAS PRODUTOS REAIS - não gerar produtos mockados
          debugPrint('=== MockDataService: Store ${store.name} não tem API real - pulando ===');
        }
      }
      
      return allProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      debugPrint('=== MockDataService: Product not found: $id ===');
      return null;
    }
  }
  
  // REMOVIDO: generateProductsForStore - não gerar mais produtos mockados
  // A partir de agora, apenas produtos reais de APIs serão retornados
  @Deprecated('Removido - não usar mais produtos mockados')
  Future<List<Product>> generateProductsForStore(String storeName, int count) async {
    debugPrint('=== MockDataService: generateProductsForStore REMOVIDO - apenas produtos reais ===');
    return []; // Retornar lista vazia - não gerar produtos mockados
  }
}



