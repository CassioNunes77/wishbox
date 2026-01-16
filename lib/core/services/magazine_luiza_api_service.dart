import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/product.dart';
import '../../core/constants/app_constants.dart';

class MagazineLuizaApiService {
  // Base URL da API da Magazine Luiza
  static const String _baseUrl = 'https://www.magazineluiza.com.br';
  
  /// Busca produtos da Magazine Luiza por termo de busca
  /// Agora usa o backend para fazer scraping (resolve problema de CORS)
  static Future<List<Product>> searchProducts({
    required String query,
    int limit = 20,
    String? affiliateUrl,
  }) async {
    try {
      debugPrint('=== MagazineLuizaApiService: Searching for: $query ===');
      debugPrint('=== MagazineLuizaApiService: Using backend: ${AppConstants.backendBaseUrl} ===');
      
      // Construir URL da API do backend
      final backendUrl = Uri.parse(AppConstants.backendBaseUrl);
      final apiUrl = Uri(
        scheme: backendUrl.scheme,
        host: backendUrl.host,
        port: backendUrl.port,
        path: '/api/search',
        queryParameters: {
          'query': query,
          'limit': limit.toString(),
          if (affiliateUrl != null && affiliateUrl.isNotEmpty) 'affiliateUrl': affiliateUrl,
        },
      );

      debugPrint('=== MagazineLuizaApiService: API URL: $apiUrl ===');

      // Fazer requisição ao backend
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('=== MagazineLuizaApiService: Response status: ${response.statusCode} ===');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonData['success'] == true && jsonData['products'] != null) {
          final productsList = jsonData['products'] as List;
          final products = productsList.map((productJson) {
            return _productFromJson(productJson as Map<String, dynamic>);
          }).toList();
          
          debugPrint('=== MagazineLuizaApiService: Found ${products.length} products ===');
          return products;
        } else {
          debugPrint('=== MagazineLuizaApiService: Backend returned error: ${jsonData['error']} ===');
          return [];
        }
      } else {
        debugPrint('=== MagazineLuizaApiService: HTTP ${response.statusCode} ===');
        debugPrint('=== MagazineLuizaApiService: Response body: ${response.body} ===');
        return [];
      }
    } catch (e) {
      debugPrint('=== MagazineLuizaApiService: Error: $e ===');
      debugPrint('=== MagazineLuizaApiService: Error type: ${e.runtimeType} ===');
      
      // Se o backend não estiver disponível, retornar lista vazia
      // (não tentar fazer scraping direto devido a CORS)
      debugPrint('=== MagazineLuizaApiService: Backend não disponível - verifique se está rodando ===');
      return [];
    }
  }

  /// Converte JSON do backend para objeto Product
  static Product _productFromJson(Map<String, dynamic> json) {
    // Garantir que imageUrl seja uma URL válida
    String imageUrl = json['imageUrl'] as String? ?? '';
    
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('MagazineLuizaApiService DEBUG - Processando produto');
    debugPrint('Nome: ${json['name']}');
    debugPrint('imageUrl original do JSON: "${json['imageUrl']}"');
    debugPrint('imageUrl após conversão: "$imageUrl"');
    
    // Validar e limpar URL da imagem
    if (imageUrl.isNotEmpty) {
      imageUrl = imageUrl.trim();
      
      // Garantir URL completa (adicionar https:// se necessário)
      if (imageUrl.startsWith('//')) {
        imageUrl = 'https:$imageUrl';
        debugPrint('✅ URL corrigida (// -> https:): $imageUrl');
      } else if (imageUrl.startsWith('/')) {
        imageUrl = 'https://www.magazineluiza.com.br$imageUrl';
        debugPrint('✅ URL corrigida (relativa -> absoluta): $imageUrl');
      }
      
      debugPrint('✅ imageUrl final: $imageUrl');
    } else {
      debugPrint('❌ AVISO - imageUrl VAZIA para produto: ${json['name']}');
    }
    debugPrint('═══════════════════════════════════════════════════════');
    
    final product = Product(
      id: json['id'] as String? ?? '',
      externalId: json['externalId'] as String? ?? json['id'] as String? ?? '',
      affiliateSource: json['affiliateSource'] as String? ?? 'magazine_luiza',
      name: json['name'] as String? ?? 'Produto sem nome',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'BRL',
      category: json['category'] as String? ?? 'Geral',
      imageUrl: imageUrl, // Usar URL processada
      productUrlBase: json['productUrlBase'] as String? ?? '',
      affiliateUrl: json['affiliateUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as int?),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
    
    debugPrint('✅ Product criado com imageUrl: ${product.imageUrl}');
    return product;
  }


  /// Gera produtos mockados baseados na query (temporário até ter API real)
  static List<Product> _getMockProductsFromQuery(
    String query,
    int limit,
    String? affiliateUrl,
  ) {
    final products = <Product>[];
    
    // Categorias baseadas na query
    final categories = _extractCategoriesFromQuery(query);
    final productTypes = _extractProductTypesFromQuery(query);
    
    // Lista de produtos reais da Magazine Luiza (exemplos)
    final realProductNames = _getRealProductNames(query);
    
    for (int i = 0; i < limit; i++) {
      final category = categories[i % categories.length];
      final productType = productTypes[i % productTypes.length];
      
      // Usar nome real se disponível, senão gerar
      final productName = i < realProductNames.length 
          ? realProductNames[i]
          : _generateProductName(query, productType, i);
      
      // Preço variado e realista
      final price = _generateRealisticPrice(category, i);
      
      // ID do produto único
      final productId = 'ml_${DateTime.now().millisecondsSinceEpoch}_$i';
      
      // URL do produto - usar link de afiliado se fornecido
      String finalAffiliateUrl;
      if (affiliateUrl != null && affiliateUrl.isNotEmpty) {
        // Se o affiliateUrl contém {productId}, substituir
        if (affiliateUrl.contains('{productId}')) {
          finalAffiliateUrl = affiliateUrl.replaceAll('{productId}', productId);
        } else if (affiliateUrl.contains('{productUrl}')) {
          final productUrl = 'https://www.magazineluiza.com.br/produto/$productId';
          finalAffiliateUrl = affiliateUrl.replaceAll('{productUrl}', productUrl);
        } else {
          // Adicionar produto ao final do link de afiliado
          finalAffiliateUrl = '$affiliateUrl?productId=$productId';
        }
      } else {
        finalAffiliateUrl = 'https://www.magazineluiza.com.br/produto/$productId';
      }
      
      final productUrl = 'https://www.magazineluiza.com.br/produto/$productId';
      
      products.add(Product(
        id: productId,
        externalId: productId,
        affiliateSource: 'magazine_luiza',
        name: productName,
        description: 'Produto exclusivo da Magazine Luiza: $productName. Categoria: $category. Perfeito para presentes especiais e ocasiões importantes.',
        price: price,
        currency: AppConstants.defaultCurrency,
        category: category,
        imageUrl: _generateImageUrl(productName, i),
        productUrlBase: productUrl,
        affiliateUrl: finalAffiliateUrl,
        rating: 4.2 + (i % 8) / 10,
        reviewCount: 100 + (i * 50),
        tags: _generateTagsFromQuery(query),
      ));
    }
    
    return products;
  }
  
  static List<String> _getRealProductNames(String query) {
    final lowerQuery = query.toLowerCase();
    final names = <String>[];
    
    if (lowerQuery.contains('presente') || lowerQuery.contains('gift')) {
      names.addAll([
        'Kit Presente Premium Magazine Luiza',
        'Vale Presente Magazine Luiza',
        'Cesta de Presentes Especial',
        'Box Presente Exclusivo',
        'Kit Premium para Presentear',
      ]);
    } else if (lowerQuery.contains('eletrônico') || lowerQuery.contains('tech')) {
      names.addAll([
        'Smartphone Samsung Galaxy',
        'Fone de Ouvido Bluetooth',
        'Smartwatch Fitness',
        'Tablet Android',
        'Carregador Wireless',
      ]);
    } else if (lowerQuery.contains('casa') || lowerQuery.contains('decoração')) {
      names.addAll([
        'Kit Decoração Casa',
        'Conjunto de Panelas Premium',
        'Kit Utensílios de Cozinha',
        'Decoração Moderna',
        'Kit Organização Casa',
      ]);
    } else if (lowerQuery.contains('moda') || lowerQuery.contains('roupa')) {
      names.addAll([
        'Vestido Feminino Elegante',
        'Kit Moda Masculina',
        'Bolsa Feminina Premium',
        'Tênis Esportivo',
        'Acessórios de Moda',
      ]);
    } else {
      // Produtos gerais populares
      names.addAll([
        'Produto Exclusivo Magazine Luiza',
        'Kit Premium Selecionado',
        'Edição Especial Limitada',
        'Produto em Destaque',
        'Oferta Especial',
        'Kit Completo Premium',
        'Produto Mais Vendido',
        'Novidade Exclusiva',
      ]);
    }
    
    return names;
  }
  
  static double _generateRealisticPrice(String category, int index) {
    // Preços realistas por categoria
    final basePrices = {
      'Eletrônicos': [299.90, 599.90, 899.90, 1299.90, 1999.90],
      'Casa e Cozinha': [89.90, 149.90, 249.90, 399.90, 599.90],
      'Moda': [79.90, 129.90, 199.90, 299.90, 499.90],
      'Livros': [29.90, 49.90, 79.90, 99.90, 149.90],
      'Beleza': [39.90, 69.90, 119.90, 179.90, 249.90],
      'Esportes': [99.90, 199.90, 349.90, 499.90, 799.90],
    };
    
    final prices = basePrices[category] ?? [50.0, 100.0, 200.0, 300.0, 500.0];
    return prices[index % prices.length];
  }
  
  static String _generateImageUrl(String productName, int index) {
    // Usar placeholder melhorado com nome do produto
    final encodedName = Uri.encodeComponent(productName.substring(0, productName.length > 30 ? 30 : productName.length));
    return 'https://via.placeholder.com/400x400/8B5CF6/FFFFFF?text=$encodedName';
  }

  static List<String> _extractCategoriesFromQuery(String query) {
    final lowerQuery = query.toLowerCase();
    if (lowerQuery.contains('eletrônico') || lowerQuery.contains('celular') || lowerQuery.contains('smartphone')) {
      return ['Eletrônicos', 'Celulares', 'Smartphones', 'Tablets'];
    } else if (lowerQuery.contains('casa') || lowerQuery.contains('decoração')) {
      return ['Casa e Decoração', 'Móveis', 'Utilidades Domésticas'];
    } else if (lowerQuery.contains('roupa') || lowerQuery.contains('moda')) {
      return ['Moda', 'Roupas', 'Acessórios'];
    } else if (lowerQuery.contains('livro') || lowerQuery.contains('leitura')) {
      return ['Livros', 'Papelaria'];
    } else if (lowerQuery.contains('beleza') || lowerQuery.contains('perfume')) {
      return ['Beleza', 'Perfumaria', 'Cosméticos'];
    } else {
      return ['Eletrônicos', 'Casa e Cozinha', 'Moda', 'Livros', 'Beleza', 'Esportes'];
    }
  }

  static List<String> _extractProductTypesFromQuery(String query) {
    final lowerQuery = query.toLowerCase();
    final types = <String>[];
    
    if (lowerQuery.contains('kit') || lowerQuery.contains('conjunto')) {
      types.add('Kit');
    }
    if (lowerQuery.contains('premium') || lowerQuery.contains('exclusivo')) {
      types.add('Premium');
    }
    if (lowerQuery.contains('edição') || lowerQuery.contains('especial')) {
      types.add('Edição Especial');
    }
    
    return types.isNotEmpty ? types : ['Produto', 'Item', 'Artigo'];
  }

  static String _generateProductName(String query, String productType, int index) {
    final variations = [
      '$productType $query',
      '$query $productType',
      '$productType relacionado a $query',
      'Produto $query',
    ];
    return variations[index % variations.length];
  }

  static List<String> _generateTagsFromQuery(String query) {
    final lowerQuery = query.toLowerCase();
    final tags = <String>[];
    
    if (lowerQuery.contains('romântico') || lowerQuery.contains('amor')) {
      tags.add('Romântico');
    }
    if (lowerQuery.contains('tecnológico') || lowerQuery.contains('tech')) {
      tags.add('Tecnológico');
    }
    if (lowerQuery.contains('útil') || lowerQuery.contains('prático')) {
      tags.add('Útil');
    }
    if (lowerQuery.contains('divertido') || lowerQuery.contains('diversão')) {
      tags.add('Divertido');
    }
    if (lowerQuery.contains('experiência') || lowerQuery.contains('vivencia')) {
      tags.add('Experiência');
    }
    
    // Tags padrão se não houver match
    if (tags.isEmpty) {
      tags.addAll(['Útil', 'Qualidade']);
    }
    
    return tags;
  }

  /// Busca produtos populares da Magazine Luiza
  static Future<List<Product>> getPopularProducts({
    int limit = 20,
    String? affiliateUrl,
  }) async {
    return searchProducts(
      query: 'presentes',
      limit: limit,
      affiliateUrl: affiliateUrl,
    );
  }
}

