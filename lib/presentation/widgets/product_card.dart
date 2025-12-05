import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:html' as html show window;
import '../../domain/entities/product.dart';
import '../../domain/entities/affiliate_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/affiliate_store_service.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final String reasonText;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;
  final VoidCallback? onSave;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.reasonText,
    this.onLike,
    this.onDislike,
    this.onSave,
    this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  bool _isLiked = false;
  bool _isSaved = false;
  String? _storeDisplayName;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _checkIfFavorite();
    _loadStoreName();
  }

  /// Carrega o nome da loja cadastrada na área admin
  Future<void> _loadStoreName() async {
    try {
      final stores = await AffiliateStoreService.getActiveStores();
      if (stores.isEmpty) {
        // Se não houver lojas cadastradas, usar método padrão
        if (mounted) {
          setState(() {
            _storeDisplayName = _getStoreName(widget.product.affiliateSource);
          });
        }
        return;
      }

      // Tentar encontrar a loja pelo nome (affiliateSource)
      AffiliateStore? foundStore;
      
      // Estratégia 1: Buscar por nome exato
      try {
        foundStore = stores.firstWhere(
          (s) => s.name == widget.product.affiliateSource,
        );
      } catch (e) {
        // Estratégia 2: Buscar por nome normalizado
        try {
          foundStore = stores.firstWhere(
            (s) => s.name.toLowerCase().replaceAll(' ', '_') == 
                   widget.product.affiliateSource.toLowerCase(),
          );
        } catch (e2) {
          // Estratégia 3: Buscar por displayName
          try {
            foundStore = stores.firstWhere(
              (s) => s.displayName.toLowerCase() == 
                     widget.product.affiliateSource.toLowerCase(),
            );
          } catch (e3) {
            // Não encontrou, usar método padrão
            foundStore = null;
          }
        }
      }
      
      if (mounted) {
        setState(() {
          _storeDisplayName = foundStore?.displayName ?? 
                             _getStoreName(widget.product.affiliateSource);
        });
      }
    } catch (e) {
      // Se houver qualquer erro, usar o método padrão
      if (mounted) {
        setState(() {
          _storeDisplayName = _getStoreName(widget.product.affiliateSource);
        });
      }
    }
  }

  Future<void> _checkIfFavorite() async {
    final isFavorite = await FavoritesService.isFavorite(widget.product.id);
    if (mounted) {
      setState(() {
        _isSaved = isFavorite;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            constraints: const BoxConstraints(
              minHeight: 0,
              maxHeight: double.infinity,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderColor,
                width: 1,
              ),
              boxShadow: AppTheme.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header com rating e botão salvar
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating
                          if (widget.product.rating != null)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: AppTheme.accentColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        widget.product.rating!
                                            .toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.accentColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          // Botão salvar
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                if (_isSaved) {
                                  await FavoritesService.removeFavorite(widget.product.id);
                                  setState(() => _isSaved = false);
                                } else {
                                  final success = await FavoritesService.addFavorite(widget.product);
                                  if (success) {
                                    setState(() => _isSaved = true);
                                  }
                                }
                                widget.onSave?.call();
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: _isSaved
                                      ? AppTheme.primaryColor.withOpacity(0.1)
                                      : AppTheme.dividerColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _isSaved
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: _isSaved
                                      ? AppTheme.primaryColor
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Imagem do produto
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 160),
                          decoration: BoxDecoration(
                            color: AppTheme.dividerColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Stack(
                            children: [
                              // Sempre tentar exibir imagem, mesmo que seja placeholder
                              _buildProductImage(),
                              // Badge da loja
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceColor.withOpacity(0.95),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: AppTheme.cardShadow,
                                  ),
                                  child: Text(
                                    _storeDisplayName ?? _getStoreName(widget.product.affiliateSource),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nome do produto
                      Text(
                        widget.product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Preço
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppConstants.currencySymbol,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              ' ${widget.product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Tags
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: widget.product.tags.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),

                      // Por que combina
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 14,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Por que combina',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.reasonText,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Botões de ação compactos
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.thumb_up_outlined,
                              label: 'Gostei',
                              isActive: _isLiked,
                              onTap: () {
                                setState(() => _isLiked = !_isLiked);
                                widget.onLike?.call();
                              },
                              color: AppTheme.successColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.thumb_down_outlined,
                              label: 'Não',
                              onTap: widget.onDislike,
                              color: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Botão Ver na loja
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _openProductInStore();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_bag_rounded, size: 16),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Ver na loja',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Constrói a imagem do produto com fallback para placeholder
  Widget _buildProductImage() {
    // Validar URL da imagem
    final imageUrl = widget.product.imageUrl.trim();
    
    // DEBUG: Log completo da URL
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('ProductCard DEBUG - Produto: ${widget.product.name}');
    debugPrint('ProductCard DEBUG - imageUrl original: "${widget.product.imageUrl}"');
    debugPrint('ProductCard DEBUG - imageUrl processada: "$imageUrl"');
    debugPrint('ProductCard DEBUG - imageUrl.isEmpty: ${imageUrl.isEmpty}');
    debugPrint('ProductCard DEBUG - imageUrl.startsWith(http): ${imageUrl.startsWith('http')}');
    debugPrint('ProductCard DEBUG - imageUrl.contains(placeholder): ${imageUrl.contains('placeholder')}');
    debugPrint('═══════════════════════════════════════════════════════');
    
    // Se não houver URL de imagem ou for inválida, usar placeholder
    if (imageUrl.isEmpty) {
      debugPrint('❌ ProductCard: URL de imagem VAZIA');
      return _buildPlaceholderImageWithDebug('URL VAZIA');
    }
    
    if (!imageUrl.startsWith('http')) {
      debugPrint('❌ ProductCard: URL não começa com http: $imageUrl');
      return _buildPlaceholderImageWithDebug('URL INVÁLIDA: $imageUrl');
    }
    
    if (imageUrl.contains('placeholder') || imageUrl.contains('via.placeholder')) {
      debugPrint('❌ ProductCard: URL é placeholder: $imageUrl');
      return _buildPlaceholderImageWithDebug('PLACEHOLDER');
    }

    debugPrint('✅ ProductCard: Tentando carregar imagem: $imageUrl');

    // Tentar carregar a imagem da URL
    // No Flutter Web, Image.network funciona melhor sem headers customizados
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 160,
      cacheWidth: 400, // Otimizar cache para web
      cacheHeight: 300,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('❌ ProductCard: ERRO ao carregar imagem');
        debugPrint('URL: $imageUrl');
        debugPrint('Erro: $error');
        debugPrint('Stack: $stackTrace');
        debugPrint('═══════════════════════════════════════════════════════');
        // Se falhar, mostrar placeholder com informação de erro
        return _buildPlaceholderImageWithDebug('ERRO: ${error.toString().substring(0, error.toString().length > 50 ? 50 : error.toString().length)}');
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          // Imagem carregada com sucesso
          debugPrint('✅ ProductCard: Imagem carregada com SUCESSO: $imageUrl');
          return child;
        }
        
        final progress = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null;
        
        debugPrint('⏳ ProductCard: Carregando imagem... ${progress != null ? (progress * 100).toStringAsFixed(1) : '?'}%');
        
        // Mostrar placeholder enquanto carrega
        return Stack(
          children: [
            _buildPlaceholderImageWithDebug('CARREGANDO...'),
            Center(
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Placeholder com informação de debug
  Widget _buildPlaceholderImageWithDebug(String debugText) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.dividerColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.dividerColor,
            AppTheme.dividerColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_rounded,
            size: 48,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            debugText,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return _buildPlaceholderImageWithDebug('SEM IMAGEM');
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
    bool isActive = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
          child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? color.withOpacity(0.1)
                                  : AppTheme.dividerColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isActive ? color : AppTheme.borderColor,
                                width: 1,
                              ),
                            ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? color : AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? color : AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
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

  /// Abre o produto na loja (usando URL de afiliado se disponível)
  Future<void> _openProductInStore() async {
    try {
      String? url;
      
      // SEMPRE gerar URL de afiliado usando o template da loja (isso garante limpeza de duplicações)
      url = await _generateAffiliateUrl();
      
      // Se não conseguiu gerar, usar affiliateUrl do produto (mas limpar duplicações)
      if (url == null || url.isEmpty) {
        url = widget.product.affiliateUrl;
        if (url != null && url.isNotEmpty) {
          // Buscar template da loja para limpar
          final stores = await AffiliateStoreService.getActiveStores();
          AffiliateStore? store;
          try {
            store = stores.firstWhere(
              (s) => s.name.toLowerCase() == widget.product.affiliateSource.toLowerCase() ||
                     s.displayName.toLowerCase() == widget.product.affiliateSource.toLowerCase(),
            );
            if (store != null) {
              url = _cleanDuplicateUrlSync(url, store.affiliateUrlTemplate);
            }
          } catch (e) {
            // Se não encontrou loja, usar URL original
          }
        }
      }
      
      // Se ainda não tem, usar URL base do produto
      if (url == null || url.isEmpty) {
        url = widget.product.productUrlBase;
      }
      
      // Verificar se temos uma URL válida
      if (url.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Link não disponível para este produto'),
              backgroundColor: AppTheme.errorColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      // Validar e abrir a URL
      final uri = Uri.parse(url);
      
      try {
        if (kIsWeb) {
          // No web, usar window.open diretamente para garantir que funcione
          html.window.open(url, '_blank');
          
          // Feedback positivo
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text('Abrindo na loja...'),
                  ],
                ),
                backgroundColor: AppTheme.successColor,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        } else {
          // No mobile, usar url_launcher
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          
          // Feedback positivo
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text('Abrindo na loja...'),
                  ],
                ),
                backgroundColor: AppTheme.successColor,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Erro ao abrir URL: $e');
        // Se falhar, mostrar mensagem de erro
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Erro ao abrir link'),
                  const SizedBox(height: 4),
                  Text(
                    uri.toString(),
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              backgroundColor: AppTheme.errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao abrir produto na loja: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir link: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Gera a URL de afiliado usando o template da loja cadastrada
  Future<String?> _generateAffiliateUrl() async {
    try {
      final stores = await AffiliateStoreService.getActiveStores();
      if (stores.isEmpty) {
        return null;
      }

      // Buscar a loja correspondente ao produto
      AffiliateStore? store;
      try {
        store = stores.firstWhere(
          (s) => s.name == widget.product.affiliateSource,
        );
      } catch (e) {
        try {
          store = stores.firstWhere(
            (s) => s.name.toLowerCase().replaceAll(' ', '_') == 
                   widget.product.affiliateSource.toLowerCase(),
          );
        } catch (e2) {
          try {
            store = stores.firstWhere(
              (s) => s.displayName.toLowerCase() == 
                     widget.product.affiliateSource.toLowerCase(),
            );
          } catch (e3) {
            // Não encontrou a loja
            return null;
          }
        }
      }

      if (store.affiliateUrlTemplate.isEmpty) {
        return null;
      }

      // Substituir placeholders no template
      String affiliateUrl = store.affiliateUrlTemplate;
      
      // Substituir {productId} pelo ID do produto
      if (affiliateUrl.contains('{productId}')) {
        affiliateUrl = affiliateUrl.replaceAll('{productId}', widget.product.externalId);
      }
      
      // Substituir {productUrl} pela URL base do produto
      if (affiliateUrl.contains('{productUrl}')) {
        final encodedUrl = Uri.encodeComponent(widget.product.productUrlBase);
        affiliateUrl = affiliateUrl.replaceAll('{productUrl}', encodedUrl);
      }
      
      // Se o template não tem placeholders, pode ser que seja apenas um prefixo
      // Nesse caso, adicionar a URL do produto
      if (!affiliateUrl.contains('{') && widget.product.productUrlBase.isNotEmpty) {
        String productUrl = widget.product.productUrlBase.trim();
        
        debugPrint('═══════════════════════════════════════════════════════');
        debugPrint('DEBUG: Gerando URL de afiliado');
        debugPrint('Template: ${store.affiliateUrlTemplate}');
        debugPrint('ProductUrlBase original: $productUrl');
        
        // LÓGICA CORRIGIDA PARA REMOVER DUPLICAÇÕES:
        final templateNormalized = store.affiliateUrlTemplate.trim();
        
        // ETAPA 1: Remover TODAS as ocorrências do template do início do productUrl
        String tempUrl = productUrl;
        int removals = 0;
        while (tempUrl.startsWith(templateNormalized)) {
          tempUrl = tempUrl.substring(templateNormalized.length);
          removals++;
        }
        productUrl = tempUrl;
        if (removals > 0) {
          debugPrint('✅ Removido template $removals vez(es) do início: $productUrl');
        }
        
        // ETAPA 2: Se ainda é URL completa, extrair APENAS o caminho relativo
        if (productUrl.startsWith('http://') || productUrl.startsWith('https://')) {
          try {
            final uri = Uri.parse(productUrl);
            productUrl = uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : '');
            debugPrint('✅ Extraído caminho relativo: $productUrl');
          } catch (e) {
            debugPrint('⚠️ Erro ao parsear URL: $e');
            final match = RegExp(r'https?://[^/]+(/.*)').firstMatch(productUrl);
            if (match != null && match.group(1) != null) {
              productUrl = match.group(1)!;
              debugPrint('✅ Fallback: Extraído caminho: $productUrl');
            }
          }
        }
        
        // ETAPA 3: Remover duplicações do caminho do template
        try {
          final templateUri = Uri.parse(templateNormalized);
          final templatePath = templateUri.path;
          
          // Remover caminho do template se começar com ele
          if (templatePath.isNotEmpty && productUrl.startsWith(templatePath)) {
            productUrl = productUrl.substring(templatePath.length);
            debugPrint('✅ Removido caminho do template: $productUrl');
          }
          
          // Remover segmentos duplicados (ex: "elislecio/elislecio/")
          final templateSegments = templatePath.split('/').where((s) => s.isNotEmpty).toList();
          if (templateSegments.isNotEmpty) {
            final lastSegment = templateSegments.last;
            while (productUrl.startsWith('$lastSegment/') || productUrl.startsWith('/$lastSegment/')) {
              productUrl = productUrl.replaceFirst(RegExp(r'^/?$lastSegment/'), '/');
            }
            if (productUrl.startsWith('//')) {
              productUrl = productUrl.substring(1);
            }
            debugPrint('✅ Removido segmentos duplicados: $productUrl');
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao processar template: $e');
        }
        
        // ETAPA 4: Limpar barras duplicadas e garantir que comece com /
        productUrl = productUrl.replaceAll(RegExp(r'/+'), '/');
        if (productUrl.startsWith('//')) {
          productUrl = productUrl.substring(1);
        }
        if (!productUrl.startsWith('/')) {
          productUrl = '/$productUrl';
        }
        
        // ETAPA 5: Preparar base URL (remover barra final se houver)
        String baseUrl = templateNormalized;
        if (baseUrl.endsWith('/')) {
          baseUrl = baseUrl.substring(0, baseUrl.length - 1);
        }
        
        // ETAPA 6: Concatenar: baseUrl + productUrl
        affiliateUrl = '$baseUrl$productUrl';
        
        debugPrint('✅ URL FINAL GERADA: $affiliateUrl');
        debugPrint('═══════════════════════════════════════════════════════');
      }

      return affiliateUrl;
    } catch (e) {
      debugPrint('⚠️ Erro ao gerar URL de afiliado: $e');
      return null;
    }
  }

  /// Versão síncrona para limpar URL duplicada
  String _cleanDuplicateUrlSync(String url, String template) {
    String cleanUrl = url;
    final templateNormalized = template.trim();
    
    // Remover TODAS as ocorrências do template do início
    while (cleanUrl.startsWith(templateNormalized)) {
      cleanUrl = cleanUrl.substring(templateNormalized.length);
    }
    
    // Se ainda é URL completa, extrair apenas o caminho
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      try {
        final uri = Uri.parse(cleanUrl);
        cleanUrl = uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : '');
      } catch (e) {
        final match = RegExp(r'https?://[^/]+(/.*)').firstMatch(cleanUrl);
        if (match != null && match.group(1) != null) {
          cleanUrl = match.group(1)!;
        }
      }
    }
    
    // Remover duplicações do caminho
    try {
      final templateUri = Uri.parse(templateNormalized);
      final templatePath = templateUri.path;
      if (templatePath.isNotEmpty && cleanUrl.startsWith(templatePath)) {
        cleanUrl = cleanUrl.substring(templatePath.length);
      }
      
      final templateSegments = templatePath.split('/').where((s) => s.isNotEmpty).toList();
      if (templateSegments.isNotEmpty) {
        final lastSegment = templateSegments.last;
        while (cleanUrl.startsWith('$lastSegment/') || cleanUrl.startsWith('/$lastSegment/')) {
          cleanUrl = cleanUrl.replaceFirst(RegExp(r'^/?$lastSegment/'), '/');
        }
      }
    } catch (e) {
      // Ignorar
    }
    
    // Limpar barras e garantir que comece com /
    cleanUrl = cleanUrl.replaceAll(RegExp(r'/+'), '/');
    if (cleanUrl.startsWith('//')) cleanUrl = cleanUrl.substring(1);
    if (!cleanUrl.startsWith('/')) cleanUrl = '/$cleanUrl';
    
    // Preparar base e concatenar
    String baseUrl = templateNormalized;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    
    return '$baseUrl$cleanUrl';
  }
}
