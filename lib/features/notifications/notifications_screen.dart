import 'package:flutter/material.dart';
import '../../app/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      _NotificationItem(
        icon: Icons.local_fire_department_rounded,
        title: 'PS5 com 32% de desconto!',
        subtitle: 'A oferta que você salvou baixou de preço',
        time: '5 min atrás',
        isNew: true,
        color: AppColors.hot,
      ),
      _NotificationItem(
        icon: Icons.local_offer_rounded,
        title: 'Cupom exclusivo: ACHADOS20',
        subtitle: 'Válido por mais 6 horas na Amazon',
        time: '1h atrás',
        isNew: true,
        color: AppColors.coupon,
      ),
      _NotificationItem(
        icon: Icons.smartphone_rounded,
        title: 'Nova oferta em Eletrônicos',
        subtitle: 'Galaxy S24 Ultra com frete grátis',
        time: '3h atrás',
        isNew: false,
        color: AppColors.primary,
      ),
      _NotificationItem(
        icon: Icons.thumb_up_rounded,
        title: 'Seu achado tem 100 votos!',
        subtitle: 'Air Fryer Philips está bombando',
        time: '5h atrás',
        isNew: false,
        color: AppColors.savings,
      ),
      _NotificationItem(
        icon: Icons.timer_rounded,
        title: 'Oferta expirando em 1 hora!',
        subtitle: 'Tênis Nike Air Max salvo por você',
        time: '6h atrás',
        isNew: false,
        color: AppColors.coupon,
      ),
      _NotificationItem(
        icon: Icons.verified_rounded,
        title: 'Novo achado verificado',
        subtitle: 'iPhone 15 Pro Max — oferta confirmada',
        time: '8h atrás',
        isNew: false,
        color: AppColors.verified,
      ),
      _NotificationItem(
        icon: Icons.workspace_premium_rounded,
        title: 'Comissão de afiliado recebida!',
        subtitle: 'R\$ 300,00 creditado na sua conta',
        time: '12h atrás',
        isNew: false,
        color: const Color(0xFFD4AF37),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Alertas'),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.primary),
            label: const Text(
              'Marcar tudo',
              style: TextStyle(color: AppColors.primary, fontSize: 13),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: notif.isNew
                  ? AppColors.primary.withValues(alpha: 0.06)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: notif.isNew
                    ? AppColors.primary.withValues(alpha: 0.25)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: notif.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(notif.icon, color: notif.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notif.isNew ? FontWeight.w700 : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        notif.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      notif.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (notif.isNew) ...[
                      const SizedBox(height: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final bool isNew;
  final Color color;

  _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isNew,
    required this.color,
  });
}
