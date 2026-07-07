import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../data/mock_deals.dart';
import '../../models/deal.dart';
import '../../services/auth_service.dart';
import '../../services/boost_service.dart';
import '../../shared/widgets/deal_card.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'flash_deals_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  DealCategory? _selectedCategory;
  String _sortBy = 'hot';
  late ScrollController _scrollController;
  bool _showElevation = false;
  int _proofIndex = 0;

  // Carrossel CLIENTE — foco em economia e cupons
  static const _clientProof = [
    ('Samuel', 'acabou de comprar um iPhone 15 Pro', 'cupom IPHONE15BR', Icons.smartphone_rounded),
    ('Maria', 'economizou R\$ 350 com um cupom exclusivo', null, Icons.savings_rounded),
    ('João', 'comprou um PS5 com 25% de desconto', 'cupom PS5BRASIL', Icons.sports_esports_rounded),
    ('Camila', 'encontrou frete grátis em 3 produtos', null, Icons.local_shipping_rounded),
    ('Pedro', 'economizou R\$ 1.200 com alerta de promoção', null, Icons.notifications_active_rounded),
    ('Fernanda', 'comprou Air Fryer por R\$ 90 a menos', null, Icons.kitchen_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      setState(() {
        _showElevation = _scrollController.offset > 10;
      });
    });

    // Auto-advance proof carousel
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 3500));
      if (!mounted) return false;
      setState(() => _proofIndex = (_proofIndex + 1) % _clientProof.length);
      return true;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Deal> get filteredDeals {
    var deals = mockDeals.where((d) {
      if (_selectedCategory != null && d.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    switch (_sortBy) {
      case 'hot':
        deals.sort((a, b) => b.temperature.compareTo(a.temperature));
      case 'new':
        deals.sort((a, b) => b.postedAt.compareTo(a.postedAt));
      case 'discount':
        deals.sort((a, b) =>
            b.discountPercent.compareTo(a.discountPercent));
    }
    return deals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          _buildBanner(),
          SliverToBoxAdapter(child: _buildClientProof()),
          _buildSortTabs(),
          _buildCategories(),
          _buildDealsCount(),
          _buildDealsList(),
        ],
      ),
    );
  }

  Widget _buildClientProof() {
    final msg = _clientProof[_proofIndex];
    final colors = context.appColors;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey(_proofIndex),
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(msg.$4, color: AppColors.primary, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                  children: [
                    TextSpan(
                      text: '${msg.$1} ',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),
                    TextSpan(
                      text: '${msg.$2} ',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    if (msg.$3 != null)
                      TextSpan(
                        text: 'usando ${msg.$3}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.savings),
                      ),
                  ],
                ),
              ),
            ),
            // Dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_clientProof.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(left: 3),
                  width: i == _proofIndex ? 12 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i == _proofIndex
                        ? AppColors.primary
                        : colors.border,
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

  Widget _buildAppBar() {
    final colors = context.appColors;
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: colors.appBarBackground,
      elevation: _showElevation ? 4 : 0,
      shadowColor: Colors.black,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Achados',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: colors.textPrimary,
                  ),
                ),
                const TextSpan(
                  text: 'BR',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_outlined, color: colors.textPrimary),
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.hot,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Builder(builder: (context) {
              final user = AuthService().currentUser;
              final initial = (user?.name.isNotEmpty == true)
                  ? user!.name[0].toUpperCase()
                  : 'U';
              return CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        height: 95,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFEF4444)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Ofertas Relâmpago!',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Mais de 200 promoções hoje',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FlashDealsScreen()),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Ver todos',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildSortTabs() {
    final tabs = [
      ('hot', Icons.local_fire_department_rounded, 'Mais Quentes'),
      ('new', Icons.auto_awesome_rounded, 'Mais Novos'),
      ('discount', Icons.sell_rounded, 'Maior Desconto'),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 0, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tabs.map((tab) {
              final isSelected = _sortBy == tab.$1;
              return GestureDetector(
                onTap: () => setState(() => _sortBy = tab.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? AppGradients.primaryGradient
                        : null,
                    color: isSelected ? null : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppColors.border,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tab.$2,
                        size: 14,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tab.$3,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
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
      ),
    );
  }

  Widget _buildCategories() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 0, 0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedCategory = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedCategory == null
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedCategory == null
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.apps_rounded,
                        size: 14,
                        color: _selectedCategory == null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Todos',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selectedCategory == null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...DealCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _categoryIconForFilter(cat),
                          size: 14,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealsCount() {
    final colors = context.appColors;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Row(
          children: [
            Text(
              '${filteredDeals.length} achados encontrados',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.textMuted,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.tune_rounded,
              size: 18,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == filteredDeals.length) {
            return const SizedBox(height: 20);
          }
          return DealCard(deal: filteredDeals[index])
              .animate(delay: (index * 80).ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, end: 0);
        },
        childCount: filteredDeals.length + 1,
      ),
    );
  }

  IconData _categoryIconForFilter(DealCategory cat) {
    switch (cat) {
      case DealCategory.eletronicos:
        return Icons.devices_rounded;
      case DealCategory.moda:
        return Icons.checkroom_rounded;
      case DealCategory.casa:
        return Icons.home_rounded;
      case DealCategory.jogos:
        return Icons.sports_esports_rounded;
      case DealCategory.livros:
        return Icons.menu_book_rounded;
      case DealCategory.beleza:
        return Icons.face_retouching_natural_rounded;
      case DealCategory.esporte:
        return Icons.fitness_center_rounded;
      case DealCategory.viagem:
        return Icons.flight_rounded;
      case DealCategory.alimentacao:
        return Icons.restaurant_rounded;
      case DealCategory.outros:
        return Icons.category_rounded;
    }
  }
}
