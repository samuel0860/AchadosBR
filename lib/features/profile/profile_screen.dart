import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../features/affiliate/affiliate_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStats(),
                  const SizedBox(height: 20),
                  _buildInterests(),
                  const SizedBox(height: 20),
                  _buildAffiliateCard(context),
                  const SizedBox(height: 20),
                  _buildMenuItems(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C1D95), Color(0xFF1A1A2E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    gradient: AppGradients.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 48),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: const Icon(Icons.edit_rounded, size: 12, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'João Achados',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '@joaoachados · Membro desde jan/2024',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Hunter Expert',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        _statCard('42', 'Achados\nPostados', AppColors.primary),
        const SizedBox(width: 10),
        _statCard('3.2K', 'Votos\nRecebidos', AppColors.savings),
        const SizedBox(width: 10),
        _statCard('R\$ 12K', 'Economia\nGerada', AppColors.coupon),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterests() {
    final interests = [
      (Icons.devices_rounded, 'Eletrônicos'),
      (Icons.sports_esports_rounded, 'Jogos'),
      (Icons.checkroom_rounded, 'Moda'),
      (Icons.home_rounded, 'Casa'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Meus interesses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Editar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: interests.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.$1, color: AppColors.primary, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAffiliateCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AffiliateScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1508), Color(0xFF2A2010)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Color(0xFF1A1000), size: 26),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Painel de Afiliado',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Ver comissões, vendas e relatórios',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A7A5A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFD4AF37),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final items = [
      _MenuItem(icon: Icons.bookmark_rounded, label: 'Achados Salvos', color: AppColors.coupon, onTap: () {}),
      _MenuItem(icon: Icons.history_rounded, label: 'Histórico de Visitas', color: AppColors.primary, onTap: () {}),
      _MenuItem(icon: Icons.notifications_active_rounded, label: 'Configurar Alertas', color: AppColors.savings, onTap: () {}),
      _MenuItem(icon: Icons.shield_rounded, label: 'Segurança e Privacidade', color: AppColors.verified, onTap: () {}),
      _MenuItem(icon: Icons.star_rounded, label: 'Avaliar o App', color: AppColors.hot, onTap: () {}),
      _MenuItem(icon: Icons.group_add_rounded, label: 'Convidar Amigos', color: AppColors.primary, onTap: () {}),
      _MenuItem(icon: Icons.help_outline_rounded, label: 'Ajuda e Suporte', color: AppColors.textSecondary, onTap: () {}),
      _MenuItem(
        icon: Icons.logout_rounded,
        label: 'Sair da conta',
        color: AppColors.hot,
        onTap: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Sair da conta?',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
              ),
              content: const Text(
                'Você precisará fazer login novamente para acessar o app.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Sair', style: TextStyle(color: AppColors.hot, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          );
          if (confirm == true && context.mounted) {
            final auth = AuthService();
            await auth.logout();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        },
      ),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                ListTile(
                  onTap: item.onTap,
                  tileColor: Colors.transparent,
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: i == items.length - 1 ? AppColors.hot : AppColors.textPrimary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 60, color: AppColors.border),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
