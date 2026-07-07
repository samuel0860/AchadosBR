import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../data/mock_deals.dart';
import '../../models/deal.dart';
import '../../shared/widgets/deal_card.dart';
import '../deal_detail/deal_detail_screen.dart';

class AllDealsScreen extends StatefulWidget {
  const AllDealsScreen({super.key});

  @override
  State<AllDealsScreen> createState() => _AllDealsScreenState();
}

class _AllDealsScreenState extends State<AllDealsScreen> {
  DealCategory? _selectedCategory;
  String _sortBy = 'hot';

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
        deals.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    }
    return deals;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Todos os Achados',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
        backgroundColor: colors.appBarBackground,
        iconTheme: IconThemeData(color: colors.textPrimary),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.border),
        ),
      ),
      body: Column(
        children: [
          // ─── Filtros ────────────────────────────────────────────────────────
          Container(
            color: colors.appBarBackground,
            child: Column(
              children: [
                // Sort tabs
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      ('hot', Icons.local_fire_department_rounded, 'Mais Quentes'),
                      ('new', Icons.auto_awesome_rounded, 'Mais Novos'),
                      ('discount', Icons.sell_rounded, 'Maior Desconto'),
                    ].map((tab) {
                      final isSelected = _sortBy == tab.$1;
                      return GestureDetector(
                        onTap: () => setState(() => _sortBy = tab.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppGradients.primaryGradient : null,
                            color: isSelected ? null : colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : colors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(tab.$2,
                                  size: 13,
                                  color: isSelected ? Colors.white : colors.textSecondary),
                              const SizedBox(width: 5),
                              Text(
                                tab.$3,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Category chips
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    children: [
                      // "Todos"
                      GestureDetector(
                        onTap: () => setState(() => _selectedCategory = null),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedCategory == null
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _selectedCategory == null
                                  ? AppColors.primary.withValues(alpha: 0.5)
                                  : colors.border,
                            ),
                          ),
                          child: Text(
                            'Todos',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _selectedCategory == null
                                  ? AppColors.primary
                                  : colors.textSecondary,
                            ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : colors.surfaceElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.5)
                                    : colors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat.icon,
                                  size: 14,
                                  color: isSelected ? Colors.white : colors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  cat.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : colors.textSecondary,
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
                Divider(height: 1, color: colors.border),
              ],
            ),
          ),

          // ─── Lista ──────────────────────────────────────────────────────────
          Expanded(
            child: filteredDeals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: colors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum achado encontrado',
                          style: TextStyle(fontSize: 16, color: colors.textMuted),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                    itemCount: filteredDeals.length,
                    itemBuilder: (context, index) {
                      final deal = filteredDeals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DealCard(
                          deal: deal,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DealDetailScreen(deal: deal),
                            ),
                          ),
                        )
                            .animate(delay: Duration(milliseconds: index * 50))
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.05, end: 0),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
