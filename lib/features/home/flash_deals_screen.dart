import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../data/mock_deals.dart';
import '../../models/boost_model.dart';
import '../../models/deal.dart';
import '../../services/boost_service.dart';
import '../../shared/widgets/deal_card.dart';
import '../deal_detail/deal_detail_screen.dart';

/// Tela de Ofertas Relâmpago — acessada pelo banner da home
class FlashDealsScreen extends StatelessWidget {
  const FlashDealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final boostService = BoostService();
    boostService.seedDemo();

    // Ordena: boosted primeiro (por prioridade), depois por desconto
    final boostedIds = boostService.boostedDealIds;
    final allDeals = List<Deal>.from(mockDeals);

    allDeals.sort((a, b) {
      final aPriority = boostService.boostFor(a.id)?.priority ?? 0;
      final bPriority = boostService.boostFor(b.id)?.priority ?? 0;
      if (bPriority != aPriority) return bPriority.compareTo(aPriority);
      return b.discountPercent.compareTo(a.discountPercent);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── AppBar animada com gradiente ──────────────────────────────────
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF4C1D95),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFEF4444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'Ofertas Relâmpago',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${allDeals.length} promoções disponíveis hoje',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Badge informativo de produtos patrocinados ─────────────────────
          if (boostedIds.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        color: Color(0xFFD4AF37), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Produtos em destaque aparecem primeiro. Saiba mais.',
                        style: TextStyle(
                            fontSize: 12, color: Color(0xFFD4AF37)),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(),
            ),

          // ─── Lista de deals ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 100), // Removed horizontal 16
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final deal = allDeals[index];
                  final boost = boostService.boostFor(deal.id);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Stack(
                      children: [
                        DealCard(
                          deal: deal,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => DealDetailScreen(deal: deal)),
                          ),
                        ),
                        // Badge de boost
                        if (boost != null)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: _buildBoostBadge(boost),
                          ),
                      ],
                    ).animate().fadeIn(
                          delay: Duration(milliseconds: 60 * index)),
                  );
                },
                childCount: allDeals.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoostBadge(BoostModel boost) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (boost.plan) {
      case BoostPlan.premium:
        badgeColor = const Color(0xFFD4AF37);
        badgeText = 'TOP #1';
        badgeIcon = Icons.workspace_premium_rounded;
      case BoostPlan.pro:
        badgeColor = const Color(0xFF3B82F6);
        badgeText = 'DESTAQUE';
        badgeIcon = Icons.star_rounded;
      case BoostPlan.basico:
        badgeColor = const Color(0xFF10B981);
        badgeText = 'PATROCINADO';
        badgeIcon = Icons.rocket_launch_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: badgeColor.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: Colors.white, size: 11),
          const SizedBox(width: 3),
          Text(
            badgeText,
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
