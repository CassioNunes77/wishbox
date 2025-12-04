import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/app_preferences_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    try {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2000),
      );

      // Animação de fade in
      _fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        ),
      );

      // Animação de scale (zoom)
      _scaleAnimation = Tween<double>(
        begin: 0.5,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
        ),
      );

      // Animação de slide up
      _slideAnimation = Tween<double>(
        begin: 50.0,
        end: 0.0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        ),
      );

      // Verificar se já viu a splash antes
      _checkIfShouldSkipSplash();
    } catch (e) {
      debugPrint('=== Error in SplashPage initState: $e ===');
      // Se houver erro, tentar navegar imediatamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _navigateToHome();
        }
      });
    }
  }

  void _checkIfShouldSkipSplash() async {
    try {
      // Sempre mostrar animação e depois navegar
      _controller.forward();
      _navigateToHome();
    } catch (e) {
      debugPrint('=== Error in splash: $e ===');
      // Em caso de erro, navegar imediatamente
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final router = GoRouter.maybeOf(context);
          if (router != null) {
            router.go('/home');
          }
        }
      });
    }
  }
  
  void _navigateToHome() async {
    // Aguardar animação e navegar
    Future.delayed(const Duration(milliseconds: 2000), () async {
      if (!mounted) return;
      
      try {
        await AppPreferencesService.setCompletedOnboarding(true);
        
        if (!mounted) return;
        
        final router = GoRouter.maybeOf(context);
        if (router != null) {
          router.go('/home');
        }
      } catch (e) {
        debugPrint('=== Error navigating from splash: $e ===');
        if (mounted) {
          final router = GoRouter.maybeOf(context);
          if (router != null) {
            router.go('/home');
          }
        }
      }
    });
  }
  

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            color: AppTheme.primaryColor,
            child: Center(
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: const Text(
                    'WishBox',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                      fontFamily: 'Roboto',
                    ),
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

