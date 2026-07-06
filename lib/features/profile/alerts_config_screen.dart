import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/deal.dart';
import '../../services/user_data_service.dart';

class AlertsConfigScreen extends StatefulWidget {
  const AlertsConfigScreen({super.key});

  @override
  State<AlertsConfigScreen> createState() => _AlertsConfigScreenState();
}

class _AlertsConfigScreenState extends State<AlertsConfigScreen> {
  final _userDataService = UserDataService();

  final _categories = [
    (DealCategory.eletronicos, Icons.devices_rounded),
    (DealCategory.moda, Icons.checkroom_rounded),
    (DealCategory.casa, Icons.home_rounded),
    (DealCategory.beleza, Icons.face_retouching_natural_rounded),
    (DealCategory.alimentacao, Icons.restaurant_rounded),
    (DealCategory.jogos, Icons.sports_esports_rounded),
    (DealCategory.esporte, Icons.sports_soccer_rounded),
    (DealCategory.livros, Icons.menu_book_rounded),
    (DealCategory.viagem, Icons.flight_rounded),
    (DealCategory.outros, Icons.shopping_bag_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Configurar Alertas'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Master switch
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notificações',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      Text('Receber alertas de promoções',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Switch(
                  value: _userDataService.alertsEnabled,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    _userDataService.setAlertsEnabled(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'CATEGORIAS DE ALERTA',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          Opacity(
            opacity: _userDataService.alertsEnabled ? 1 : 0.4,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _categories.map((item) {
                final (cat, icon) = item;
                final isSelected =
                    _userDataService.alertCategories.contains(cat.name);
                return GestureDetector(
                  onTap: _userDataService.alertsEnabled
                      ? () {
                          _userDataService.toggleAlertCategory(cat.name);
                          setState(() {});
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon,
                            size: 16,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: AppColors.primary, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Você receberá alertas quando novos achados forem postados nas categorias selecionadas.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
