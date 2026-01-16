import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class TopNavBar extends StatefulWidget implements PreferredSizeWidget {
  final String currentRoute;
  final Widget? searchBar;

  const TopNavBar({
    super.key,
    required this.currentRoute,
    this.searchBar,
  });

  @override
  State<TopNavBar> createState() => _TopNavBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _TopNavBarState extends State<TopNavBar> {
  // Remover animação contínua - agora será apenas no hover

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return AppBar(
      elevation: 0,
      backgroundColor: AppTheme.primaryColor, // Cor roxa
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Logo WishBox
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/home'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'WishBox',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          // Barra de busca (se fornecida)
          if (widget.searchBar != null) ...[
            const SizedBox(width: 16),
            Expanded(child: widget.searchBar!),
          ],
        ],
      ),
      actions: [
        // Ícones do menu (minimalista)
        if (isWeb) ...[
          _buildNavIcon(
            context: context,
            icon: Icons.home_rounded,
            route: '/home',
            isActive: widget.currentRoute == '/home' || 
                     widget.currentRoute == '/suggestions' || 
                     widget.currentRoute == '/product-details',
            tooltip: 'Home',
            animationIndex: 0,
          ),
          _buildNavIcon(
            context: context,
            icon: Icons.history_rounded,
            route: '/history',
            isActive: widget.currentRoute == '/history',
            tooltip: 'Histórico',
            animationIndex: 1,
          ),
          _buildNavIcon(
            context: context,
            icon: Icons.favorite_rounded,
            route: '/favorites',
            isActive: widget.currentRoute == '/favorites',
            tooltip: 'Favoritos',
            animationIndex: 2,
          ),
          const SizedBox(width: 8),
        ],
        // Ícone de perfil
        _buildHoverIcon(
          icon: Icons.person_outline_rounded,
          onTap: () => context.go('/profile'),
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
    required int animationIndex,
  }) {
    return _buildHoverIcon(
      icon: icon,
      onTap: () {
        if (widget.currentRoute != route) {
          context.go(route);
        }
      },
      tooltip: tooltip,
      isActive: isActive,
    );
  }

  /// Constrói um ícone com animação apenas no hover
  Widget _buildHoverIcon({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isActive = false,
  }) {
    return _HoverAnimatedIcon(
      icon: icon,
      onTap: onTap,
      tooltip: tooltip,
      isActive: isActive,
    );
  }
}

/// Widget que anima o ícone apenas quando o mouse está sobre ele
class _HoverAnimatedIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isActive;

  const _HoverAnimatedIcon({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.isActive = false,
  });

  @override
  State<_HoverAnimatedIcon> createState() => _HoverAnimatedIconState();
}

class _HoverAnimatedIconState extends State<_HoverAnimatedIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEnterEvent event) {
    setState(() => _isHovering = true);
    _controller.forward();
  }

  void _onExit(PointerExitEvent event) {
    setState(() => _isHovering = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: widget.isActive
                        ? Colors.white.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

