import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../data/mock_deals.dart';
import '../../services/auth_service.dart';
import '../../shared/widgets/deal_card.dart';
import '../../features/deal_detail/deal_detail_screen.dart';
import '../../features/home/all_deals_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/affiliate/product_form_screen.dart';
import '../../features/affiliate/affiliate_page_screen.dart';

/// Tela inicial exclusiva para AFILIADOS
class AffiliateHomeScreen extends StatefulWidget {
  const AffiliateHomeScreen({super.key});

  @override
  State<AffiliateHomeScreen> createState() => _AffiliateHomeScreenState();
}

class _AffiliateHomeScreenState extends State<AffiliateHomeScreen> {
  final _authService = AuthService();
  final _scrollController = ScrollController();
  bool _showElevation = false;

  // Carrossel de métricas do afiliado
  int _metricIndex = 0;
  final _metrics = const [
    _MetricCard('Cliques no link hoje', '127', '+23 hoje', Icons.touch_app_rounded, Color(0xFFD4AF37)),
    _MetricCard('Taxa de conversão', '4,7%', 'Média dos cliques', Icons.trending_up_rounded, Color(0xFF3B82F6)),
  ];

  // Carrossel social proof (comissões)
  int _proofIndex = 0;
  final _proofMessages = const [
    ('Samuel', 'acabou de ganhar', 'R\$ 400 em comissão', Icons.emoji_events_rounded),
    ('Maria', 'realizou mais uma venda e faturou', 'R\$ 120', Icons.shopping_cart_checkout_rounded),
    ('João', 'faturou', 'R\$ 1.200 hoje', Icons.trending_up_rounded),
    ('Ana', 'atingiu 50 vendas este mês', null, Icons.workspace_premium_rounded),
    ('Ricardo', 'ganhou comissão de', 'R\$ 680 esta semana', Icons.account_balance_wallet_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() => _showElevation = _scrollController.offset > 10);
    });

    // Auto-advance proof banner
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 3500));
      if (!mounted) return false;
      setState(() => _proofIndex = (_proofIndex + 1) % _proofMessages.length);
      return true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final initial = (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'A';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ─── AppBar dourada do afiliado ─────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: _showElevation
                ? const Color(0xFF0A0800).withValues(alpha: 0.97)
                : Colors.transparent,
            elevation: 0,
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF5D77E), Color(0xFFC8922A)],
              ).createShader(bounds),
              child: const Text(
                'AchouAchado',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            actions: [
              // Minha Vitrine
              GestureDetector(
                onTap: () {
                  final u = _authService.currentUser;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AffiliatePageScreen(
                        affiliateId: u?.id ?? 'me',
                        affiliateName: u?.name ?? 'Minha Vitrine',
                        isOwner: true,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.storefront_rounded,
                          color: Color(0xFF1A0A00), size: 14),
                      SizedBox(width: 5),
                      Text(
                        'Vitrine',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A0A00),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Notificações
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1200),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.25)),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_rounded,
                          color: Color(0xFFD4AF37), size: 22),
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: AppColors.hot, shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Avatar
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A0A00)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ─── Boas-vindas ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge premium
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Afiliado Premium',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A0A00),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Olá, ${user?.name.split(' ').first ?? 'Afiliado'}!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Text(
                    'Veja seus resultados',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),
            ),
          ),

          // ─── Carrossel de métricas ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
              child: SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _metrics.length,
                  itemBuilder: (context, i) => _buildMetricCard(_metrics[i], i),
                ),
              ),
            ),
          ),

          // ─── Carrossel social proof (afiliado) ──────────────────────────────
          SliverToBoxAdapter(
            child: _buildAffiliateProof(),
          ),

          // ─── Feed de achados (para compartilhar) ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                children: [
                  // ─── Header "Achados para Divulgar" ───────────────────────────
                  Row(
                    children: [
                      const Text(
                        'Achados para Divulgar',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllDealsScreen(),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'Ver todos',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD4AF37)),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 16),
                  // ─── Botão PROMOVER em destaque ──────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1200), Color(0xFF2E2000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.rocket_launch_rounded,
                                  color: Color(0xFF1A0A00), size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Promova e Fature',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFD4AF37),
                                    ),
                                  ),
                                  Text(
                                    'Compartilhe o link e ganhe comissão',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF8A7A5A)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductFormScreen(),
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_rounded,
                                    color: Color(0xFF1A0A00), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Novo Produto para Promover',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1A0A00),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final deal = mockDeals[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DealCard(
                      deal: deal,
                      heroTagPrefix: 'affiliate_',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => DealDetailScreen(
                              deal: deal,
                              heroTagPrefix: 'affiliate_',
                            )),
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)),
                  );
                },
                childCount: mockDeals.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(_MetricCard m, int i) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: m.color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
              color: m.color.withValues(alpha: 0.06),
              blurRadius: 10,
              spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(m.icon, color: m.color, size: 17),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.savings.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  m.change,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.savings),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(m.value,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: m.color)),
              Text(m.label,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: i * 80)).fadeIn().slideX(begin: 0.1);
  }

  Widget _buildAffiliateProof() {
    final msg = _proofMessages[_proofIndex];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_proofIndex),
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1200), Color(0xFF2A1F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(msg.$4, color: const Color(0xFFD4AF37), size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(fontSize: 12),
                  children: [
                    TextSpan(
                      text: '${msg.$1} ',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFD4AF37)),
                    ),
                    TextSpan(
                      text: '${msg.$2} ',
                      style:
                          const TextStyle(color: AppColors.textSecondary),
                    ),
                    if (msg.$3 != null)
                      TextSpan(
                        text: msg.$3,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFD4AF37)),
                      ),
                  ],
                ),
              ),
            ),
            // Dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_proofMessages.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(left: 3),
                  width: i == _proofIndex ? 12 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i == _proofIndex
                        ? const Color(0xFFD4AF37)
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _MetricCard {
  final String label;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _MetricCard(
      this.label, this.value, this.change, this.icon, this.color);
}
