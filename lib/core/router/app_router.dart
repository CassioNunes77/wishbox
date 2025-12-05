import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/onboarding_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/recipient_form_page.dart';
import '../../presentation/pages/preferences_page.dart';
import '../../presentation/pages/loading_profile_page.dart';
import '../../presentation/pages/suggestions_page.dart';
import '../../presentation/pages/history_page.dart';
import '../../presentation/pages/favorites_page.dart';
import '../../presentation/pages/product_details_page.dart';
import '../../presentation/pages/profile_page.dart';
import '../../presentation/pages/admin_page.dart';
import '../../presentation/pages/admin_debug_page.dart';
import '../theme/app_theme.dart';

class AppRouter {
  static final GoRouter _routerInstance = _createRouter();
  
  static GoRouter get router => _routerInstance;

  static GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: false,
      redirect: (context, state) {
        return null;
      },
    errorBuilder: (context, state) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Erro'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ops! Algo deu errado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.error?.toString() ?? 'Erro desconhecido',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).go('/home');
                  },
                  child: const Text('Voltar ao início'),
                ),
              ],
            ),
          ),
        ),
      );
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/recipient-form',
        name: 'recipient-form',
        builder: (context, state) => const RecipientFormPage(),
      ),
      GoRoute(
        path: '/preferences',
        name: 'preferences',
        builder: (context, state) => const PreferencesPage(),
      ),
      GoRoute(
        path: '/loading-profile',
        name: 'loading-profile',
        builder: (context, state) {
          // Extrair parâmetros da URL
          final queryParams = state.uri.queryParameters;
          return LoadingProfilePage(
            query: queryParams['query'],
            isSelfGift: queryParams['isSelfGift'] == 'true',
            minPrice: double.tryParse(queryParams['minPrice'] ?? '0') ?? 0.0,
            maxPrice: double.tryParse(queryParams['maxPrice'] ?? '1000') ?? 1000.0,
            giftTypes: queryParams['giftTypes']?.split(',') ?? [],
          );
        },
      ),
      GoRoute(
        path: '/suggestions',
        name: 'suggestions',
        builder: (context, state) {
          // Extrair parâmetros da URL
          final queryParams = state.uri.queryParameters;
          return SuggestionsPage(
            query: queryParams['query'],
            isSelfGift: queryParams['isSelfGift'] == 'true',
            minPrice: double.tryParse(queryParams['minPrice'] ?? '0') ?? 0.0,
            maxPrice: double.tryParse(queryParams['maxPrice'] ?? '1000') ?? 1000.0,
            giftTypes: queryParams['giftTypes']?.split(',') ?? [],
            relationType: queryParams['relationType'],
            occasion: queryParams['occasion'],
          );
        },
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesPage(),
      ),
      GoRoute(
        path: '/product-details',
        name: 'product-details',
        builder: (context, state) {
          final productId = state.uri.queryParameters['id'] ?? '';
          return ProductDetailsPage(productId: productId);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminPage(),
      ),
      GoRoute(
        path: '/admin/debug',
        name: 'admin-debug',
        builder: (context, state) => const AdminDebugPage(),
      ),
    ],
    );
  }
}

