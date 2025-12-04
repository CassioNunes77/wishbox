import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data_service.dart';
import '../../domain/entities/product.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/bottom_nav_bar.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;

  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    final mockService = MockDataService();
    final product = mockService.getProductById(productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Produto não encontrado')),
        body: const Center(child: Text('Produto não encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do presente'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 300,
                  width: double.infinity,
                  color: AppTheme.textLight.withOpacity(0.1),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: AppTheme.textLight,
                            );
                          },
                        )
                      : const Icon(
                          Icons.image,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Nome
              Text(
                product.name,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),
              
              // Preço
              Text(
                '${AppConstants.currencySymbol} ${product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: product.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Descrição
              Text(
                'Descrição',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              
              // Rating (se disponível)
              if (product.rating != null) ...[
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating!.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    if (product.reviewCount != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${product.reviewCount} avaliações)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
              ],
              
              // Botão ver na loja
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Abrir link de afiliado
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Abrindo loja...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('Ver na loja'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/product-details'),
    );
  }
}



