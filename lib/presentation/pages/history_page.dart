import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/search_history_service.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/top_nav_bar.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await SearchHistoryService.getSearchHistory();
      if (mounted) {
        setState(() {
          _history = history;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Erro ao carregar histórico: $e');
      }
    }
  }

  Future<void> _deleteSearch(String searchId) async {
    final success = await SearchHistoryService.removeSearch(searchId);
    if (success && mounted) {
      await _loadHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesquisa removida do histórico'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text('Tem certeza que deseja limpar todo o histórico de pesquisas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await SearchHistoryService.clearHistory();
      if (success && mounted) {
        await _loadHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Histórico limpo'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _reuseSearch(Map<String, dynamic> search) {
    // Construir query parameters para a página de sugestões
    final queryParams = <String, String>{
      'query': search['query'] ?? '',
      'isSelfGift': (search['isSelfGift'] ?? false).toString(),
      'minPrice': (search['minPrice'] ?? 0.0).toString(),
      'maxPrice': (search['maxPrice'] ?? 1000.0).toString(),
    };
    
    // Adicionar tipos de presente se houver
    if (search['giftTypes'] != null && (search['giftTypes'] as List).isNotEmpty) {
      queryParams['giftTypes'] = (search['giftTypes'] as List).join(',');
    }
    
    // Adicionar relação se houver
    if (search['relationType'] != null) {
      queryParams['relationType'] = search['relationType'];
    }
    
    // Adicionar ocasião se houver
    if (search['occasion'] != null) {
      queryParams['occasion'] = search['occasion'];
    }
    
    // Navegar para sugestões com os parâmetros
    context.go('/suggestions?${Uri(queryParameters: queryParams).query}');
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hoje';
      } else if (difference.inDays == 1) {
        return 'Ontem';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} dias atrás';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    
    return Scaffold(
      appBar: TopNavBar(currentRoute: '/history'),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: AppTheme.textLight,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma busca ainda',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Comece a buscar presentes para ver seu histórico aqui',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Header com botão limpar
                      if (_history.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWeb ? 32 : 16,
                            vertical: 12,
                          ),
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Histórico de pesquisas',
                                style: TextStyle(
                                  fontSize: isWeb ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _clearAllHistory,
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: const Text('Limpar tudo'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.errorColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Lista de pesquisas
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.all(isWeb ? 24 : 16),
                          itemCount: _history.length,
                          itemBuilder: (context, index) {
                            final search = _history[index];
                            return _buildHistoryItem(search, isWeb);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar: isWeb ? null : const BottomNavBar(currentRoute: '/history'),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> search, bool isWeb) {
    return Card(
      margin: EdgeInsets.only(bottom: isWeb ? 16 : 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _reuseSearch(search),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isWeb ? 20 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  search['isSelfGift'] == true
                      ? Icons.person_rounded
                      : Icons.people_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Query
                    Text(
                      search['query'] ?? 'Pesquisa',
                      style: TextStyle(
                        fontSize: isWeb ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Info adicional
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        if (search['isSelfGift'] == true)
                          _buildInfoChip('Para mim', Icons.person_outline, isWeb)
                        else if (search['relationType'] != null)
                          _buildInfoChip(
                            search['relationType'],
                            Icons.people_outline,
                            isWeb,
                          ),
                        if (search['occasion'] != null)
                          _buildInfoChip(
                            search['occasion'],
                            Icons.cake_outlined,
                            isWeb,
                          ),
                        _buildInfoChip(
                          '${AppConstants.currencySymbol} ${(search['minPrice'] ?? 0.0).toStringAsFixed(0)} - ${AppConstants.currencySymbol} ${(search['maxPrice'] ?? 0.0).toStringAsFixed(0)}',
                          Icons.attach_money_rounded,
                          isWeb,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Data
                    Text(
                      _formatDate(search['createdAt'] ?? DateTime.now().toIso8601String()),
                      style: TextStyle(
                        fontSize: isWeb ? 13 : 12,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Botão deletar
              IconButton(
                onPressed: () => _deleteSearch(search['id'] ?? ''),
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: AppTheme.textLight,
                ),
                tooltip: 'Remover',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon, bool isWeb) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWeb ? 10 : 8,
        vertical: isWeb ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: isWeb ? 14 : 12, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: isWeb ? 12 : 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
