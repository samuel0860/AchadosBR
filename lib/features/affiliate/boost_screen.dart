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
      name: 'Básico',
      price: 'R\$ 29,90',
      period: '7 dias',
      color: Color(0xFF10B981),
      icon: Icons.rocket_launch_rounded,
      perks: [
        'Aparece acima dos não impulsionados',
        'Badge "Destaque" no feed',
        'Relatório de cliques',
      ],
    ),
    _PlanInfo(
      plan: BoostPlan.pro,
      name: 'Pro',
      price: 'R\$ 79,90',
      period: '30 dias',
      color: Color(0xFF3B82F6),
      icon: Icons.star_rounded,
      perks: [
        'Posição de destaque no feed',
        'Badge "Patrocinado" animado',
        'Aparece no banner "Mais Vendidos"',
        'Relatório detalhado',
      ],
    ),
    _PlanInfo(
      plan: BoostPlan.premium,
      name: 'Premium TOP',
      price: 'R\$ 199,90',
      period: '30 dias',
      color: Color(0xFFD4AF37),
      icon: Icons.workspace_premium_rounded,
      perks: [
        '🥇 Topo absoluto do feed',
        'Badge dourado "TOP #1"',
        'Destaque no banner Relâmpago',
        'Notificação push para usuários',
        'Relatório completo com conversões',
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.savings.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.savings, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Impulsionamento ativado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Seu produto agora aparece em destaque no feed dos clientes.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.savings,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Perfeito!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Impulsionar Produto',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          // Header do produto
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.inventory_2_rounded,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Produto selecionado',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      Text(
                        widget.productTitle,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          // Escolha o plano
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ESCOLHA O PLANO DE DESTAQUE',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 1),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _plans.length,
              itemBuilder: (context, i) => _buildPlanCard(_plans[i], i),
            ),
          ),

          // Botão de compra
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _selectedPlan == null || _isLoading ? null : _purchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedPlan != null
                      ? const Color(0xFFD4AF37)
                      : AppColors.border,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: _selectedPlan != null ? 4 : 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _selectedPlan != null
                            ? 'Confirmar — ${_plans.firstWhere((p) => p.plan == _selectedPlan).price}'
                            : 'Selecione um plano',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _selectedPlan != null
                              ? const Color(0xFF1A0A00)
                              : AppColors.textMuted,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? info.color.withValues(alpha: 0.08)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? info.color
                : info.isHighlight
                    ? info.color.withValues(alpha: 0.4)
                    : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: info.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(info.icon, color: info.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(info.name,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: info.color)),
                          if (info.isHighlight) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: info.color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('MAIS POPULAR',
                                  style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF1A0A00))),
                            ),
                          ],
                        ],
                      ),
                      Text(info.period,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(info.price,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: info.color)),
                    Text('/${info.period}',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? info.color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? info.color : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...info.perks.map(
              (perk) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: info.color, size: 14),
                    const SizedBox(width: 6),
                    Text(perk,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: i * 80)).fadeIn().slideY(begin: 0.1),
    );
  }
}

class _PlanInfo {
  final BoostPlan plan;
  final String name;
  final String price;
  final String period;
  final Color color;
  final IconData icon;
  final List<String> perks;
  final bool isHighlight;

  const _PlanInfo({
    required this.plan,
    required this.name,
    required this.price,
    required this.period,
    required this.color,
    required this.icon,
    required this.perks,
    this.isHighlight = false,
  });
}
