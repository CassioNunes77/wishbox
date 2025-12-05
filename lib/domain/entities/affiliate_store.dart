class AffiliateStore {
  final String id;
  final String name;
  final String displayName;
  final String affiliateUrlTemplate; // Template com {productId} ou similar
  final String apiEndpoint; // Endpoint para buscar produtos (opcional)
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AffiliateStore({
    required this.id,
    required this.name,
    required this.displayName,
    required this.affiliateUrlTemplate,
    this.apiEndpoint = '',
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Gera URL de afiliado para um produto
  String generateAffiliateUrl(String productUrl) {
    print('🔧 AffiliateStore.generateAffiliateUrl INICIANDO');
    print('   Template: $affiliateUrlTemplate');
    print('   ProductUrl input: $productUrl');
    
    // Se o template contém {productUrl}, substitui
    if (affiliateUrlTemplate.contains('{productUrl}')) {
      return affiliateUrlTemplate.replaceAll('{productUrl}', productUrl);
    }
    // Se contém {productId}, precisa do productId (será implementado depois)
    if (affiliateUrlTemplate.contains('{productId}')) {
      // Por enquanto, retorna o template como está
      return affiliateUrlTemplate;
    }
    
    // Remover duplicações do template no início do productUrl
    String cleanProductUrl = productUrl;
    final templateNormalized = affiliateUrlTemplate.trim();
    
    // Remover TODAS as ocorrências do template do início
    int removals = 0;
    while (cleanProductUrl.startsWith(templateNormalized)) {
      cleanProductUrl = cleanProductUrl.substring(templateNormalized.length);
      removals++;
    }
    if (removals > 0) {
      print('   ✅ Removido template $removals vez(es): $cleanProductUrl');
    }
    
    // Se ainda é URL completa, extrair apenas o caminho
    if (cleanProductUrl.startsWith('http://') || cleanProductUrl.startsWith('https://')) {
      print('   🔍 É URL completa, extraindo caminho...');
      try {
        final uri = Uri.parse(cleanProductUrl);
        cleanProductUrl = uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : '');
        print('   ✅ Caminho extraído: $cleanProductUrl');
      } catch (e) {
        final match = RegExp(r'https?://[^/]+(/.*)').firstMatch(cleanProductUrl);
        if (match != null && match.group(1) != null) {
          cleanProductUrl = match.group(1)!;
          print('   ✅ Fallback caminho extraído: $cleanProductUrl');
        }
      }
    }
    
    // Remover duplicações do caminho do template
    try {
      final templateUri = Uri.parse(templateNormalized);
      final templatePath = templateUri.path;
      print('   📂 Template path: $templatePath');
      
      if (templatePath.isNotEmpty && cleanProductUrl.startsWith(templatePath)) {
        cleanProductUrl = cleanProductUrl.substring(templatePath.length);
        print('   ✅ Removido template path: $cleanProductUrl');
      }
      
      // Remover segmentos duplicados
      final templateSegments = templatePath.split('/').where((s) => s.isNotEmpty).toList();
      if (templateSegments.isNotEmpty) {
        final lastSegment = templateSegments.last;
        print('   🔍 Último segmento do template: $lastSegment');
        int segmentRemovals = 0;
        while (cleanProductUrl.startsWith('$lastSegment/') || cleanProductUrl.startsWith('/$lastSegment/')) {
          cleanProductUrl = cleanProductUrl.replaceFirst(RegExp(r'^/?$lastSegment/'), '/');
          segmentRemovals++;
        }
        if (segmentRemovals > 0) {
          print('   ✅ Removido segmento "$lastSegment" $segmentRemovals vez(es): $cleanProductUrl');
        }
      }
    } catch (e) {
      print('   ⚠️ Erro ao processar template path: $e');
    }
    
    // Limpar barras duplicadas e garantir que comece com /
    cleanProductUrl = cleanProductUrl.replaceAll(RegExp(r'/+'), '/');
    if (cleanProductUrl.startsWith('//')) {
      cleanProductUrl = cleanProductUrl.substring(1);
    }
    if (!cleanProductUrl.startsWith('/')) {
      cleanProductUrl = '/$cleanProductUrl';
    }
    
    // Preparar base URL
    String baseUrl = templateNormalized;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    
    // Se é um prefixo com query, adiciona o productUrl
    if (affiliateUrlTemplate.endsWith('?') || affiliateUrlTemplate.endsWith('&')) {
      return '$affiliateUrlTemplate$cleanProductUrl';
    }
    
    // Caso padrão: concatena base + caminho limpo
    final finalUrl = '$baseUrl$cleanProductUrl';
    print('   🎯 URL FINAL: $finalUrl');
    print('🔧 AffiliateStore.generateAffiliateUrl FINALIZADO\n');
    return finalUrl;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'affiliateUrlTemplate': affiliateUrlTemplate,
      'apiEndpoint': apiEndpoint,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory AffiliateStore.fromJson(Map<String, dynamic> json) {
    return AffiliateStore(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      affiliateUrlTemplate: json['affiliateUrlTemplate'] as String,
      apiEndpoint: json['apiEndpoint'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}


