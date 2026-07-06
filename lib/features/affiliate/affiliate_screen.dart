import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';

class AffiliateScreen extends StatefulWidget {
  const AffiliateScreen({super.key});

  @override
  State<AffiliateScreen> createState() => _AffiliateScreenState();
}

class _AffiliateScreenState extends State<AffiliateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _chartPeriod = 'semanal';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Mock Data ─────────────────────────────────────────────────────────────

  final _topProducts = [
    _ProductStat('iPhone 15 Pro Max', 48, 14_400.0, Icons.smartphone_rounded),
    _ProductStat('PlayStation 5 Slim', 31, 9_920.0, Icons.sports_esports_rounded),
    _ProductStat('Galaxy Tab S9 FE', 27, 4_590.0, Icons.tablet_rounded),
    _ProductStat('Air Fryer Philips', 19, 1_710.0, Icons.kitchen_rounded),
    _ProductStat('Nike Air Max 270', 14, 1_120.0, Icons.directions_run_rounded),
  ];

  final _salesHistory = [
    _SaleRecord('iPhone 15 Pro Max', 'Samuel O.', 6799.0, 300.0, '06/07/2026 14:32', true),
    _SaleRecord('PS5 Slim Bundle', 'Juliana R.', 3199.0, 140.0, '06/07/2026 11:10', true),
    _SaleRecord('Galaxy Tab S9', 'Carlos M.', 1699.0, 75.0, '05/07/2026 18:47', true),
    _SaleRecord('Air Fryer Philips', 'Beatriz S.', 349.90, 15.0, '05/07/2026 09:22', true),
    _SaleRecord('Nike Air Max', 'Rafael T.', 399.90, 17.50, '04/07/2026 16:05', false),
    _SaleRecord('Kit Perfumes', 'Larissa F.', 649.90, 28.0, '04/07/2026 12:33', true),
    _SaleRecord('iPhone 15 Pro Max', 'Thiago N.', 6799.0, 300.0, '03/07/2026 20:15', true),
    _SaleRecord('Galaxy Tab S9', 'Amanda C.', 1699.0, 75.0, '03/07/2026 15:40', false),
  ];

  final _payments = [
    _PaymentRecord('R\$ 1.250,00', '01/07/2026', 'Pago', AppColors.savings),
    _PaymentRecord('R\$ 890,00', '15/06/2026', 'Pago', AppColors.savings),
    _PaymentRecord('R\$ 2.100,00', '01/06/2026', 'Pago', AppColors.savings),
    _PaymentRecord('R\$ 450,00', '15/05/2026', 'Pago', AppColors.savings),
    _PaymentRecord('R\$ 1.680,00', '01/05/2026', 'Pago', AppColors.savings),
  ];

  final Map<String, List<double>> _chartData = {
    'diário': [120, 280, 190, 350, 420, 310, 490],
    'semanal': [890, 1240, 760, 1580, 920, 1350, 1100],
    'mensal': [4200, 5800, 3900, 7200, 6100, 8400, 5500],
  };

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(),
          _buildTabBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDashboard(),
            _buildSalesTab(),
            _buildPaymentsTab(),
            _buildReportsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1000), Color(0xFF0A0A14)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
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
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      color: Color(0xFF1A1000), size: 26),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Painel de Afiliado',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                    Text(
                      'Estatísticas em tempo real',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A7A5A)),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.savings.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.savings.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 7, color: AppColors.savings),
                      SizedBox(width: 5),
                      Text(
                        'Ao vivo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.savings,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        TabBar(
          controller: _tabController,
          isScrollable: false,
          labelColor: const Color(0xFFD4AF37),
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          indicator: UnderlineTabIndicator(
            borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 2.5),
            borderRadius: BorderRadius.circular(2),
          ),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded, size: 18), text: 'Dashboard'),
            Tab(icon: Icon(Icons.receipt_long_rounded, size: 18), text: 'Vendas'),
            Tab(icon: Icon(Icons.account_balance_wallet_rounded, size: 18), text: 'Pagamentos'),
            Tab(icon: Icon(Icons.bar_chart_rounded, size: 18), text: 'Relatórios'),
          ],
        ),
      ),
    );
  }

  // ─── Dashboard ─────────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          _buildKPIGrid(currency),
          const SizedBox(height: 20),
          // Performance Chart
          _buildChartSection(),
          const SizedBox(height: 20),
          // Top Products
          _buildTopProducts(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(NumberFormat currency) {
    final kpis = [
      _KPI('Comissões Totais', 'R\$ 15.670', '+12%', Icons.emoji_events_rounded, const Color(0xFFD4AF37), true),
      _KPI('Vendas Realizadas', '148', '+8', Icons.shopping_cart_checkout_rounded, AppColors.savings, true),
      _KPI('Taxa de Conversão', '4,7%', '+0.3%', Icons.trending_up_rounded, AppColors.verified, true),
      _KPI('Ticket Médio', 'R\$ 1.890', '+R\$120', Icons.price_check_rounded, AppColors.coupon, true),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: kpis.asMap().entries.map((e) {
        final index = e.key;
        final kpi = e.value;
        return _buildKPICard(kpi)
            .animate(delay: (index * 80).ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0);
      }).toList(),
    );
  }

  Widget _buildKPICard(_KPI kpi) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kpi.color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: kpi.color.withValues(alpha: 0.06),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: kpi.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(kpi.icon, color: kpi.color, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.savings.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_upward_rounded,
                        size: 10, color: AppColors.savings),
                    Text(
                      kpi.change,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.savings,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kpi.value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: kpi.color,
                ),
              ),
              Text(
                kpi.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    final data = _chartData[_chartPeriod]!;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final labels = {
      'diário': ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
      'semanal': ['S1', 'S2', 'S3', 'S4', 'S5', 'S6', 'S7'],
      'mensal': ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul'],
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Desempenho',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              ...['diário', 'semanal', 'mensal'].map((p) {
                final isSelected = _chartPeriod == p;
                return GestureDetector(
                  onTap: () => setState(() => _chartPeriod = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD4AF37).withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD4AF37).withValues(alpha: 0.5)
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      p[0].toUpperCase() + p.substring(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFFD4AF37)
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.asMap().entries.map((e) {
                final index = e.key;
                final value = e.value;
                final heightFraction = value / maxVal;
                final label = labels[_chartPeriod]![index];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      value >= 1000
                          ? 'R\$${(value / 1000).toStringAsFixed(1)}k'
                          : 'R\$${value.toInt()}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 32,
                      height: 100 * heightFraction,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD4AF37),
                            const Color(0xFFC8922A).withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    )
                        .animate(delay: (index * 60).ms)
                        .slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOut),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
  }

  Widget _buildTopProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Produtos mais vendidos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._topProducts.asMap().entries.map((e) {
          final index = e.key;
          final p = e.value;
          return _buildProductRankItem(index + 1, p)
              .animate(delay: (index * 60).ms)
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.05, end: 0);
        }),
      ],
    );
  }

  Widget _buildProductRankItem(int rank, _ProductStat p) {
    final rankColors = [
      const Color(0xFFD4AF37),
      const Color(0xFFC0C0C0),
      const Color(0xFFCD7F32),
      AppColors.textMuted,
      AppColors.textMuted,
    ];
    final color = rankColors[rank - 1];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(p.icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${p.units} vendas',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(p.commission),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.savings,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Sales Tab ─────────────────────────────────────────────────────────────

  Widget _buildSalesTab() {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1508), Color(0xFF0A0A14)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem('Total', 'R\$ 21.895', Icons.monetization_on_rounded),
                _vDivider(),
                _summaryItem('Comissão', 'R\$ 950,50', Icons.emoji_events_rounded),
                _vDivider(),
                _summaryItem('Vendas', '148', Icons.shopping_bag_rounded),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: 20),
          const Text(
            'Histórico de Vendas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._salesHistory.asMap().entries.map((e) {
            final i = e.key;
            final sale = e.value;
            return _buildSaleItem(sale, currency)
                .animate(delay: (i * 60).ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFFD4AF37),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF8A7A5A)),
        ),
      ],
    );
  }

  Widget _vDivider() {
    return Container(width: 1, height: 40, color: const Color(0xFFD4AF37).withValues(alpha: 0.2));
  }

  Widget _buildSaleItem(_SaleRecord sale, NumberFormat currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.receipt_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.product,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${sale.buyer} · ${sale.date}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${currency.format(sale.commission)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.savings,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: (sale.approved ? AppColors.savings : AppColors.coupon)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  sale.approved ? 'Aprovado' : 'Pendente',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: sale.approved ? AppColors.savings : AppColors.coupon,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Payments Tab ─────────────────────────────────────────────────────────

  Widget _buildPaymentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1508), Color(0xFF2A2010)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        color: Color(0xFFD4AF37), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Saldo disponível',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A7A5A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'R\$ 2.340,50',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Próximo pagamento: 15/07/2026',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A7A5A)),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send_rounded, color: Color(0xFF1A1000), size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Solicitar saque',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1000),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, end: 0),
          const SizedBox(height: 24),
          const Text(
            'Histórico de Pagamentos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ..._payments.asMap().entries.map((e) {
            final i = e.key;
            final pay = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.savings.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.check_circle_rounded,
                        color: AppColors.savings, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pagamento recebido',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          pay.date,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        pay.amount,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.savings,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.savings.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pay.status,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.savings,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: (i * 60).ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
          }),
        ],
      ),
    );
  }

  // ─── Reports Tab ──────────────────────────────────────────────────────────

  Widget _buildReportsTab() {
    final reports = [
      _Report('Relatório Mensal — Julho 2026', 'Comissões: R\$ 2.340,50 · Vendas: 31', Icons.calendar_month_rounded, AppColors.primary),
      _Report('Relatório Mensal — Junho 2026', 'Comissões: R\$ 4.890,00 · Vendas: 58', Icons.calendar_month_rounded, AppColors.savings),
      _Report('Relatório Mensal — Maio 2026', 'Comissões: R\$ 3.210,00 · Vendas: 42', Icons.calendar_month_rounded, AppColors.coupon),
      _Report('Relatório de Produtos Topo', 'iPhone 15 Pro Max lidera com 48 vendas', Icons.emoji_events_rounded, const Color(0xFFD4AF37)),
      _Report('Análise de Conversão', 'Taxa média: 4,7% · Acima da média', Icons.analytics_rounded, AppColors.verified),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export row
          Row(
            children: [
              const Text(
                'Relatórios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_rounded, color: Color(0xFF1A1000), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Exportar',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          ...reports.asMap().entries.map((e) {
            final i = e.key;
            final r = e.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: r.color.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: r.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(r.icon, color: r.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          r.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.open_in_new_rounded,
                    color: AppColors.textMuted,
                    size: 16,
                  ),
                ],
              ),
            ).animate(delay: (i * 80).ms).fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
          }),
        ],
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _KPI {
  final String label;
  final String value;
  final String change;
  final IconData icon;
  final Color color;
  final bool isPositive;
  const _KPI(this.label, this.value, this.change, this.icon, this.color, this.isPositive);
}

class _ProductStat {
  final String name;
  final int units;
  final double commission;
  final IconData icon;
  const _ProductStat(this.name, this.units, this.commission, this.icon);
}

class _SaleRecord {
  final String product;
  final String buyer;
  final double amount;
  final double commission;
  final String date;
  final bool approved;
  const _SaleRecord(this.product, this.buyer, this.amount, this.commission, this.date, this.approved);
}

class _PaymentRecord {
  final String amount;
  final String date;
  final String status;
  final Color color;
  const _PaymentRecord(this.amount, this.date, this.status, this.color);
}

class _Report {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _Report(this.title, this.subtitle, this.icon, this.color);
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _StickyTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          tabBar,
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}
