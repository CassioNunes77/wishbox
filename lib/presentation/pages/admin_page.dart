import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/affiliate_store_service.dart';
import '../../domain/entities/affiliate_store.dart';
import 'package:uuid/uuid.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _affiliateUrlController = TextEditingController();
  final TextEditingController _apiEndpointController = TextEditingController();
  
  bool _isAuthenticated = false;
  bool _isLoading = false;
  List<AffiliateStore> _stores = [];
  AffiliateStore? _editingStore;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _nameController.dispose();
    _displayNameController.dispose();
    _affiliateUrlController.dispose();
    _apiEndpointController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    setState(() => _isLoading = true);
    final stores = await AffiliateStoreService.getAffiliateStores();
    if (mounted) {
      setState(() {
        _stores = stores;
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticate() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite a senha'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final isValid = await AffiliateStoreService.verifyAdminPassword(password);
    if (isValid) {
      setState(() {
        _isAuthenticated = true;
      });
      _passwordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha incorreta'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _startEditing(AffiliateStore store) {
    setState(() {
      _editingStore = store;
      _nameController.text = store.name;
      _displayNameController.text = store.displayName;
      _affiliateUrlController.text = store.affiliateUrlTemplate;
      _apiEndpointController.text = store.apiEndpoint;
    });
  }

  void _cancelEditing() {
    setState(() {
      _editingStore = null;
      _nameController.clear();
      _displayNameController.clear();
      _affiliateUrlController.clear();
      _apiEndpointController.clear();
    });
  }

  Future<void> _saveStore() async {
    final name = _nameController.text.trim();
    final displayName = _displayNameController.text.trim();
    final affiliateUrl = _affiliateUrlController.text.trim();

    if (name.isEmpty || displayName.isEmpty || affiliateUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final store = AffiliateStore(
      id: _editingStore?.id ?? _uuid.v4(),
      name: name,
      displayName: displayName,
      affiliateUrlTemplate: affiliateUrl,
      apiEndpoint: _apiEndpointController.text.trim(),
      isActive: _editingStore?.isActive ?? true,
      createdAt: _editingStore?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = _editingStore == null
        ? await AffiliateStoreService.addStore(store)
        : await AffiliateStoreService.updateStore(store);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingStore == null
                ? 'Loja adicionada com sucesso!'
                : 'Loja atualizada com sucesso!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _cancelEditing();
        await _loadStores();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar loja'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteStore(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta loja?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      final success = await AffiliateStoreService.removeStore(id);
      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Loja excluída com sucesso!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          await _loadStores();
        }
      }
    }
  }

  Future<void> _toggleStoreStatus(String id) async {
    setState(() => _isLoading = true);
    final success = await AffiliateStoreService.toggleStoreStatus(id);
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        await _loadStores();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Área Administrativa',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Digite a senha para acessar',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      prefixIcon: const Icon(Icons.lock_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _authenticate(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Entrar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Voltar ao site'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Gerenciar Lojas Afiliadas'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_rounded),
            onPressed: () => context.go('/admin/debug'),
            tooltip: 'Diagnóstico',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              setState(() => _isAuthenticated = false);
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formulário
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _editingStore == null
                                ? 'Adicionar Nova Loja'
                                : 'Editar Loja',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome (ID) *',
                              hintText: 'amazon, mercado_livre, etc.',
                              helperText: 'Identificador único (sem espaços)',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _displayNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome de Exibição *',
                              hintText: 'Amazon, Mercado Livre, etc.',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _affiliateUrlController,
                            decoration: const InputDecoration(
                              labelText: 'URL Base do Afiliado *',
                              hintText: 'https://www.magazinevoce.com.br/elislecio/',
                              helperText: 'Para Magazine Luiza: use a URL completa da sua loja (ex: https://www.magazinevoce.com.br/seu-usuario/). O sistema usará esta URL para buscar produtos.',
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _apiEndpointController,
                            decoration: const InputDecoration(
                              labelText: 'Endpoint da API (opcional)',
                              hintText: 'https://api.loja.com/products',
                              helperText: 'Endpoint para buscar produtos desta loja',
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveStore,
                                  child: Text(_editingStore == null
                                      ? 'Adicionar'
                                      : 'Salvar Alterações'),
                                ),
                              ),
                              if (_editingStore != null) ...[
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: _cancelEditing,
                                  child: const Text('Cancelar'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Lista de lojas
                  Text(
                    'Lojas Cadastradas (${_stores.length})',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._stores.map((store) => _buildStoreCard(store)),
                ],
              ),
            ),
    );
  }

  Widget _buildStoreCard(AffiliateStore store) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            store.displayName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: store.isActive
                                  ? AppTheme.successColor.withOpacity(0.1)
                                  : AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              store.isActive ? 'Ativa' : 'Inativa',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: store.isActive
                                    ? AppTheme.successColor
                                    : AppTheme.errorColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${store.name}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    store.isActive
                        ? Icons.toggle_on_rounded
                        : Icons.toggle_off_rounded,
                    color: store.isActive
                        ? AppTheme.successColor
                        : AppTheme.textLight,
                    size: 40,
                  ),
                  onPressed: () => _toggleStoreStatus(store.id),
                  tooltip: store.isActive ? 'Desativar' : 'Ativar',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Template de URL:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.affiliateUrlTemplate,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            if (store.apiEndpoint.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Endpoint:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      store.apiEndpoint,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _startEditing(store),
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('Editar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _deleteStore(store.id),
                  icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                  label: const Text('Excluir', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

