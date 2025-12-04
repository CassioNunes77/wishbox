import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const TopNavBar({
    super.key,
    required this.currentRoute,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: Text(
        'WishBox',
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 20,
          color: AppTheme.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      actions: [
        // Ícones do menu (minimalista)
        if (isWeb) ...[
          _buildNavIcon(
            context: context,
            icon: Icons.search_rounded,
            route: '/home',
            isActive: currentRoute == '/home' || 
                     currentRoute == '/suggestions' || 
                     currentRoute == '/product-details',
            tooltip: 'Buscar',
          ),
          _buildNavIcon(
            context: context,
            icon: Icons.history_rounded,
            route: '/history',
            isActive: currentRoute == '/history',
            tooltip: 'Histórico',
          ),
          _buildNavIcon(
            context: context,
            icon: Icons.favorite_rounded,
            route: '/favorites',
            isActive: currentRoute == '/favorites',
            tooltip: 'Favoritos',
          ),
          const SizedBox(width: 8),
        ],
        // Ícone de perfil
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
          tooltip: 'Perfil',
        ),
      ],
    );
  }

  Widget _buildNavIcon({
    required BuildContext context,
    required IconData icon,
    required String route,
    required bool isActive,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (currentRoute != route) {
            context.go(route);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

