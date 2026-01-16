import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class AppPreferencesService {
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String _keyHasSeenSplash = 'has_seen_splash';

  /// Verifica se o usuário já completou o onboarding/splash
  static Future<bool> hasCompletedOnboarding() async {
    try {
      // Usar timeout para evitar travamentos
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 2));
      final value = prefs.getBool(_keyHasCompletedOnboarding) ?? false;
      debugPrint('=== AppPreferencesService: hasCompletedOnboarding = $value ===');
      return value;
    } catch (e) {
      debugPrint('=== AppPreferencesService: Error reading hasCompletedOnboarding: $e ===');
      // Em caso de erro, retorna false para garantir que o usuário veja o onboarding
      return false;
    }
  }

  /// Marca que o usuário completou o onboarding/splash
  static Future<void> setCompletedOnboarding(bool value) async {
    try {
      // Usar timeout mais curto para evitar travamentos na inicialização
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(milliseconds: 500), onTimeout: () {
        debugPrint('=== Timeout getting SharedPreferences instance ===');
        throw TimeoutException('Timeout getting SharedPreferences', const Duration(milliseconds: 500));
      });
      
      await prefs.setBool(_keyHasCompletedOnboarding, value)
          .timeout(const Duration(milliseconds: 500));
      
      debugPrint('=== AppPreferencesService: setCompletedOnboarding($value) = success ===');
    } on TimeoutException {
      debugPrint('=== AppPreferencesService: Timeout writing hasCompletedOnboarding ===');
      // Não relançar o erro para não bloquear o app - apenas logar
      // O app deve continuar funcionando mesmo se não conseguir salvar
    } catch (e) {
      debugPrint('=== AppPreferencesService: Error writing hasCompletedOnboarding: $e ===');
      // Não relançar o erro para não bloquear o app - apenas logar
      // O app deve continuar funcionando mesmo se não conseguir salvar
    }
  }

  /// Verifica se o usuário já viu a splash screen
  static Future<bool> hasSeenSplash() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool(_keyHasSeenSplash) ?? false;
      debugPrint('=== AppPreferencesService: hasSeenSplash = $value ===');
      return value;
    } catch (e) {
      debugPrint('=== AppPreferencesService: Error reading hasSeenSplash: $e ===');
      return false;
    }
  }

  /// Marca que o usuário viu a splash screen
  static Future<void> setSeenSplash(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setBool(_keyHasSeenSplash, value);
      debugPrint('=== AppPreferencesService: setSeenSplash($value) = $success ===');
    } catch (e) {
      debugPrint('=== AppPreferencesService: Error writing hasSeenSplash: $e ===');
    }
  }
}

