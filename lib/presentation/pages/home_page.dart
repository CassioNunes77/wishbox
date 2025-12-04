import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/search_history_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/top_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSelfGift = false;
  bool _showFilters = false;
  double _minPrice = 50.0;
  double _maxPrice = 500.0;
  final Set<String> _selectedGiftTypes = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Descreva a pessoa ou o que você procura'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Salvar no histórico
    await SearchHistoryService.saveSearch(
      query: query,
      isSelfGift: _isSelfGift,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      giftTypes: _selectedGiftTypes.toList(),
    );

    context.go('/loading-profile');
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;
    final maxWidth = isWeb ? 800.0 : double.infinity;
    
    return Scaffold(
      backgroundColor: Colors.white, // ChatGPT style - fundo branco
      appBar: TopNavBar(currentRoute: '/home'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWeb ? 32.0 : 24.0,
                vertical: 40.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo/Título - ChatGPT style
                  const SizedBox(height: 40),
                  Text(
                    'WishBox',
                    style: TextStyle(
                      fontSize: isWeb ? 48 : 36,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.textPrimary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Encontre o presente ideal',
                    style: TextStyle(
                      fontSize: isWeb ? 18 : 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // Barra de pesquisa centralizada - ChatGPT style
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 700),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _searchFocusNode.hasFocus 
                            ? AppTheme.primaryColor 
                            : AppTheme.borderColor,
                        width: _searchFocusNode.hasFocus ? 2 : 1,
                      ),
                      boxShadow: _searchFocusNode.hasFocus
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      maxLines: null,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _performSearch(),
                      style: TextStyle(
                        fontSize: isWeb ? 16 : 15,
                        color: AppTheme.textPrimary,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Descreva a pessoa ou o que você procura...',
                        hintStyle: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: isWeb ? 16 : 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: isWeb ? 20 : 18,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear_rounded,
                                  size: 20,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchFocusNode.unfocus();
                                  setState(() {});
                                },
                              )
                            : IconButton(
                                icon: Icon(
                                  Icons.search_rounded,
                                  size: 24,
                                  color: AppTheme.textSecondary,
                                ),
                                onPressed: _performSearch,
                              ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botões de ação - ChatGPT style (maiores para web)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: Icons.person_outline_rounded,
                        label: 'Para mim',
                        isSelected: _isSelfGift,
                        onTap: () => setState(() => _isSelfGift = true),
                        isWeb: isWeb,
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        icon: Icons.people_outline_rounded,
                        label: 'Para outra pessoa',
                        isSelected: !_isSelfGift,
                        onTap: () => setState(() => _isSelfGift = false),
                        isWeb: isWeb,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Botão de busca principal - ChatGPT style
                  SizedBox(
                    width: isWeb ? 200 : double.infinity,
                    child: ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isWeb ? 32 : 24,
                          vertical: isWeb ? 16 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Buscar',
                            style: TextStyle(
                              fontSize: isWeb ? 16 : 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Filtros opcionais (colapsável)
                  if (!_showFilters)
                    TextButton.icon(
                      onPressed: () => setState(() => _showFilters = true),
                      icon: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                      label: Text(
                        'Filtros opcionais',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: isWeb ? 15 : 14,
                        ),
                      ),
                    ),
                  
                  if (_showFilters) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(maxWidth: 600),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Filtros',
                                style: TextStyle(
                                  fontSize: isWeb ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() => _showFilters = false),
                                icon: const Icon(Icons.close_rounded),
                                color: AppTheme.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Faixa de preço
                          Text(
                            'Faixa de preço',
                            style: TextStyle(
                              fontSize: isWeb ? 15 : 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Mínimo',
                                    prefixText: '${AppConstants.currencySymbol} ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: isWeb ? 16 : 14,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: isWeb ? 15 : 14,
                                  ),
                                  onChanged: (value) {
                                    final price = double.tryParse(value) ?? 0.0;
                                    setState(() => _minPrice = price);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Máximo',
                                    prefixText: '${AppConstants.currencySymbol} ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: isWeb ? 16 : 14,
                                    ),
                                  ),
                                  style: TextStyle(
                                    fontSize: isWeb ? 15 : 14,
                                  ),
                                  onChanged: (value) {
                                    final price = double.tryParse(value) ?? 0.0;
                                    setState(() => _maxPrice = price);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Tipos de presente
                          Text(
                            'Tipo de presente',
                            style: TextStyle(
                              fontSize: isWeb ? 15 : 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: AppConstants.giftTypes.map((type) {
                              return FilterChip(
                                label: Text(
                                  type,
                                  style: TextStyle(
                                    fontSize: isWeb ? 14 : 13,
                                  ),
                                ),
                                selected: _selectedGiftTypes.contains(type),
                                onSelected: (selected) => _toggleGiftType(type),
                                selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                                checkmarkColor: AppTheme.primaryColor,
                                side: BorderSide(
                                  color: _selectedGiftTypes.contains(type)
                                      ? AppTheme.primaryColor
                                      : AppTheme.borderColor,
                                  width: 1,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWeb ? 16 : 12,
                                  vertical: isWeb ? 12 : 8,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: isWeb ? null : const BottomNavBar(currentRoute: '/home'),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isWeb,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 24 : 20,
            vertical: isWeb ? 14 : 12,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.borderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isWeb ? 22 : 20,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isWeb ? 15 : 14,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
