import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/favorites_service.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/gift_suggestion.dart';
import '../widgets/product_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../data/mock/mock_data_service.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final MockDataService _mockService = MockDataService();
  List<GiftSuggestion> _suggestions = [];
  bool _isLoading = true;
  String _sortBy = 'relevance';

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      setState(() => _isLoading = true);
      // Simular delay de API
      await Future.delayed(const Duration(seconds: 1));
      final suggestions = await _mockService.getGiftSuggestions();
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
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

  List<GiftSuggestion> get _filteredSuggestions {
    return _suggestions;
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'WishBox',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 20,
            color: AppTheme.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Perfil em breve! 👤'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: Icon(
              Icons.person_outline_rounded,
              color: AppTheme.textPrimary,
              size: 24,
            ),
            tooltip: 'Perfil',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filtro minimalista - apenas ícone de ordenar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 32 : 16,
                vertical: 12,
              ),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                          padding: EdgeInsets.all(isWeb ? 24 : 16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: isWeb ? 20 : 16,
                            mainAxisSpacing: isWeb ? 20 : 16,
                            childAspectRatio: isWeb ? 0.65 : 1.2,
                          ),
                          itemCount: _filteredSuggestions.length,
                          itemBuilder: (context, index) {
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
      bottomNavigationBar: const BottomNavBar(currentRoute: '/suggestions'),
    );
  }
}


