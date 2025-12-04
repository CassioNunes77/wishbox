import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data_service.dart';
import '../../domain/entities/gift_search_session.dart';
import '../../core/constants/app_constants.dart';
import '../widgets/bottom_nav_bar.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<GiftSearchSession> sessions = [];
    try {
      final mockService = MockDataService();
      sessions = mockService.getSearchSessions();
    } catch (e) {
      // Se houver erro, usar lista vazia
      debugPrint('Erro ao carregar histórico: $e');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas buscas e presentes'),
      ),
      body: SafeArea(
        child: sessions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.history,
                      size: 64,
                      color: AppTheme.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma busca ainda',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Comece a buscar presentes para ver seu histórico aqui',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sessions.length,
                itemBuilder: (context, index) {
                  final session = sessions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                session.recipientProfile.isSelfGift
                                    ? Icons.person
                                    : Icons.people,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  session.recipientProfile.isSelfGift
                                      ? 'Presente para mim'
                                      : session.recipientProfile.relationType ?? 'Outra pessoa',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            ],
                          ),
                          if (session.recipientProfile.occasion != null) ...[
                            const SizedBox(height: 8),
                            Chip(
                              label: Text(session.recipientProfile.occasion!),
                              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            '${AppConstants.currencySymbol} ${session.priceMin.toStringAsFixed(2)} - ${AppConstants.currencySymbol} ${session.priceMax.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${session.createdAt.day}/${session.createdAt.month}/${session.createdAt.year}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: const BottomNavBar(currentRoute: '/history'),
    );
  }
}

