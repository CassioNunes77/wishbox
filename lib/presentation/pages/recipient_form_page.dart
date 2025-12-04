import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class RecipientFormPage extends StatefulWidget {
  const RecipientFormPage({super.key});

  @override
  State<RecipientFormPage> createState() => _RecipientFormPageState();
}

class _RecipientFormPageState extends State<RecipientFormPage> {
  bool _isSelfGift = false;
  String? _selectedRelationType;
  String? _selectedAgeRange;
  String? _selectedGender;
  String? _selectedOccasion;
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _navigateToNext() {
    if (_isSelfGift || _validateForm()) {
      // Salvar dados temporariamente (usar provider ou state management)
      context.go('/preferences');
    }
  }

  bool _validateForm() {
    if (!_isSelfGift) {
      if (_selectedRelationType == null ||
          _selectedAgeRange == null ||
          _selectedOccasion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios'),
          ),
        );
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Para quem é o presente?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pergunta principal
              const Text(
                'Esse presente é para você ou para outra pessoa?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 32),
              
              // Opção: Presente para mim
              _buildOptionCard(
                title: 'Presente para mim',
                icon: Icons.person,
                isSelected: _isSelfGift,
                onTap: () {
                  setState(() {
                    _isSelfGift = true;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Opção: Presente para outra pessoa
              _buildOptionCard(
                title: 'Presente para outra pessoa',
                icon: Icons.people,
                isSelected: !_isSelfGift,
                onTap: () {
                  setState(() {
                    _isSelfGift = false;
                  });
                },
              ),
              
              if (!_isSelfGift) ...[
                const SizedBox(height: 32),
                Text(
                  'Informações sobre a pessoa',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                
                // Tipo de relação
                _buildDropdown(
                  label: 'Tipo de relação *',
                  value: _selectedRelationType,
                  items: AppConstants.relationTypes,
                  onChanged: (value) {
                    setState(() => _selectedRelationType = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Faixa de idade
                _buildDropdown(
                  label: 'Faixa de idade *',
                  value: _selectedAgeRange,
                  items: AppConstants.ageRanges,
                  onChanged: (value) {
                    setState(() => _selectedAgeRange = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Gênero (opcional)
                _buildDropdown(
                  label: 'Gênero (opcional)',
                  value: _selectedGender,
                  items: AppConstants.genders,
                  onChanged: (value) {
                    setState(() => _selectedGender = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Ocasião
                _buildDropdown(
                  label: 'Ocasião *',
                  value: _selectedOccasion,
                  items: AppConstants.occasions,
                  onChanged: (value) {
                    setState(() => _selectedOccasion = value);
                  },
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Descrição
              Text(
                'Descreva a pessoa (ou você mesmo)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Coisas que gosta, estilo, hobbies, profissão, jeito de ser...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Ex: Gosta de café, leitura, é caseiro, trabalha com tecnologia, gosta de coisas minimalistas...',
                ),
              ),
              const SizedBox(height: 24),
              
              const SizedBox(height: 32),
              // Botão continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continuar',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withOpacity(0.1)
                : AppTheme.surfaceColor,
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.borderColor,
              width: isSelected ? 2.5 : 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? AppTheme.cardShadow : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : AppTheme.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            hintText: 'Selecione uma opção',
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

