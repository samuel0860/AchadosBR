import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import 'product_manager_screen.dart';

class AffiliateScreen extends StatefulWidget {
  const AffiliateScreen({super.key});

  @override
  State<AffiliateScreen> createState() => _AffiliateScreenState();
}

class _AffiliateScreenState extends State<AffiliateScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _chartPeriod = 'semanal';

  // Manual sales tracking
  final List<Map<String, dynamic>> _manualSales = [
    {'product': 'iPhone 15 Pro Max', 'amount': 6799.0, 'commission': 300.0, 'date': '06/07/2026'},
    {'product': 'PS5 Slim Bundle', 'amount': 3199.0, 'commission': 140.0, 'date': '05/07/2026'},
  ];
  final int _totalLinkClicks = 4821;
  final int _todayLinkClicks = 127;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  final Map<String, List<double>> _chartData = {
    'diário': [120, 280, 190, 350, 420, 310, 490],
    'semanal': [890, 1240, 760, 1580, 920, 1350, 1100],
    'mensal': [4200, 5800, 3900, 7200, 6100, 8400, 5500],
  };

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(),
          _buildTabBar(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLinksAndSalesTab(),
            _buildReportsTab(),
            ProductManagerScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      backgroundColor: context.appColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.appColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.appColors.border),
          ),
          child: Icon(Icons.arrow_back_rounded, color: context.appColors.textPrimary, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1000), Color(0xFF0A0A14)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 60, 20, 16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFD4AF37).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.workspace_premium_rounded,
                      color: Color(0xFF1A1000), size: 26),
                ),
                SizedBox(width: 14),
                Column(
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
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.savings.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.savings.withValues(alpha: 0.4)),
                  ),
                  child: Row(
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
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: Color(0xFFD4AF37),
          unselectedLabelColor: context.appColors.textMuted,
          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Color(0xFFD4AF37), width: 2.5),
            borderRadius: BorderRadius.circular(2),
          ),
          tabs: const [
            Tab(icon: Icon(Icons.link_rounded, size: 18), text: 'Links & Vendas'),
            Tab(icon: Icon(Icons.bar_chart_rounded, size: 18), text: 'Relatórios'),
            Tab(icon: Icon(Icons.inventory_2_rounded, size: 18), text: 'Produtos'),
          ],
        ),
      ),
    );
  }

  // ─── Dashboard ─────────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Cards
          _buildKPIGrid(currency),
          SizedBox(height: 20),
          // Promote Button
          _buildPromoteButton(),
          SizedBox(height: 20),
          // Performance Chart
          _buildChartSection(),
          SizedBox(height: 20),
          // Top Products
          _buildTopProducts(),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildKPIGrid(NumberFormat currency) {
    final kpis = [
      _KPI('Comissões Totais', 'R\$ 15.670', '+12%', Icons.emoji_events_rounded, Color(0xFFD4AF37), true),
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
      physics: NeverScrollableScrollPhysics(),
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
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.surfaceElevated,
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
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.savings.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward_rounded,
                        size: 10, color: AppColors.savings),
                    Text(
                      kpi.change,
                      style: TextStyle(
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
                style: TextStyle(
                  fontSize: 11,
                  color: context.appColors.textMuted,
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Desempenho',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.appColors.textPrimary,
                ),
              ),
              Spacer(),
              ...['diário', 'semanal', 'mensal'].map((p) {
                final isSelected = _chartPeriod == p;
                return GestureDetector(
                  onTap: () => setState(() => _chartPeriod = p),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    margin: EdgeInsets.only(left: 6),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFFD4AF37).withValues(alpha: 0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFFD4AF37).withValues(alpha: 0.5)
                            : context.appColors.border,
                      ),
                    ),
                    child: Text(
                      p[0].toUpperCase() + p.substring(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Color(0xFFD4AF37)
                            : context.appColors.textMuted,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 20),
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
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: context.appColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 4),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      width: 32,
                      height: 100 * heightFraction,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFD4AF37),
                            Color(0xFFC8922A).withValues(alpha: 0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    )
                        .animate(delay: (index * 60).ms)
                        .slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOut),
                    SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: context.appColors.textMuted,
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

  Widget _buildPromoteButton() {
    return GestureDetector(
      onTap: () => _showBoostPlansDialog(),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A1508), Color(0xFF2A2010)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Color(0xFFD4AF37).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFD4AF37).withValues(alpha: 0.1),
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
                gradient: LinearGradient(
                  colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.rocket_launch_rounded, color: Color(0xFF1A1000), size: 24),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promover Produto',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Destaque seu produto no topo da lista',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A7A5A)),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD4AF37), size: 16),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  void _showBoostPlansDialog() {
    final plans = [
      _BoostPlan('Básico', 'R\$ 29,90/mês', '7 dias em destaque', Icons.star_outline_rounded, Color(0xFF10B981), [
        '✅ Aparece antes dos não patrocinados',
        '✅ Badge "Patrocinado" no card',
        '✅ 200 cliques garantidos',
      ]),
      _BoostPlan('Pro', 'R\$ 59,90/mês', '15 dias em destaque', Icons.star_rounded, Color(0xFF3B82F6), [
        '✅ Tudo do Básico',
        '✅ Badge azul "Destaque"',
        '✅ 500 cliques garantidos',
        '✅ Aparece no carrossel da home',
      ]),
      _BoostPlan('Premium', 'R\$ 99,90/mês', 'TOP #1 garantido', Icons.workspace_premium_rounded, Color(0xFFD4AF37), [
        '✅ Tudo do Pro',
        '✅ Badge dourado TOP #1',
        '✅ 1.000 cliques garantidos',
        '✅ Prioridade máxima em Ofertas Relâmpago',
        '✅ Notificação push para usuários',
      ]),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Color(0xFF0F0F1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFF8A7A5A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Icon(Icons.rocket_launch_rounded, color: Color(0xFFD4AF37), size: 36),
                  SizedBox(height: 10),
                  Text(
                    'Planos de Destaque',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Coloque seu produto na frente de todos!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF8A7A5A)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: plans.length,
                itemBuilder: (context, i) {
                  final plan = plans[i];
                  final isPopular = i == 1;
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isPopular
                          ? plan.color.withValues(alpha: 0.1)
                          : Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: plan.color.withValues(alpha: isPopular ? 0.6 : 0.3),
                        width: isPopular ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(plan.icon, color: plan.color, size: 22),
                            SizedBox(width: 8),
                            Text(
                              plan.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: plan.color,
                              ),
                            ),
                            Spacer(),
                            if (isPopular)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: plan.color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: plan.color.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  '⭐ Popular',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: plan.color),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(plan.subtitle, style: TextStyle(fontSize: 12, color: Color(0xFF8A7A5A))),
                        SizedBox(height: 12),
                        ...plan.features.map((f) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(f, style: TextStyle(fontSize: 12, color: Color(0xFFB0A080))),
                        )),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan.price,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: plan.color,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: plan.color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Contratar',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: i == 2 ? Color(0xFF1A1000) : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produtos mais vendidos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: context.appColors.textPrimary,
          ),
        ),
        SizedBox(height: 12),
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
      Color(0xFFD4AF37),
      Color(0xFFC0C0C0),
      Color(0xFFCD7F32),
      context.appColors.textMuted,
      context.appColors.textMuted,
    ];
    final color = rankColors[rank - 1];

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.border),
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
          SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(p.icon, color: AppColors.primary, size: 18),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${p.units} vendas',
                  style: TextStyle(fontSize: 11, color: context.appColors.textMuted),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(p.commission),
            style: TextStyle(
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
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary bar
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1508), Color(0xFF0A0A14)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFD4AF37).withValues(alpha: 0.3),
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
          SizedBox(height: 20),
          Text(
            'Histórico de Vendas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: context.appColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
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
        Icon(icon, color: Color(0xFFD4AF37), size: 20),
        SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Color(0xFFD4AF37),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Color(0xFF8A7A5A)),
        ),
      ],
    );
  }

  Widget _vDivider() {
    return Container(width: 1, height: 40, color: Color(0xFFD4AF37).withValues(alpha: 0.2));
  }

  Widget _buildSaleItem(_SaleRecord sale, NumberFormat currency) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.border),
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
            child: Icon(Icons.receipt_rounded, color: AppColors.primary, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.product,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${sale.buyer} · ${sale.date}',
                  style: TextStyle(fontSize: 11, color: context.appColors.textMuted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${currency.format(sale.commission)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.savings,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 4),
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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

  // ─── Links & Manual Sales Tab ──────────────────────────────────────────────

  Widget _buildLinksAndSalesTab() {
    final currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final totalCommission = _manualSales.fold(0.0, (sum, s) => sum + (s['commission'] as double));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Link Click Stats ──
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0D1A0D), Color(0xFF0A0A14)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.savings.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.savings.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.link_rounded, color: AppColors.savings, size: 18),
                          ),
                          SizedBox(width: 8),
                          Text('Cliques Totais', style: TextStyle(fontSize: 12, color: context.appColors.textMuted)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        NumberFormat('#,###').format(_totalLinkClicks),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.savings,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '+$_todayLinkClicks hoje',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.savings.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1508), Color(0xFF0A0A14)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Color(0xFFD4AF37).withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFFD4AF37).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.monetization_on_rounded, color: Color(0xFFD4AF37), size: 18),
                          ),
                          SizedBox(width: 8),
                          Text('Comissão Total', style: TextStyle(fontSize: 12, color: context.appColors.textMuted)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        currency.format(totalCommission),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${_manualSales.length} vendas lançadas',
                        style: TextStyle(fontSize: 11, color: Color(0xFF8A7A5A)),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0),
              ),
            ],
          ),
          SizedBox(height: 24),

          // ── Manual Sales Header ──
          Row(
            children: [
              Text(
                'Vendas Manuais',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.appColors.textPrimary,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => _showAddSaleDialog(currency),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Color(0xFF1A1000), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Lançar Venda',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF1A1000)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          if (_manualSales.isEmpty)
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.appColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.appColors.border),
              ),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: context.appColors.textMuted, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'Nenhuma venda lançada ainda',
                      style: TextStyle(fontSize: 14, color: context.appColors.textMuted),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Toque em "Lançar Venda" para registrar',
                      style: TextStyle(fontSize: 12, color: context.appColors.textMuted),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._manualSales.asMap().entries.map((e) {
              final i = e.key;
              final sale = e.value;
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.appColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.appColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Color(0xFFD4AF37).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.handshake_rounded, color: Color(0xFFD4AF37), size: 20),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sale['product'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: context.appColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            sale['date'] as String,
                            style: TextStyle(fontSize: 11, color: context.appColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${currency.format(sale['commission'])}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.savings,
                          ),
                        ),
                        Text(
                          'Venda: ${currency.format(sale['amount'])}',
                          style: TextStyle(fontSize: 10, color: context.appColors.textMuted),
                        ),
                      ],
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _manualSales.removeAt(i)),
                      child: Icon(Icons.delete_outline_rounded, color: context.appColors.textMuted, size: 18),
                    ),
                  ],
                ),
              ).animate(delay: (i * 60).ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
            }),
          SizedBox(height: 80),
        ],
      ),
    );
  }

  void _showAddSaleDialog(NumberFormat currency) {
    final productCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final commissionCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF0F0F1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Lançar Venda Manual',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD4AF37),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Registre uma venda realizada fora da plataforma',
                style: TextStyle(fontSize: 12, color: context.appColors.textMuted),
              ),
              SizedBox(height: 20),
              _dialogField(productCtrl, 'Nome do Produto', Icons.inventory_2_rounded),
              SizedBox(height: 12),
              _dialogField(amountCtrl, 'Valor da Venda (R\$)', Icons.attach_money_rounded, isNumber: true),
              SizedBox(height: 12),
              _dialogField(commissionCtrl, 'Sua Comissão (R\$)', Icons.emoji_events_rounded, isNumber: true),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    if (productCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                      setState(() {
                        _manualSales.insert(0, {
                          'product': productCtrl.text,
                          'amount': double.tryParse(amountCtrl.text.replaceAll(',', '.')) ?? 0.0,
                          'commission': double.tryParse(commissionCtrl.text.replaceAll(',', '.')) ?? 0.0,
                          'date': '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}',
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        'Lançar Venda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1000),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: TextStyle(color: context.appColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.appColors.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: Color(0xFFD4AF37), size: 18),
        filled: true,
        fillColor: context.appColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.appColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFD4AF37), width: 2),
        ),
      ),
    );
  }

  // ─── Reports Tab ──────────────────────────────────────────────────────────

  Widget _buildReportsTab() {
    final reports = [
      _Report('Relatório Mensal — Julho 2026', 'Comissões: R\$ 2.340,50 · Vendas: 31', Icons.calendar_month_rounded, AppColors.primary),
      _Report('Relatório Mensal — Junho 2026', 'Comissões: R\$ 4.890,00 · Vendas: 58', Icons.calendar_month_rounded, AppColors.savings),
      _Report('Relatório Mensal — Maio 2026', 'Comissões: R\$ 3.210,00 · Vendas: 42', Icons.calendar_month_rounded, AppColors.coupon),
      _Report('Relatório de Produtos Topo', 'iPhone 15 Pro Max lidera com 48 vendas', Icons.emoji_events_rounded, Color(0xFFD4AF37)),
      _Report('Análise de Conversão', 'Taxa média: 4,7% · Acima da média', Icons.analytics_rounded, AppColors.verified),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Export row
          Row(
            children: [
              Text(
                'Relatórios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.appColors.textPrimary,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
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
          SizedBox(height: 16),
          ...reports.asMap().entries.map((e) {
            final i = e.key;
            final r = e.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.appColors.surfaceElevated,
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
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          r.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.appColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.open_in_new_rounded,
                    color: context.appColors.textMuted,
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

class _BoostPlan {
  final String name;
  final String price;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> features;
  const _BoostPlan(this.name, this.price, this.subtitle, this.icon, this.color, this.features);
}

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
      color: context.appColors.background,
      child: Column(
        children: [
          tabBar,
          Divider(height: 1, color: context.appColors.border),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) => false;
}
