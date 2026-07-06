import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../services/user_data_service.dart';

class VisitHistoryScreen extends StatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  final _userDataService = UserDataService();

  @override
  Widget build(BuildContext context) {
    final history = _userDataService.visitHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Histórico de Visitas'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (history.isNotEmpty)
            TextButton(
              onPressed: () {
                _userDataService.clearHistory();
                setState(() {});
              },
              child: const Text('Limpar',
                  style: TextStyle(color: AppColors.hot, fontSize: 13)),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_rounded,
                      size: 72, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  const Text('Histórico vazio',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('Produtos que você visitar aparecerão aqui',
                      style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                final date = DateTime.tryParse(item['visitedAt'] ?? '') ??
                    DateTime.now();
                final diff = DateTime.now().difference(date);
                String timeLabel;
                if (diff.inMinutes < 60) {
                  timeLabel = 'Há ${diff.inMinutes} min';
                } else if (diff.inHours < 24) {
                  timeLabel = 'Há ${diff.inHours}h';
                } else {
                  timeLabel = 'Há ${diff.inDays} dias';
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 50,
                          height: 50,
                          color: AppColors.surface,
                          child: const Icon(Icons.image_rounded,
                              color: AppColors.textMuted),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] ?? 'Produto',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 2),
                            Text(timeLabel,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textMuted, size: 18),
                    ],
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: index * 40));
              },
            ),
    );
  }
}
