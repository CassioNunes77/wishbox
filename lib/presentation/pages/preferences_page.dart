import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/price_range_selector.dart';
import '../widgets/tag_chip.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  double _minPrice = 50.0;
  double _maxPrice = 500.0;
  final Set<String> _selectedGiftTypes = {};
  final Set<String> _selectedStores = {};
  final TextEditingController _avoidController = TextEditingController();

  @override
  void dispose() {
    _avoidController.dispose();
    super.dispose();
  }

  void _toggleGiftType(String type) {
    setState(() {
      if (_selectedGiftTypes.contains(type)) {
        _selectedGiftTypes.remove(type);
      } else {
        _selectedGiftTypes.add(type);
      }
    });
  }

  void _toggleStore(String store) {
    setState(() {
      if (_selectedStores.contains(store)) {
        _selectedStores.remove(store);
      } else {
        _selectedStores.add(store);
      }
    });
  }

  void _navigateToLoading() {
    if (_selectedGiftTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione pelo menos um tipo de presente'),
        ),
      );
      return;
    }
    context.go('/loading-profile');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferências e faixa de preço'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Faixa de preço
              PriceRangeSelector(
                minPrice: _minPrice,
                maxPrice: _maxPrice,
                onMinChanged: (price) {
                  setState(() => _minPrice = price);
                },
                onMaxChanged: (price) {
                  setState(() => _maxPrice = price);
                },
              ),
              const SizedBox(height: 32),
              
              // Tipo de presente
              Text(
                'Tipo de presente desejado *',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.giftTypes.map((type) {
                  return TagChip(
                    label: type,
                    isSelected: _selectedGiftTypes.contains(type),
                    onTap: () => _toggleGiftType(type),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Evitar
              Text(
                'Evitar (opcional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Ex: nada de bebida alcoólica, nada muito chamativo...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _avoidController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'O que evitar?',
                ),
              ),
              const SizedBox(height: 32),
              
              // Lojas preferidas
              Text(
                'Lojas preferidas (opcional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.stores.map((store) {
                  return TagChip(
                    label: store,
                    isSelected: _selectedStores.contains(store),
                    onTap: () => _toggleStore(store),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Botão continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToLoading,
                  child: const Text('Gerar sugestões'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



