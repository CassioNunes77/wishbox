import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/bottom_nav_bar.dart';

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
    // NÃO focar automaticamente - usuário deve clicar para abrir teclado
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
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

    // Navegar para loading e depois sugestões
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'WishBox',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
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
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo de busca principal - estilo Dafiti
              GestureDetector(
                onTap: () {
                  _searchFocusNode.requestFocus();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 1,
                    ),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    maxLines: 3,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _performSearch(),
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'O que você está procurando?',
                      hintStyle: const TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppTheme.textSecondary,
                        size: 24,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
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
                          : null,
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Roboto',
                    ),
                    onChanged: (value) => setState(() {}),
                    onTap: () {
                      _searchFocusNode.requestFocus();
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Toggle rápido: Para mim / Para outra pessoa
              Row(
                children: [
                  Expanded(
                    child: _buildQuickToggle(
                      label: 'Para mim',
                      icon: Icons.person_outline_rounded,
                      isSelected: _isSelfGift,
                      onTap: () => setState(() => _isSelfGift = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickToggle(
                      label: 'Para outra pessoa',
                      icon: Icons.people_outline_rounded,
                      isSelected: !_isSelfGift,
                      onTap: () => setState(() => _isSelfGift = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Filtros opcionais (colapsável) - estilo Dafiti
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _showFilters
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Filtros opcionais',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              if (_showFilters) ...[
                const SizedBox(height: 16),
                // Faixa de preço - estilo Dafiti
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Faixa de preço',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                          fontFamily: 'Roboto',
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
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                              ),
                              onChanged: (value) {
                                final price = double.tryParse(value) ?? 0.0;
                                setState(() => _minPrice = price);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Máximo',
                                prefixText: '${AppConstants.currencySymbol} ',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                              ),
                              onChanged: (value) {
                                final price = double.tryParse(value) ?? 0.0;
                                setState(() => _maxPrice = price);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Tipos de presente
                      const Text(
                        'Tipo de presente',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.giftTypes.map((type) {
                          return FilterChip(
                            label: Text(
                              type,
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 13,
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
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Botão de busca - estilo Dafiti
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Buscar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/home'),
    );
  }

  Widget _buildQuickToggle({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.textSecondary,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
