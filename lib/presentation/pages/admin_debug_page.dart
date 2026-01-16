import 'package:flutter/material.dart';
import '../../core/services/affiliate_store_service.dart';
import '../../core/services/magazine_luiza_api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data_service.dart';

class AdminDebugPage extends StatefulWidget {
  const AdminDebugPage({super.key});

  @override
  State<AdminDebugPage> createState() => _AdminDebugPageState();
}

class _AdminDebugPageState extends State<AdminDebugPage> {
  List<String> _logs = [];
  bool _isLoading = false;

  Future<void> _runDiagnostics() async {
    setState(() {
      _logs = [];
      _isLoading = true;
    });

    _addLog('=== Iniciando diagnóstico ===');
    
    // 1. Verificar todas as lojas
    final allStores = await AffiliateStoreService.getAffiliateStores();
    _addLog('Total de lojas cadastradas: ${allStores.length}');
    for (final store in allStores) {
      _addLog('  - ${store.displayName} (${store.name}) - Ativa: ${store.isActive}');
    }
    
    // 2. Verificar lojas ativas
    final activeStores = await AffiliateStoreService.getActiveStores();
    _addLog('\nLojas ativas: ${activeStores.length}');
    for (final store in activeStores) {
      _addLog('  - ${store.displayName} (${store.name})');
    }
    
    // 3. Verificar produtos gerados
    final mockService = MockDataService();
    final suggestions = await mockService.getGiftSuggestions();
    _addLog('\nTotal de sugestões geradas: ${suggestions.length}');
    
    // Agrupar por loja
    final productsByStore = <String, int>{};
    for (final suggestion in suggestions) {
      final storeName = suggestion.product.affiliateSource;
      productsByStore[storeName] = (productsByStore[storeName] ?? 0) + 1;
    }
    
    _addLog('\nProdutos por loja:');
    productsByStore.forEach((store, count) {
      _addLog('  - $store: $count produtos');
    });
    
    // 4. Verificar Magazine Luiza especificamente
    final magazineLuiza = await AffiliateStoreService.getStoreByName('magazine_luiza');
    if (magazineLuiza != null) {
      _addLog('\nMagazine Luiza encontrada:');
      _addLog('  - Nome: ${magazineLuiza.name}');
      _addLog('  - Display: ${magazineLuiza.displayName}');
      _addLog('  - Ativa: ${magazineLuiza.isActive}');
      
      // Tentar buscar produtos reais
      try {
        final products = await MagazineLuizaApiService.searchProducts(
          query: 'presentes',
          limit: 3,
          affiliateUrl: magazineLuiza.affiliateUrlTemplate,
        );
        _addLog('  - Produtos reais encontrados: ${products.length}');
      } catch (e) {
        _addLog('  - Erro ao buscar produtos: $e');
      }
    } else {
      _addLog('\n⚠️ Magazine Luiza NÃO encontrada!');
      _addLog('Tentando variações do nome...');
      
      final variations = ['magazine_luiza', 'magazineluiza', 'magazine-luiza', 'Magazine Luiza'];
      for (final variation in variations) {
        final store = await AffiliateStoreService.getStoreByName(variation);
        if (store != null) {
          _addLog('  ✓ Encontrada como: $variation');
        }
      }
    }
    
    setState(() => _isLoading = false);
    _addLog('\n=== Diagnóstico concluído ===');
  }

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico de Lojas'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _runDiagnostics,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 0),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Executar Diagnóstico'),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        'Clique em "Executar Diagnóstico" para ver os logs',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(
                              color: Colors.green,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

