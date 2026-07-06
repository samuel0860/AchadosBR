import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../services/user_data_service.dart';
import '../auth/login_screen.dart';
import '../affiliate/affiliate_screen.dart';
import 'saved_deals_screen.dart';
import 'visit_history_screen.dart';
import 'alerts_config_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _themeService = ThemeService();
  final _userDataService = UserDataService();

  // Cores disponíveis para avatar
  static const _avatarColors = [
    '#7C3AED', '#EF4444', '#10B981', '#F59E0B',
    '#3B82F6', '#EC4899', '#D4AF37', '#14B8A6',
    '#F97316', '#8B5CF6',
  ];

  Color _hexColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cor do avatar',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Escolha uma cor para personalizar seu perfil',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: _avatarColors.map((hex) {
                  final color = _hexColor(hex);
                  final current =
                      _authService.currentUser?.avatarColor ?? '#7C3AED';
                  final isSelected = current == hex;
                  return GestureDetector(
                    onTap: () async {
                      await _authService.updateProfile(avatarColor: hex);
                      if (mounted) setState(() {});
                      setSheet(() {});
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                    color: color.withValues(alpha: 0.6),
                                    blurRadius: 12,
                                    spreadRadius: 2)
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 24)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final isAffiliate = _authService.isAffiliate;
    final savedCount = _userDataService.savedDealIds.length;
    final historyCount = _userDataService.visitHistory.length;
    final initial = user?.name.isNotEmpty == true
        ? user!.name[0].toUpperCase()
        : 'U';
    final avatarColor = _hexColor(user?.avatarColor ?? '#7C3AED');
    final accentColor = isAffiliate ? const Color(0xFFD4AF37) : AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── Header premium ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isAffiliate
                      ? [const Color(0xFF1A1200), const Color(0xFF0D0800), AppColors.background]
                      : [const Color(0xFF150930), const Color(0xFF0D0520), AppColors.background],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.6, 1],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // ─── AppBar mínima ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          if (Navigator.canPop(context))
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded,
                                  color: AppColors.textPrimary),
                              onPressed: () => Navigator.pop(context),
                            )
                          else
                            const SizedBox(width: 48),
                          const Spacer(),
                          const Text(
                            'Perfil',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded,
                                color: AppColors.textMuted),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen()),
                            ).then((_) => setState(() {})),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ─── Avatar com seletor de cor ──────────────────────────
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow atrás do avatar
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color: avatarColor.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5),
                              ],
                            ),
                          ),
                          // Avatar
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: avatarColor,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white),
                            ),
                          ),
                          // Ícone de câmera
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.background, width: 2),
                              ),
                              child: const Icon(Icons.color_lens_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(
                        duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 14),

                    // Nome
                    Text(
                      user?.name ?? 'Usuário',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary),
                    ).animate().fadeIn(delay: 100.ms),

                    // Email
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textMuted),
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 8),

                    // Badge de tipo
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: accentColor.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAffiliate
                                ? Icons.workspace_premium_rounded
                                : Icons.person_rounded,
                            color: accentColor,
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isAffiliate ? 'Afiliado Premium' : 'Cliente',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: accentColor),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    // Bio
                    if (user?.bio?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                        child: Text(
                          user!.bio!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textSecondary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ).animate().fadeIn(delay: 250.ms),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // ─── Estatísticas ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  _buildStat('$savedCount', 'Salvos',
                      Icons.bookmark_rounded, accentColor),
                  _buildStatDivider(),
                  _buildStat('$historyCount', 'Visitados',
                      Icons.history_rounded, accentColor),
                  _buildStatDivider(),
                  isAffiliate
                      ? _buildStat('12', 'Produtos',
                          Icons.inventory_2_rounded, accentColor)
                      : _buildStat('3', 'Avaliações',
                          Icons.star_rounded, accentColor),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          ),

          // ─── Card Painel Afiliado ─────────────────────────────────────────
          if (isAffiliate)
            SliverToBoxAdapter(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AffiliateScreen()),
                ),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A1F00), Color(0xFF1A1200)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.bar_chart_rounded,
                            color: Color(0xFFD4AF37), size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Painel do Afiliado',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFD4AF37))),
                            Text('Dashboard, vendas e comissões',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFFD4AF37)),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms),
            ),

          // ─── Menu ─────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('MINHA CONTA'),
                _buildMenuCard([
                  _MenuItemData(
                    icon: Icons.person_outline_rounded,
                    title: 'Editar Perfil',
                    subtitle: 'Nome, bio e avatar',
                    color: accentColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfileScreen()),
                    ).then((_) => setState(() {})),
                  ),
                  _MenuItemData(
                    icon: Icons.bookmark_outline_rounded,
                    title: 'Itens Salvos',
                    subtitle: '$savedCount achados salvos',
                    color: const Color(0xFF10B981),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SavedDealsScreen())),
                  ),
                  _MenuItemData(
                    icon: Icons.history_rounded,
                    title: 'Histórico de Visitas',
                    subtitle: 'Produtos visitados recentemente',
                    color: const Color(0xFF3B82F6),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const VisitHistoryScreen())),
                  ),
                  _MenuItemData(
                    icon: Icons.notifications_active_outlined,
                    title: 'Configurar Alertas',
                    subtitle: 'Categorias e frequência',
                    color: const Color(0xFFF59E0B),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AlertsConfigScreen())),
                  ),
                ]),

                _buildSectionHeader('PREFERÊNCIAS'),
                _buildMenuCard([
                  _MenuItemData(
                    icon: Icons.dark_mode_outlined,
                    title: 'Tema do App',
                    subtitle: _themeService.modeLabel,
                    color: const Color(0xFF8B5CF6),
                    onTap: () => _showThemeDialog(context),
                  ),
                  _MenuItemData(
                    icon: Icons.lock_outline_rounded,
                    title: 'Segurança',
                    subtitle: 'Alterar senha',
                    color: const Color(0xFFEF4444),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  _MenuItemData(
                    icon: Icons.info_outline_rounded,
                    title: 'Sobre o App',
                    subtitle: 'Versão 2.0.0 · AchadosBR',
                    color: AppColors.textMuted,
                    onTap: () => _showAboutAppDialog(context),
                  ),
                ]),

                const SizedBox(height: 12),
                _buildLogoutButton(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItemData> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(20) : Radius.zero,
                    bottom: i == items.length - 1
                        ? const Radius.circular(20)
                        : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
                              Text(item.subtitle,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textMuted, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
              if (i < items.length - 1)
                const Divider(
                    height: 1, color: AppColors.border, indent: 70),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStat(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary)),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() => Container(
        width: 1,
        height: 50,
        color: AppColors.border,
      );

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _confirmLogout(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.hot.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.hot.withValues(alpha: 0.2)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppColors.hot, size: 20),
                SizedBox(width: 10),
                Text('Sair da conta',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.hot)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              const Text('Tema do Aplicativo',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              ...AppThemeMode.values.map((mode) {
                final icons = {
                  AppThemeMode.dark: Icons.dark_mode_rounded,
                  AppThemeMode.light: Icons.light_mode_rounded,
                  AppThemeMode.system: Icons.phone_android_rounded,
                };
                final labels = {
                  AppThemeMode.dark: 'Escuro',
                  AppThemeMode.light: 'Claro',
                  AppThemeMode.system: 'Automático (sistema)',
                };
                return ListTile(
                  leading: Icon(icons[mode], color: AppColors.primary),
                  title: Text(labels[mode]!,
                      style:
                          const TextStyle(color: AppColors.textPrimary)),
                  trailing: _themeService.mode == mode
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary)
                      : null,
                  onTap: () async {
                    await _themeService.setMode(mode);
                    if (context.mounted) {
                      setModalState(() {});
                      setState(() {});
                      Navigator.pop(context);
                    }
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Alterar Senha',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
            'Para alterar sua senha, utilize a opção "Esqueci a senha" na tela de login.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'AchadosBR',
      applicationVersion: '2.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFFEF4444)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.local_fire_department_rounded,
            color: Colors.white, size: 32),
      ),
      children: const [
        Text('O melhor app de promoções do Brasil!',
            style: TextStyle(color: AppColors.textSecondary)),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800)),
        content: const Text('Tem certeza que deseja sair?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sair',
                style: TextStyle(
                    color: AppColors.hot, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
