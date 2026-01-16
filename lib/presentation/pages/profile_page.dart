import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/bottom_nav_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      appBar: TopNavBar(currentRoute: '/profile'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWeb ? 40 : 24,
            vertical: 32,
          ),
          child: Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: isWeb ? 600 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Nome do usuário
                  Text(
                    'Usuário',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Email
                  Text(
                    'usuario@email.com',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Seções do perfil
                  _buildSection(
                    context: context,
                    title: 'Conta',
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: Icons.edit_rounded,
                        title: 'Editar perfil',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em breve!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.notifications_outlined,
                        title: 'Notificações',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em breve!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    context: context,
                    title: 'Preferências',
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: Icons.palette_outlined,
                        title: 'Tema',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em breve!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.language_outlined,
                        title: 'Idioma',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em breve!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildSection(
                    context: context,
                    title: 'Sobre',
                    children: [
                      _buildMenuItem(
                        context: context,
                        icon: Icons.help_outline,
                        title: 'Ajuda',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em breve!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        context: context,
                        icon: Icons.info_outline,
                        title: 'Sobre o WishBox',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidade em breve!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Botão de sair
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidade em breve!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.errorColor),
                      ),
                      child: Text(
                        'Sair',
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: isWeb ? null : const BottomNavBar(currentRoute: '/profile'),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textLight,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


