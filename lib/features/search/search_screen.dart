import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../data/mock_deals.dart';
import '../../models/deal.dart';
import '../../shared/widgets/deal_card.dart';
import '../../shared/widgets/filter_bottom_sheet.dart';
import '../deal_detail/deal_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _shakeController;

  String _query = '';
  DealCategory? _filterCategory;
  String _sortBy = 'relevance'; // relevance | price_asc | price_desc | discount | hot
  bool _onlyFreeShipping = false;

  // Histórico em memória (simples)
  final List<String> _history = [];

  final List<(IconData, String)> _trending = [
    (Icons.smartphone_rounded, 'iPhone 15'),
    (Icons.sports_esports_rounded, 'PS5'),
    (Icons.directions_run_rounded, 'Nike Air Max'),
    (Icons.laptop_rounded, 'Notebook'),
    (Icons.tv_rounded, 'Smart TV'),
    (Icons.headphones_rounded, 'Fones'),
    (Icons.kitchen_rounded, 'Air Fryer'),
    (Icons.tablet_rounded, 'Tablet'),
    (Icons.watch_rounded, 'Smartwatch'),
    (Icons.camera_alt_rounded, 'Câmera'),
  ];

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    final q = value.trim();
    if (q.isEmpty) return;
    setState(() => _query = q);
    if (!_history.contains(q)) {
      _history.insert(0, q);
      if (_history.length > 8) _history.removeLast();
    }
    _focusNode.unfocus();
  }

  List<Deal> get _results {
    if (_query.isEmpty) return [];

    var deals = mockDeals.where((d) {
      final q = _query.toLowerCase();
      final matchesText =
          d.title.toLowerCase().contains(q) ||
          d.store.toLowerCase().contains(q) ||
          d.category.name.toLowerCase().contains(q) ||
          d.category.label.toLowerCase().contains(q) ||
          (d.description?.toLowerCase().contains(q) ?? false);

      final matchesCategory =
          _filterCategory == null || d.category == _filterCategory;
      final matchesFreeShipping =
          !_onlyFreeShipping || d.hasFreeShipping == true;

      return matchesText && matchesCategory && matchesFreeShipping;
    }).toList();

    switch (_sortBy) {
      case 'price_asc':
        deals.sort((a, b) => a.dealPrice.compareTo(b.dealPrice));
      case 'price_desc':
        deals.sort((a, b) => b.dealPrice.compareTo(a.dealPrice));
      case 'discount':
        deals.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
      case 'hot':
        deals.sort((a, b) => b.temperature.compareTo(a.temperature));
      default: // relevance — título primeiro
        deals.sort((a, b) {
          final aq = a.title.toLowerCase().contains(_query.toLowerCase()) ? 0 : 1;
          final bq = b.title.toLowerCase().contains(_query.toLowerCase()) ? 0 : 1;
          return aq.compareTo(bq);
        });
    }

    return deals;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final results = _results;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          // ─── Header com campo de busca ──────────────────────────────────────
          _buildSearchHeader(colors),

          // ─── Barra de resultados ────────────────────────────────────────────
          if (_query.isNotEmpty)
            _buildResultsBar(results, colors),

          // ─── Conteúdo principal ─────────────────────────────────────────────
          Expanded(
            child: _query.isEmpty
                ? _buildEmptyState(colors)
                : results.isEmpty
                    ? _buildNoResults(colors)
                    : _buildResultsList(results, colors),
          ),
        ],
      ),
    );
  }

  // ─── Search Header ──────────────────────────────────────────────────────────

  Widget _buildSearchHeader(AppThemeColors colors) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: colors.appBarBackground,
      padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.search_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Buscar Achados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              if (_query.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    final result = await showModalBottomSheet<Map<String, dynamic>>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => FilterBottomSheet(
                        initialSortBy: _sortBy,
                        initialCategory: _filterCategory,
                      ),
                    );
                    if (result != null) {
                      setState(() {
                        _sortBy = result['sortBy'] as String;
                        _filterCategory = result['category'] as DealCategory?;
                      });
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 14,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Filtros',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.textSecondary,
                          ),
                        ),
                        if (_filterCategory != null ||
                            _onlyFreeShipping ||
                            _sortBy != 'relevance') ...[
                          const SizedBox(width: 5),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Campo de busca
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : colors.border,
                width: _focusNode.hasFocus ? 1.5 : 1,
              ),
              boxShadow: _focusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: _submitSearch,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'iPhone, PS5, Nike, loja...',
                hintStyle: TextStyle(color: colors.textMuted, fontSize: 15),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search_rounded,
                    color: _focusNode.hasFocus
                        ? AppColors.primary
                        : colors.textMuted,
                    size: 22,
                  ),
                ),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                          });
                        },
                        icon: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: colors.borderLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded,
                              size: 14, color: colors.textSecondary),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
              textInputAction: TextInputAction.search,
              onTap: () => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Results Bar ────────────────────────────────────────────────────────────

  Widget _buildResultsBar(List<Deal> results, AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      color: colors.surface,
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${results.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: results.isEmpty
                        ? colors.textMuted
                        : AppColors.primary,
                  ),
                ),
                TextSpan(
                  text: results.length == 1
                      ? ' resultado para '
                      : ' resultados para ',
                  style: TextStyle(
                      fontSize: 13, color: colors.textSecondary),
                ),
                TextSpan(
                  text: '"$_query"',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Limpar filtros ativos
          if (_filterCategory != null ||
              _onlyFreeShipping ||
              _sortBy != 'relevance')
            GestureDetector(
              onTap: () => setState(() {
                _filterCategory = null;
                _onlyFreeShipping = false;
                _sortBy = 'relevance';
              }),
              child: Text(
                'Limpar filtros',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── Results List ───────────────────────────────────────────────────────────

  Widget _buildResultsList(List<Deal> results, AppThemeColors colors) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final deal = results[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DealCard(
            deal: deal,
            heroTagPrefix: 'search_',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DealDetailScreen(deal: deal),
              ),
            ),
          )
              .animate(delay: Duration(milliseconds: index * 40))
              .fadeIn(duration: 250.ms)
              .slideY(begin: 0.04, end: 0),
        );
      },
    );
  }

  // ─── Empty State (sem busca ativa) ──────────────────────────────────────────

  Widget _buildEmptyState(AppThemeColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Histórico de buscas
          if (_history.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.history_rounded, size: 18, color: colors.textMuted),
                const SizedBox(width: 8),
                Text(
                  'Buscas recentes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _history.clear()),
                  child: Text(
                    'Limpar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _history
                  .map((term) => GestureDetector(
                        onTap: () {
                          _searchController.text = term;
                          _submitSearch(term);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history_rounded,
                                  size: 14, color: colors.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                term,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            Divider(color: colors.border),
            const SizedBox(height: 16),
          ],

          // Em alta
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.hot.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: AppColors.hot, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Em alta agora',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.05),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trending.asMap().entries.map((e) {
              final index = e.key;
              final item = e.value;
              return GestureDetector(
                onTap: () {
                  _searchController.text = item.$2;
                  _submitSearch(item.$2);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.$1, size: 15, color: AppColors.primary),
                      const SizedBox(width: 7),
                      Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: index * 40))
                  .fadeIn(duration: 300.ms)
                  .slideX(begin: 0.05, end: 0);
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Categorias rápidas
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.category_rounded,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Explorar categorias',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.4,
            children: DealCategory.values
                .asMap()
                .entries
                .map((e) {
                  final index = e.key;
                  final cat = e.value;
                  return GestureDetector(
                    onTap: () {
                      _searchController.text = cat.label;
                      setState(() {
                        _query = cat.label;
                        _filterCategory = cat;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat.icon,
                            size: 26,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                        .animate(delay: Duration(milliseconds: index * 50))
                        .fadeIn(duration: 300.ms)
                        .scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1, 1)),
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  // ─── No Results ─────────────────────────────────────────────────────────────

  Widget _buildNoResults(AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: colors.border),
            ),
            child: Icon(Icons.search_off_rounded,
                size: 42, color: colors.textMuted),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 20),
          Text(
            'Nada encontrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente outro termo ou remova os filtros',
            style: TextStyle(fontSize: 14, color: colors.textMuted),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() {
              _filterCategory = null;
              _onlyFreeShipping = false;
              _sortBy = 'relevance';
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Limpar filtros',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
