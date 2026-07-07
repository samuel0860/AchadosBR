import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../app/theme.dart';
import '../../../models/boost_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/boost_service.dart';

/// Tela de compra de impulsionamento para afiliados
class BoostScreen extends StatefulWidget {
  final String productId;
  final String productTitle;

  const BoostScreen({
    super.key,
    required this.productId,
    required this.productTitle,
  });

  @override
  State<BoostScreen> createState() => _BoostScreenState();
}

class _BoostScreenState extends State<BoostScreen> {
  final _boostService = BoostService();
  final _authService = AuthService();
  BoostPlan? _selectedPlan;
  bool _isLoading = false;

  static const _plans = [
    _PlanInfo(
      plan: BoostPlan.basico,
      name: 'Starter',
      subtitle: 'Comece a divulgar',
      price: 'R\$ 19,90',
      oldPrice: 'R\$ 29,90',
      period: '7 dias',
      color: Color(0xFF10B981),
      icon: Icons.rocket_launch_rounded,
      perks: [
        'Destaque acima dos não impulsionados',
        'Badge "Em Alta" no feed',
        'Relatório básico de cliques',
        'Suporte por e-mail',
      ],
    ),
    _PlanInfo(
      plan: BoostPlan.pro,
      name: 'Pro',
      subtitle: 'Mais visibilidade',
      price: 'R\$ 59,90',
      oldPrice: 'R\$ 79,90',
      period: '30 dias',
      color: Color(0xFF3B82F6),
      icon: Icons.star_rounded,
      perks: [
        'Posição de destaque no feed',
        'Badge "Patrocinado" animado',
        'Aparece no banner "Mais Vendidos"',
        'Relatório detalhado de conversão',
        'Compartilhamento automático',
        'Suporte prioritário',
      ],
    ),
    _PlanInfo(
      plan: BoostPlan.premium,
      name: 'Premium TOP',
      subtitle: 'Máxima exposição',
      price: 'R\$ 149,90',
      oldPrice: 'R\$ 199,90',
      period: '30 dias',
      color: Color(0xFFD4AF37),
      icon: Icons.workspace_premium_rounded,
      perks: [
        '🥇 Topo absoluto do feed 24h/dia',
        'Badge dourado exclusivo "TOP #1"',
        'Destaque no banner Relâmpago',
        'Notificação push para +10k usuários',
        'Relatório completo com ROI',
        'Link de afiliado rastreado',
        'Gerente de conta dedicado',
        'Reembolso se não gerar cliques',
      ],
      isHighlight: true,
    ),
  ];

  Future<void> _purchase() async {
    if (_selectedPlan == null) return;
    setState(() => _isLoading = true);

    final success = await _boostService.purchaseBoost(
      productId: widget.productId,
      affiliateId: _authService.currentUser?.id ?? '',
      plan: _selectedPlan!,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.rocket_launch_rounded,
                    color: Color(0xFF1A0A00), size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Produto Impulsionado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'Seu produto já aparece em destaque no feed. Acompanhe os cliques em tempo real no Painel.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Perfeito! Ver resultados',
                      style: TextStyle(
                          color: Color(0xFF1A0A00),
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Header premium ──────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1200), Color(0xFF0D0A00)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A1F00),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF3A2F00)),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Color(0xFFD4AF37), size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Impulsionar Produto',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFD4AF37)),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.hot.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.hot.withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            '🔥 Oferta limitada',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.hot),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Produto selecionado
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF241A00),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFD4AF37)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(Icons.inventory_2_rounded,
                                color: Color(0xFF1A0A00), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Produto a impulsionar',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF8A7A5A))),
                                Text(
                                  widget.productTitle,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFD4AF37)),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.savings, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 300.ms),

          // ─── Título seção ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Row(
              children: [
                const Text(
                  'Escolha seu plano',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.savings.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.savings.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    'Até 25% OFF',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.savings),
                  ),
                ),
              ],
            ),
          ),

          // ─── Lista de planos ─────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _plans.length,
              itemBuilder: (context, i) => _buildPlanCard(_plans[i], i),
            ),
          ),

          // ─── Botão de compra ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: const Border(
                  top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: GestureDetector(
              onTap: _selectedPlan == null || _isLoading ? null : _purchase,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: _selectedPlan != null
                      ? const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                        )
                      : null,
                  color: _selectedPlan == null ? AppColors.surfaceElevated : null,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedPlan != null
                        ? const Color(0xFFD4AF37)
                        : AppColors.border,
                  ),
                  boxShadow: _selectedPlan != null
                      ? [
                          BoxShadow(
                            color:
                                const Color(0xFFD4AF37).withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _selectedPlan != null
                                  ? Icons.rocket_launch_rounded
                                  : Icons.touch_app_rounded,
                              color: _selectedPlan != null
                                  ? const Color(0xFF1A0A00)
                                  : AppColors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedPlan != null
                                  ? 'Impulsionar agora — ${_plans.firstWhere((p) => p.plan == _selectedPlan).price}'
                                  : 'Selecione um plano acima',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _selectedPlan != null
                                    ? const Color(0xFF1A0A00)
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(_PlanInfo info, int i) {
    final isSelected = _selectedPlan == info.plan;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = info.plan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    info.color.withValues(alpha: 0.12),
                    info.color.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? info.color
                : info.isHighlight
                    ? info.color.withValues(alpha: 0.5)
                    : AppColors.border,
            width: isSelected ? 2 : info.isHighlight ? 1.5 : 1,
          ),
          boxShadow: isSelected || info.isHighlight
              ? [
                  BoxShadow(
                    color: info.color.withValues(
                        alpha: isSelected ? 0.2 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header do plano ─────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: info.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                          color: info.color.withValues(alpha: 0.3)),
                    ),
                    child: Icon(info.icon, color: info.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              info.name,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: info.color),
                            ),
                            if (info.isHighlight) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      info.color,
                                      info.color.withValues(alpha: 0.7)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('⭐ MAIS POPULAR',
                                    style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF1A0A00))),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          info.subtitle,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  // Preço
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (info.oldPrice != null)
                        Text(
                          info.oldPrice!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        info.price,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: info.color),
                      ),
                      Text(
                        '/ ${info.period}',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  // Radio button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? info.color : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? info.color : AppColors.border,
                        width: 2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color:
                                      info.color.withValues(alpha: 0.4),
                                  blurRadius: 8)
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 14)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // ─── Divisor ─────────────────────────────────────────────────
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      info.color.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // ─── Benefícios ───────────────────────────────────────────────
              ...info.perks.map(
                (perk) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: info.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check_rounded,
                            color: info.color, size: 11),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          perk,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate(delay: Duration(milliseconds: i * 100)).fadeIn().slideY(begin: 0.08),
    );
  }
}

class _PlanInfo {
  final BoostPlan plan;
  final String name;
  final String subtitle;
  final String price;
  final String? oldPrice;
  final String period;
  final Color color;
  final IconData icon;
  final List<String> perks;
  final bool isHighlight;

  const _PlanInfo({
    required this.plan,
    required this.name,
    required this.subtitle,
    required this.price,
    this.oldPrice,
    required this.period,
    required this.color,
    required this.icon,
    required this.perks,
    this.isHighlight = false,
  });
}
