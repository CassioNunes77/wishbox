import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'dart:ui';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  // Garantir que o binding está inicializado ANTES de tudo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tratamento de erros do Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Log do erro para debug
    debugPrint('=== Flutter Error ===');
    debugPrint('Exception: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
    debugPrint('Library: ${details.library}');
    debugPrint('===================');
  };
  
  // Tratamento de erros da plataforma (iOS/Android)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('=== Platform Error ===');
    debugPrint('Error: $error');
    debugPrint('Stack: $stack');
    debugPrint('====================');
    return true; // Indica que o erro foi tratado
  };
  
  // Tratamento de erros assíncronos não capturados
  runZonedGuarded(
    () {
      debugPrint('=== App Starting ===');
      try {
        runApp(
          const ProviderScope(
            child: PresenteIdealApp(),
          ),
        );
        debugPrint('=== App Started Successfully ===');
      } catch (e, stackTrace) {
        debugPrint('=== Error starting app ===');
        debugPrint('Error: $e');
        debugPrint('Stack: $stackTrace');
        debugPrint('============================');
        // Fallback: tentar iniciar mesmo com erro
        try {
          runApp(
            MaterialApp(
              title: 'WishBox',
              home: Scaffold(
                backgroundColor: AppTheme.backgroundColor,
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Erro ao iniciar app',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$e',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } catch (fallbackError) {
          debugPrint('=== Fallback also failed: $fallbackError ===');
        }
      }
    },
    (error, stackTrace) {
      // Log de erros não capturados
      debugPrint('=== Uncaught Error in Zone ===');
      debugPrint('Error: $error');
      debugPrint('Stack: $stackTrace');
      debugPrint('=============================');
    },
  );
}

class PresenteIdealApp extends StatelessWidget {
  const PresenteIdealApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return MaterialApp.router(
        title: 'WishBox',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
        // Prevenir crashes em produção
        builder: (context, child) {
          // Capturar erros de renderização
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColor,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ops! Algo deu errado',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Tentar reiniciar o app
                          try {
                            GoRouter.of(context).go('/home');
                          } catch (e) {
                            debugPrint('Erro ao reiniciar: $e');
                          }
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          };
          return child ?? const SizedBox();
        },
      );
    } catch (e) {
      // Fallback se houver erro na criação do MaterialApp
      debugPrint('Erro ao criar MaterialApp: $e');
      return MaterialApp(
        title: 'WishBox',
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Erro ao iniciar app'),
                const SizedBox(height: 8),
                Text('$e'),
              ],
            ),
          ),
        ),
      );
    }
  }
}

