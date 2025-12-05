import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/favorites_service.dart';
import '../../core/services/search_history_service.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/gift_suggestion.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/top_nav_bar.dart';
import '../../data/mock/mock_data_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/affiliate_store_service.dart';
import '../../domain/entities/affiliate_store.dart';

class SuggestionsPage extends StatefulWidget {
  final String? query;
  final bool isSelfGift;
  final double minPrice;
  final double maxPrice;
  final List<String> giftTypes;
  final String? relationType;
  final String? occasion;

  const SuggestionsPage({
    super.key,
    this.query,
    this.isSelfGift = false,
    this.minPrice = 0.0,
    this.maxPrice = 1000.0,
    this.giftTypes = const [],
    this.relationType,
    this.occasion,
  });

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final MockDataService _mockService = MockDataService();
  final ScrollController _scrollController = ScrollController();
  List<GiftSuggestion> _suggestions = [];
  List<GiftSuggestion> _allSuggestions = [];
  List<GiftSuggestion> _displayedSuggestions = []; // Produtos exibidos (paginação)
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMoreItems = true;
  int _currentPage = 0;
  static const int _itemsPerPage = 16;
  String _sortBy = 'relevance';
  final TextEditingController _searchController = TextEditingController();
  
  // Filtros
  double _filterMinPrice = 0.0;
  double _filterMaxPrice = 1000.0;
  final Set<String> _selectedGiftTypes = {};
  final Set<String> _selectedStores = {};
  double? _minRating;
  
  // Lojas cadastradas (carregadas dinamicamente)
  List<AffiliateStore> _availableStores = [];

  @override
  void initState() {
    super.initState();
    _filterMinPrice = widget.minPrice;
    _filterMaxPrice = widget.maxPrice;
    _selectedGiftTypes.addAll(widget.giftTypes);
    _searchController.text = widget.query ?? '';
    _scrollController.addListener(_onScroll);
    _loadStores();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Listener para detectar quando chegou ao final da lista
  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Quando está a 200px do final, carregar mais
      _loadMoreSuggestions();
    }
  }
  
  /// Carrega as lojas cadastradas na área admin (apenas ativas)
  Future<void> _loadStores() async {
    try {
      // getActiveStores() já retorna apenas lojas ativas
      final activeStores = await AffiliateStoreService.getActiveStores();
      
      if (mounted) {
        setState(() {
          _availableStores = activeStores;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar lojas: $e');
      if (mounted) {
        setState(() {
          _availableStores = [];
        });
      }
    }
  }


  void _performNewSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite algo para buscar'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    // Salvar no histórico
    await SearchHistoryService.saveSearch(
      query: query,
      isSelfGift: widget.isSelfGift,
      minPrice: _filterMinPrice,
      maxPrice: _filterMaxPrice,
      giftTypes: _selectedGiftTypes.toList(),
    );
    
    // Construir URL com parâmetros
    final uri = Uri(
      path: '/suggestions',
      queryParameters: {
        'query': query,
        'isSelfGift': widget.isSelfGift.toString(),
        'minPrice': _filterMinPrice.toString(),
        'maxPrice': _filterMaxPrice.toString(),
        if (_selectedGiftTypes.isNotEmpty)
          'giftTypes': _selectedGiftTypes.join(','),
      },
    );
    
    // Navegar diretamente para suggestions com os novos parâmetros
    context.go(uri.toString());
  }

  @override
  void didUpdateWidget(SuggestionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recarregar se os parâmetros mudaram
    if (oldWidget.query != widget.query ||
        oldWidget.minPrice != widget.minPrice ||
        oldWidget.maxPrice != widget.maxPrice ||
        oldWidget.giftTypes.toString() != widget.giftTypes.toString()) {
      _loadSuggestions();
    }
  }

  Future<void> _loadSuggestions() async {
    try {
      setState(() => _isLoading = true);
      // Simular delay de API
      await Future.delayed(const Duration(seconds: 1));
      final suggestions = await _mockService.getGiftSuggestions(query: widget.query ?? 'presentes');
      
      // Filtrar sugestões baseado nos parâmetros da pesquisa
      List<GiftSuggestion> filteredSuggestions = suggestions;
      
      // Filtrar por faixa de preço
      filteredSuggestions = filteredSuggestions.where((s) {
        return s.product.price >= widget.minPrice && 
               s.product.price <= widget.maxPrice;
      }).toList();
      
      // Filtrar por tipos de presente se especificado
      if (widget.giftTypes.isNotEmpty) {
        filteredSuggestions = filteredSuggestions.where((s) {
          return widget.giftTypes.any((type) => 
            s.product.tags.any((tag) => 
              tag.toLowerCase().contains(type.toLowerCase())
            )
          );
        }).toList();
      }
      
      // Garantir que apenas produtos de lojas ativas aparecem
      final activeStores = await AffiliateStoreService.getActiveStores();
      final activeStoreNames = activeStores.map((s) => s.name.toLowerCase()).toSet();
      final activeDisplayNames = activeStores.map((s) => s.displayName.toLowerCase()).toSet();
      
      filteredSuggestions = filteredSuggestions.where((s) {
        final productSource = s.product.affiliateSource.toLowerCase();
        // Verificar correspondência exata ou parcial
        return activeStoreNames.contains(productSource) ||
               activeDisplayNames.contains(productSource) ||
               activeStoreNames.any((storeName) => productSource.contains(storeName)) ||
               activeDisplayNames.any((displayName) => productSource.contains(displayName)) ||
               // Verificação especial para Magazine Luiza
               (productSource.contains('magazine') || productSource.contains('magalu')) &&
               activeStoreNames.any((name) => name.contains('magazine') || name.contains('magalu'));
      }).toList();
      
      if (mounted) {
        setState(() {
          _allSuggestions = filteredSuggestions;
          _applyFilters(); // Aplicar filtros do menu lateral
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar sugestões: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _handleLike(String suggestionId) {
    // TODO: Registrar feedback positivo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Obrigado pelo feedback!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleDislike(String suggestionId) {
    // TODO: Registrar feedback negativo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vamos melhorar as próximas sugestões!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _handleSave(String suggestionId) async {
    final suggestion = _suggestions.firstWhere((s) => s.id == suggestionId);
    final success = await FavoritesService.addFavorite(suggestion.product);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Presente salvo nos favoritos! ❤️'
                : 'Este presente já está nos favoritos',
          ),
          backgroundColor: success ? AppTheme.successColor : AppTheme.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _sortSuggestions() {
    setState(() {
      switch (_sortBy) {
        case 'price_low':
          _suggestions.sort((a, b) => a.product.price.compareTo(b.product.price));
          break;
        case 'price_high':
          _suggestions.sort((a, b) => b.product.price.compareTo(a.product.price));
          break;
        case 'relevance':
        default:
          _suggestions.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
          break;
      }
    });
  }

  void _applyFilters() async {
    // Buscar lojas ativas para garantir que apenas produtos de lojas ativas aparecem
    final activeStores = await AffiliateStoreService.getActiveStores();
    final activeStoreNames = activeStores.map((s) => s.name.toLowerCase()).toSet();
    final activeDisplayNames = activeStores.map((s) => s.displayName.toLowerCase()).toSet();
    
    setState(() {
      _suggestions = _allSuggestions.where((suggestion) {
        // Filtro de lojas ativas (sempre aplicado)
        final productSource = suggestion.product.affiliateSource.toLowerCase();
        final isFromActiveStore = activeStoreNames.contains(productSource) ||
            activeDisplayNames.contains(productSource) ||
            activeStoreNames.any((storeName) => productSource.contains(storeName)) ||
            activeDisplayNames.any((displayName) => productSource.contains(displayName)) ||
            // Verificação especial para Magazine Luiza
            ((productSource.contains('magazine') || productSource.contains('magalu')) &&
             activeStoreNames.any((name) => name.contains('magazine') || name.contains('magalu')));
        
        if (!isFromActiveStore) {
          return false;
        }
        
        // Filtro de preço
        if (suggestion.product.price < _filterMinPrice || 
            suggestion.product.price > _filterMaxPrice) {
          return false;
        }
        
        // Filtro de tipos de presente
        if (_selectedGiftTypes.isNotEmpty) {
          final hasMatchingType = _selectedGiftTypes.any((type) => 
            suggestion.product.tags.any((tag) => 
              tag.toLowerCase().contains(type.toLowerCase())
            )
          );
          if (!hasMatchingType) return false;
        }
        
        // Filtro de lojas (selecionadas pelo usuário)
        // Se lojas selecionadas: mostrar apenas produtos dessas lojas
        if (_selectedStores.isNotEmpty) {
          // Encontrar a loja do produto
          final productStore = _availableStores.firstWhere(
            (store) => store.name.toLowerCase() == suggestion.product.affiliateSource.toLowerCase() ||
                       store.displayName.toLowerCase() == suggestion.product.affiliateSource.toLowerCase(),
            orElse: () => _availableStores.firstWhere(
              (store) => store.name.toLowerCase().replaceAll(' ', '_') == suggestion.product.affiliateSource.toLowerCase(),
              orElse: () => _availableStores.first,
            ),
          );
          
          // Verificar se está selecionada
          if (!_selectedStores.contains(productStore.displayName)) {
            return false;
          }
        }
        
        // Filtro de avaliação
        if (_minRating != null && suggestion.product.rating != null) {
          if (suggestion.product.rating! < _minRating!) return false;
        }
        
        return true;
      }).toList();
      
      _sortSuggestions(); // Aplicar ordenação após filtrar
      // Resetar paginação quando aplicar filtros
      _currentPage = 0;
      _loadPage(0);
    });
  }

  /// Carrega uma página específica de sugestões
  void _loadPage(int page) {
    final startIndex = page * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _suggestions.length);
    
    if (startIndex >= _suggestions.length) {
      _hasMoreItems = false;
      return;
    }
    
    setState(() {
      _displayedSuggestions = _suggestions.sublist(0, endIndex);
      _hasMoreItems = endIndex < _suggestions.length;
    });
  }

  /// Carrega mais sugestões quando chega ao final
  Future<void> _loadMoreSuggestions() async {
    if (_isLoadingMore || !_hasMoreItems) return;
    
    setState(() => _isLoadingMore = true);
    
    // Simular delay de carregamento
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _currentPage++;
        _loadPage(_currentPage);
        _isLoadingMore = false;
      });
    }
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
        return 'Outras';
    }
  }

  List<GiftSuggestion> get _filteredSuggestions {
    return _displayedSuggestions;
  }

  void _showSortDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ordenar por',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 24,
                  ),
            ),
            const SizedBox(height: 20),
            _buildSortOption(context, 'Relevância', 'relevance', Icons.star_rounded),
            _buildSortOption(context, 'Preço: menor primeiro', 'price_low', Icons.arrow_upward_rounded),
            _buildSortOption(context, 'Preço: maior primeiro', 'price_high', Icons.arrow_downward_rounded),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _sortBy = value);
          _sortSuggestions();
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.borderColor,
              width: 1,
            ),
          ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    final crossAxisCount = isWeb ? 4 : 1;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopNavBar(
        currentRoute: '/suggestions',
        searchBar: _buildSearchBar(),
      ),
      drawer: isWeb ? null : _buildMobileDrawer(),
      body: SafeArea(
        child: Row(
          children: [
            // Menu lateral de filtros (apenas no web)
            if (isWeb) _buildFiltersSidebar(),
            
            // Conteúdo principal
            Expanded(
              child: Column(
                children: [
                  // Header com query e filtro de ordenar
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 32 : 16,
                      vertical: 12,
                    ),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Botão de filtros no mobile
                        if (!isWeb)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Scaffold.of(context).openDrawer(),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.filter_list_rounded,
                                  color: AppTheme.primaryColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        // Mostrar query se houver
                        if (widget.query != null && widget.query!.isNotEmpty)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resultados para:',
                                  style: TextStyle(
                                    fontSize: isWeb ? 12 : 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.query!,
                                  style: TextStyle(
                                    fontSize: isWeb ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        // Botão de ordenar
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showSortDialog(context),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.sort_rounded,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Grid de sugestões (4 colunas no web, 1 no mobile)
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredSuggestions.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.search_off,
                                      size: 64,
                                      color: AppTheme.textLight,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhuma sugestão encontrada',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.all(isWeb ? 24 : 16),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: isWeb ? 20 : 16,
                                  mainAxisSpacing: isWeb ? 20 : 16,
                                  childAspectRatio: isWeb ? 0.55 : 1.2,
                                ),
                                itemCount: _filteredSuggestions.length + (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  // Mostrar indicador de carregamento no final
                                  if (index == _filteredSuggestions.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  
                                  final suggestion = _filteredSuggestions[index];
                                  return ProductCard(
                                    product: suggestion.product,
                                    reasonText: suggestion.reasonText,
                                    onLike: () => _handleLike(suggestion.id),
                                    onDislike: () => _handleDislike(suggestion.id),
                                    onSave: () => _handleSave(suggestion.id),
                                    onTap: () {
                                      context.push(
                                        '/product-details?id=${suggestion.product.id}',
                                      );
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isWeb ? null : const BottomNavBar(currentRoute: '/suggestions'),
    );
  }
  
  Widget _buildFiltersSidebar() {
    return Container(
      width: 280,
      color: AppTheme.backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(Icons.tune_rounded, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Filtros',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Faixa de preço
            _buildPriceFilter(),
            const SizedBox(height: 24),
            
            // Tipos de presente
            _buildGiftTypesFilter(),
            const SizedBox(height: 24),
            
            // Lojas
            _buildStoresFilter(),
            const SizedBox(height: 24),
            
            // Avaliação mínima
            _buildRatingFilter(),
            const SizedBox(height: 24),
            
            // Botão limpar filtros
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _filterMinPrice = 0.0;
                    _filterMaxPrice = 1000.0;
                    _selectedGiftTypes.clear();
                    _selectedStores.clear();
                    _minRating = null;
                  });
                  _applyFilters();
                },
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Limpar filtros'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMobileDrawer() {
    return Drawer(
      child: Container(
        color: AppTheme.backgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune_rounded, color: AppTheme.primaryColor, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Filtros',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Filtros (mesmos do web)
              _buildPriceFilter(),
              const SizedBox(height: 24),
              _buildGiftTypesFilter(),
              const SizedBox(height: 24),
              _buildStoresFilter(),
              const SizedBox(height: 24),
              _buildRatingFilter(),
              const SizedBox(height: 24),
              
              // Botão limpar filtros
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _filterMinPrice = 0.0;
                      _filterMaxPrice = 1000.0;
                      _selectedGiftTypes.clear();
                      _selectedStores.clear();
                      _minRating = null;
                    });
                    _applyFilters();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.clear_all_rounded, size: 18),
                  label: const Text('Limpar filtros'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Faixa de preço',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: RangeValues(_filterMinPrice, _filterMaxPrice),
          min: 0,
          max: 1000,
          divisions: 20,
          labels: RangeLabels(
            '${AppConstants.currencySymbol} ${_filterMinPrice.toStringAsFixed(0)}',
            '${AppConstants.currencySymbol} ${_filterMaxPrice.toStringAsFixed(0)}',
          ),
          onChanged: (values) {
            setState(() {
              _filterMinPrice = values.start;
              _filterMaxPrice = values.end;
            });
            _applyFilters();
          },
          activeColor: AppTheme.primaryColor,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${AppConstants.currencySymbol} ${_filterMinPrice.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            Text(
              '${AppConstants.currencySymbol} ${_filterMaxPrice.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildGiftTypesFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de presente',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...AppConstants.giftTypes.map((type) {
          return CheckboxListTile(
            title: Text(type, style: const TextStyle(fontSize: 14)),
            value: _selectedGiftTypes.contains(type),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedGiftTypes.add(type);
                } else {
                  _selectedGiftTypes.remove(type);
                }
              });
              _applyFilters();
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.primaryColor,
          );
        }),
      ],
    );
  }
  
  Widget _buildStoresFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lojas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (_availableStores.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Nenhuma loja ativa cadastrada',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ..._availableStores.map((store) {
            final storeDisplayName = store.displayName;
            return CheckboxListTile(
              title: Text(storeDisplayName, style: const TextStyle(fontSize: 14)),
              value: _selectedStores.contains(storeDisplayName),
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selectedStores.add(storeDisplayName);
                  } else {
                    _selectedStores.remove(storeDisplayName);
                  }
                });
                _applyFilters();
              },
              dense: true,
              contentPadding: EdgeInsets.zero,
              activeColor: AppTheme.primaryColor,
            );
          }),
      ],
    );
  }
  
  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avaliação mínima',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(5, (index) {
          final rating = (index + 1).toDouble();
          return RadioListTile<double?>(
            title: Row(
              children: [
                ...List.generate(index + 1, (_) => Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: AppTheme.accentColor,
                )),
                const SizedBox(width: 4),
                Text('${rating.toStringAsFixed(1)} ou mais', style: const TextStyle(fontSize: 14)),
              ],
            ),
            value: rating,
            groupValue: _minRating,
            onChanged: (value) {
              setState(() {
                _minRating = value;
              });
              _applyFilters();
            },
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.primaryColor,
          );
        }),
        RadioListTile<double?>(
          title: const Text('Todas', style: TextStyle(fontSize: 14)),
          value: null,
          groupValue: _minRating,
          onChanged: (value) {
            setState(() {
              _minRating = null;
            });
            _applyFilters();
          },
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }
  
  Widget _buildSearchBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    
    return Container(
      constraints: BoxConstraints(maxWidth: isWeb ? 400 : double.infinity),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _performNewSearch(),
        decoration: InputDecoration(
          hintText: 'Buscar presentes...',
          hintStyle: TextStyle(
            color: AppTheme.textLight,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                )
              : IconButton(
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  onPressed: _performNewSearch,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 14,
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }
}
