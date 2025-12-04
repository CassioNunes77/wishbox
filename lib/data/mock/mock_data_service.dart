import '../../domain/entities/product.dart';
import '../../domain/entities/gift_suggestion.dart';
import '../../domain/entities/gift_search_session.dart';
import '../../domain/entities/recipient_profile.dart';
import '../../core/constants/app_constants.dart';

class MockDataService {
  // Produtos mockados
  List<Product> getMockProducts() {
    return [
      Product(
        id: '1',
        externalId: 'amz-001',
        affiliateSource: 'amazon',
        name: 'Kit Café Gourmet com Caneca Personalizada',
        description:
            'Kit completo com café especial, caneca de cerâmica personalizada e colher de madeira. Perfeito para quem ama café e momentos de tranquilidade.',
        price: 89.90,
        currency: AppConstants.defaultCurrency,
        category: 'Casa e Cozinha',
        imageUrl: 'https://via.placeholder.com/300x300?text=Kit+Cafe',
        productUrlBase: 'https://amazon.com.br/product/001',
        affiliateUrl: 'https://amazon.com.br/product/001?affiliate=xxx',
        rating: 4.8,
        reviewCount: 234,
        tags: ['Romântico', 'Útil', 'Casa'],
      ),
      Product(
        id: '2',
        externalId: 'ml-002',
        affiliateSource: 'mercado_livre',
        name: 'Livro: Romance Contemporâneo - Edição Especial',
        description:
            'Livro de romance contemporâneo com capa dura e marcador de páginas. Ideal para quem gosta de leitura e histórias emocionantes.',
        price: 45.00,
        currency: AppConstants.defaultCurrency,
        category: 'Livros',
        imageUrl: 'https://via.placeholder.com/300x300?text=Livro',
        productUrlBase: 'https://mercadolivre.com.br/item/002',
        affiliateUrl: 'https://mercadolivre.com.br/item/002?affiliate=xxx',
        rating: 4.6,
        reviewCount: 189,
        tags: ['Romântico', 'Divertido'],
      ),
      Product(
        id: '3',
        externalId: 'shopee-003',
        affiliateSource: 'shopee',
        name: 'Fone de Ouvido Bluetooth com Cancelamento de Ruído',
        description:
            'Fone de ouvido premium com cancelamento ativo de ruído, bateria de longa duração e som de alta qualidade. Perfeito para trabalho e lazer.',
        price: 299.90,
        currency: AppConstants.defaultCurrency,
        category: 'Eletrônicos',
        imageUrl: 'https://via.placeholder.com/300x300?text=Fone',
        productUrlBase: 'https://shopee.com.br/product/003',
        affiliateUrl: 'https://shopee.com.br/product/003?affiliate=xxx',
        rating: 4.9,
        reviewCount: 567,
        tags: ['Tecnológico', 'Útil'],
      ),
      Product(
        id: '4',
        externalId: 'amz-004',
        affiliateSource: 'amazon',
        name: 'Vale-Experiência: Jantar Romântico para 2',
        description:
            'Vale-presente para jantar romântico em restaurante selecionado. Inclui entrada, prato principal e sobremesa para duas pessoas.',
        price: 250.00,
        currency: AppConstants.defaultCurrency,
        category: 'Experiências',
        imageUrl: 'https://via.placeholder.com/300x300?text=Experiencia',
        productUrlBase: 'https://amazon.com.br/experience/004',
        affiliateUrl: 'https://amazon.com.br/experience/004?affiliate=xxx',
        rating: 4.7,
        reviewCount: 123,
        tags: ['Romântico', 'Experiência'],
      ),
      Product(
        id: '5',
        externalId: 'aliexpress-005',
        affiliateSource: 'aliexpress',
        name: 'Kit Plantas Suculentas com Vasos Decorativos',
        description:
            'Kit com 5 plantas suculentas diferentes e vasos de cerâmica decorativos. Ideal para quem gosta de plantas e decoração minimalista.',
        price: 65.00,
        currency: AppConstants.defaultCurrency,
        category: 'Casa e Jardim',
        imageUrl: 'https://via.placeholder.com/300x300?text=Plantas',
        productUrlBase: 'https://aliexpress.com/product/005',
        affiliateUrl: 'https://aliexpress.com/product/005?affiliate=xxx',
        rating: 4.5,
        reviewCount: 89,
        tags: ['Útil', 'Casa'],
      ),
      Product(
        id: '6',
        externalId: 'ml-006',
        affiliateSource: 'mercado_livre',
        name: 'Smartwatch com Monitor de Saúde',
        description:
            'Smartwatch com monitoramento de frequência cardíaca, contador de passos, notificações de smartphone e resistente à água.',
        price: 399.90,
        currency: AppConstants.defaultCurrency,
        category: 'Eletrônicos',
        imageUrl: 'https://via.placeholder.com/300x300?text=Smartwatch',
        productUrlBase: 'https://mercadolivre.com.br/item/006',
        affiliateUrl: 'https://mercadolivre.com.br/item/006?affiliate=xxx',
        rating: 4.8,
        reviewCount: 445,
        tags: ['Tecnológico', 'Útil'],
      ),
    ];
  }

  // Sugestões de presentes mockadas
  Future<List<GiftSuggestion>> getGiftSuggestions() async {
    final products = getMockProducts();
    return [
      GiftSuggestion(
        id: 'sug-1',
        giftSearchSessionId: 'session-1',
        product: products[0],
        relevanceScore: 0.95,
        reasonText:
            'Esse kit café combina perfeitamente porque junta algo útil para o dia a dia com um toque romântico e personalizado, ideal para quem gosta de momentos tranquilos.',
        position: 1,
      ),
      GiftSuggestion(
        id: 'sug-2',
        giftSearchSessionId: 'session-1',
        product: products[1],
        relevanceScore: 0.88,
        reasonText:
            'Este livro é uma excelente escolha para quem aprecia leitura e histórias emocionantes, oferecendo momentos de entretenimento e reflexão.',
        position: 2,
      ),
      GiftSuggestion(
        id: 'sug-3',
        giftSearchSessionId: 'session-1',
        product: products[2],
        relevanceScore: 0.85,
        reasonText:
            'Fone de ouvido premium ideal para quem trabalha com tecnologia e valoriza qualidade de som e praticidade no dia a dia.',
        position: 3,
      ),
      GiftSuggestion(
        id: 'sug-4',
        giftSearchSessionId: 'session-1',
        product: products[3],
        relevanceScore: 0.82,
        reasonText:
            'Uma experiência romântica perfeita para criar memórias especiais, ideal para ocasiões importantes e momentos a dois.',
        position: 4,
      ),
      GiftSuggestion(
        id: 'sug-5',
        giftSearchSessionId: 'session-1',
        product: products[4],
        relevanceScore: 0.78,
        reasonText:
            'Kit de plantas suculentas combina com quem gosta de decoração minimalista e tem interesse em cuidar de plantas.',
        position: 5,
      ),
      GiftSuggestion(
        id: 'sug-6',
        giftSearchSessionId: 'session-1',
        product: products[5],
        relevanceScore: 0.75,
        reasonText:
            'Smartwatch tecnológico e útil para monitorar saúde e atividades, perfeito para quem valoriza tecnologia e bem-estar.',
        position: 6,
      ),
    ];
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

  // Buscar produto por ID
  Product? getProductById(String id) {
    try {
      return getMockProducts().firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}



