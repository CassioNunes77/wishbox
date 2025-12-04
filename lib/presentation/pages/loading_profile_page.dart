import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';
import '../widgets/loading_indicator.dart';

class LoadingProfilePage extends StatefulWidget {
  const LoadingProfilePage({super.key});

  @override
  State<LoadingProfilePage> createState() => _LoadingProfilePageState();
}

class _LoadingProfilePageState extends State<LoadingProfilePage> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Analisando o perfil...',
    'Identificando interesses e personalidade...',
    'Buscando produtos ideais...',
    'Calculando compatibilidade...',
    'Quase lá!',
  ];

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          if (_currentStep < _steps.length - 1) {
            _currentStep++;
          } else {
            timer.cancel();
            // Navegar para sugestões após um breve delay
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                context.go('/suggestions');
              }
            });
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerando perfil'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Indicador de loading
              const LoadingIndicator(
                message: 'Nossa IA está analisando...',
              ),
              const SizedBox(height: 48),
              
              // Passos
              Column(
                children: List.generate(_steps.length, (index) {
                  final isCompleted = index < _currentStep;
                  final isCurrent = index == _currentStep;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? AppTheme.successColor
                                : isCurrent
                                    ? AppTheme.primaryColor
                                    : AppTheme.textLight,
                          ),
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : isCurrent
                                  ? const SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _steps[index],
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isCompleted || isCurrent
                                      ? AppTheme.textPrimary
                                      : AppTheme.textLight,
                                  fontWeight: isCurrent
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



