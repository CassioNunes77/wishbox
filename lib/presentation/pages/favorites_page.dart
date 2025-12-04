import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/favorites_service.dart';
import '../../domain/entities/product.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/product_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Product> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final favorites = await FavoritesService.getFavorites();
      if (mounted) {
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar favoritos: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(Product product) async {
    final success = await FavoritesService.removeFavorite(product.id);
    if (success && mounted) {
      // Recarregar a lista de favoritos
      await _loadFavorites();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removido dos favoritos ❤️'),
          backgroundColor: AppTheme.primaryColor,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favoritos',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppTheme.textPrimary,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _favorites.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Nenhum favorito ainda',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 20,
                                fontFamily: 'Roboto',
                              ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Salve produtos que você gostou para acessá-los depois',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Roboto',
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => context.go('/home'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Buscar presentes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final product = _favorites[index];
                      return ProductCard(
                        product: product,
                        reasonText: 'Salvo nos seus favoritos ❤️',
                        onLike: () {},
                        onDislike: () {},
                        onSave: () async {
                          await _removeFavorite(product);
                        },
                        onTap: () {
                          context.push(
                            '/product-details?id=${product.id}',
                          );
                        },
                      );
                    },
                  ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/favorites'),
    );
  }
}

