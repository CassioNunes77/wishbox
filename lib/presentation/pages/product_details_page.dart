import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data_service.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/affiliate_store_service.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/bottom_nav_bar.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with SingleTickerProviderStateMixin {
  final MockDataService _mockService = MockDataService();
  Product? _product;
  int _selectedImageIndex = 0;
  bool _isFavorite = false;
  late TabController _tabController;
  final List<String> _imageUrls = []; // Lista de imagens do produto
  String? _affiliateUrl; // URL de afiliado gerada

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProduct();
    _checkFavorite();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final product = await _mockService.getProductById(widget.productId);
    if (product != null) {
      // Buscar loja afiliada e gerar URL
      final store = await AffiliateStoreService.getStoreByName(product.affiliateSource);
      String? affiliateUrl;
      
      if (store != null && store.isActive) {
        // LIMPAR productUrlBase antes de usar (pode vir com /elislecio/ do backend)
        String productUrl = product.productUrlBase;
        
        // Remover o caminho do afiliado do productUrlBase se estiver presente
        try {
          final storeUrlObj = Uri.parse(store.affiliateUrlTemplate);
          final storePath = storeUrlObj.path; // Ex: /elislecio/
          final cleanStorePath = storePath.endsWith('/') 
            ? storePath.substring(0, storePath.length - 1)
            : storePath; // Ex: /elislecio
          
          // Se productUrl é uma URL completa, extrair caminho primeiro
          if (productUrl.startsWith('http://') || productUrl.startsWith('https://')) {
            final urlObj = Uri.parse(productUrl);
            String path = urlObj.path + (urlObj.query.isNotEmpty ? '?${urlObj.query}' : '');
            
            // Remover o caminho do afiliado do início
            if (cleanStorePath.isNotEmpty && path.startsWith(cleanStorePath + '/')) {
              path = path.substring((cleanStorePath + '/').length);
            } else if (path.startsWith(cleanStorePath)) {
              path = path.substring(cleanStorePath.length);
              if (path.startsWith('/')) path = path.substring(1);
            }
            
            // Remover segmento duplicado
            final lastSegment = cleanStorePath.split('/').where((s) => s.isNotEmpty).toList();
            if (lastSegment.isNotEmpty) {
              final segment = lastSegment.last;
              while (path.startsWith('$segment/') || path.startsWith('/$segment/')) {
                path = path.replaceFirst(RegExp(r'^/?$segment/'), '/');
              }
            }
            
            // Reconstruir URL limpa usando o domínio original
            final originalUrl = Uri.parse(productUrl);
            productUrl = '${originalUrl.scheme}://${originalUrl.host}$path';
          }
        } catch (e) {
          // Se falhar, usar productUrl original
        }
        
        print('');
        print('╔═══════════════════════════════════════════════════════════════╗');
        print('║ PRODUCT DETAILS PAGE - Gerando URL de afiliado                ║');
        print('╚═══════════════════════════════════════════════════════════════╝');
        print('📌 Product ID: ${product.id}');
        print('📌 Store Template: ${store.affiliateUrlTemplate}');
        print('🔗 productUrlBase ORIGINAL: ${product.productUrlBase}');
        print('🔗 productUrl LIMPO: $productUrl');
        print('🔧 Chamando store.generateAffiliateUrl()...');
        
        affiliateUrl = store.generateAffiliateUrl(productUrl);
        
        print('✅ URL FINAL GERADA: $affiliateUrl');
        print('╚═══════════════════════════════════════════════════════════════╝');
        print('');
      } else {
        // Fallback para URL padrão
        affiliateUrl = product.affiliateUrl ?? product.productUrlBase;
      }
      
      setState(() {
        _product = product;
        _affiliateUrl = affiliateUrl;
        // Simular múltiplas imagens (na prática viriam da API)
        _imageUrls.add(product.imageUrl);
        for (int i = 1; i < 4; i++) {
          _imageUrls.add(product.imageUrl); // Mesma imagem por enquanto
        }
      });
    }
  }

  Future<void> _checkFavorite() async {
    final isFav = await FavoritesService.isFavorite(widget.productId);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (_product == null) return;

    if (_isFavorite) {
      await FavoritesService.removeFavorite(_product!.id);
      setState(() => _isFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removido dos favoritos'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      final success = await FavoritesService.addFavorite(_product!);
      if (success) {
        setState(() => _isFavorite = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adicionado aos favoritos ❤️'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return Scaffold(
        appBar: TopNavBar(currentRoute: '/product-details'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      appBar: TopNavBar(currentRoute: '/product-details'),
      body: SafeArea(
        child: Column(
          children: [
            // Breadcrumbs
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 40 : 16,
                vertical: 12,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Início', style: TextStyle(fontSize: 12)),
                  ),
                  const Text(' > ', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Presentes', style: TextStyle(fontSize: 12)),
                  ),
                  const Text(' > ', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  Flexible(
                    child: Text(
                      _product!.name,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Layout principal: Miniaturas | Imagem Principal | Informações
                    Container(
                      padding: EdgeInsets.all(isWeb ? 40 : 16),
                      child: isWeb
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Miniaturas à esquerda
                                _buildThumbnailsColumn(),
                                const SizedBox(width: 20),
                                
                                // Imagem principal
                                Expanded(
                                  flex: 2,
                                  child: _buildMainImage(),
                                ),
                                const SizedBox(width: 40),
                                
                                // Informações do produto à direita
                                Expanded(
                                  flex: 1,
                                  child: _buildProductInfo(),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                // Miniaturas (horizontal no mobile)
                                _buildThumbnailsRow(),
                                const SizedBox(height: 16),
                                
                                // Imagem principal
                                _buildMainImage(),
                                const SizedBox(height: 24),
                                
                                // Informações do produto
                                _buildProductInfo(),
                              ],
                            ),
                    ),
                    
                    // Abas de detalhes
                    _buildDetailsTabs(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWeb ? null : const BottomNavBar(currentRoute: '/product-details'),
    );
  }

  Widget _buildThumbnailsColumn() {
    return SizedBox(
      width: 80,
      child: Column(
        children: _imageUrls.asMap().entries.map((entry) {
          final index = entry.key;
          final imageUrl = entry.value;
          final isSelected = index == _selectedImageIndex;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedImageIndex = index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.dividerColor,
                      child: const Icon(Icons.image_outlined),
                    );
                  },
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildThumbnailsRow() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedImageIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedImageIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Image.network(
                  _imageUrls[index],
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: AppTheme.dividerColor,
                      child: const Icon(Icons.image_outlined),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 1,
          child: _imageUrls.isNotEmpty
              ? Image.network(
                  _imageUrls[_selectedImageIndex],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.dividerColor,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 64),
                      ),
                    );
                  },
                )
              : Container(
                  color: AppTheme.dividerColor,
                  child: const Center(
                    child: Icon(Icons.image_outlined, size: 64),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Marca/Loja
        Text(
          _getStoreName(_product!.affiliateSource),
          style: TextStyle(
            fontSize: isWeb ? 14 : 12,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        
        // Nome do produto
        Text(
          _product!.name,
          style: TextStyle(
            fontSize: isWeb ? 24 : 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        
        // Avaliação
        Row(
          children: [
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: (_product!.rating ?? 0) > index
                      ? AppTheme.accentColor
                      : AppTheme.textLight,
                );
              }),
            ),
            const SizedBox(width: 8),
            Text(
              '${_product!.rating?.toStringAsFixed(1) ?? '0'} de 5',
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            if (_product!.reviewCount != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {},
                child: Text(
                  '(${_product!.reviewCount}) Ver avaliações',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        
        // Vendedor
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.store_rounded, size: 20, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Vendido e entregue por ${_getStoreName(_product!.affiliateSource)}',
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Preço
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              AppConstants.currencySymbol,
              style: TextStyle(
                fontSize: isWeb ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            Text(
              ' ${_product!.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isWeb ? 36 : 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Frete grátis
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_shipping_rounded, size: 16, color: AppTheme.successColor),
              const SizedBox(width: 6),
              Text(
                'Frete Grátis*',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Status de disponibilidade
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warningColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.warningColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Produto Disponível',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warningColor,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_affiliateUrl != null && _affiliateUrl!.isNotEmpty) {
                      try {
                        final uri = Uri.parse(_affiliateUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Não foi possível abrir o link'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erro ao abrir link: $e'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      }
                    } else {
                      // Tentar usar productUrlBase como fallback
                      final fallbackUrl = _product?.productUrlBase ?? _product?.affiliateUrl;
                      if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
                        try {
                          final uri = Uri.parse(fallbackUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Link não disponível'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Link de afiliado não disponível'),
                              backgroundColor: AppTheme.errorColor,
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.shopping_bag_rounded),
                  label: const Text('Ver na loja'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Botão favoritos
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _toggleFavorite,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            label: Text(
              _isFavorite ? 'Remover dos Favoritos' : 'Adicionar aos Favoritos',
              style: TextStyle(
                color: _isFavorite ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: _isFavorite ? AppTheme.primaryColor : AppTheme.borderColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primaryColor,
            tabs: const [
              Tab(text: 'DETALHES DO PRODUTO'),
              Tab(text: 'INFORMAÇÕES'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductDetailsTab(),
                _buildInformationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Categoria', _product!.category),
          const SizedBox(height: 12),
          _buildDetailRow('Tags', _product!.tags.join(', ')),
          const SizedBox(height: 12),
          _buildDetailRow('Loja', _getStoreName(_product!.affiliateSource)),
          const SizedBox(height: 12),
          _buildDetailRow('Preço', '${AppConstants.currencySymbol} ${_product!.price.toStringAsFixed(2)}'),
          if (_product!.rating != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow('Avaliação', '${_product!.rating!.toStringAsFixed(1)} de 5'),
          ],
        ],
      ),
    );
  }

  Widget _buildInformationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descrição',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _product!.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Informações Adicionais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('ID do Produto', _product!.id),
          const SizedBox(height: 12),
          _buildDetailRow('Fonte', _product!.affiliateSource),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  String _getStoreName(String source) {
    switch (source) {
      case 'amazon':
        return 'Amazon';
      case 'mercado_livre':
        return 'Mercado Livre';
      case 'shopee':
        return 'Shopee';
      case 'aliexpress':
        return 'AliExpress';
      default:
        return 'Loja';
    }
  }
}
