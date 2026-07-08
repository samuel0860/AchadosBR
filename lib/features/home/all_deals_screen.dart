import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../data/mock_deals.dart';
import '../../models/deal.dart';
import '../../shared/widgets/deal_card.dart';
import '../../shared/widgets/deal_card_skeleton.dart';
import '../../shared/widgets/filter_bottom_sheet.dart';
import '../deal_detail/deal_detail_screen.dart';

class AllDealsScreen extends StatefulWidget {
  const AllDealsScreen({super.key});

  @override
  State<AllDealsScreen> createState() => _AllDealsScreenState();
}

class _AllDealsScreenState extends State<AllDealsScreen> {
  DealCategory? _selectedCategory;
  String _sortBy = 'hot';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _isLoading = false);
    });
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
          'Todos os AchouAchados',
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
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: _isLoading ? 4 : filteredDeals.length,
                    itemBuilder: (context, index) {
                      if (_isLoading) {
                        return const DealCardSkeleton();
                      }
                      final deal = filteredDeals[index];
                      return DealCard(
                        deal: deal,
                        heroTagPrefix: 'all_deals_',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DealDetailScreen(
                              deal: deal,
                              heroTagPrefix: 'all_deals_',
                            ),
                          ),
                        ),
                      )
                          .animate(delay: Duration(milliseconds: index * 50))
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.05, end: 0);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showModalBottomSheet<Map<String, dynamic>>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => FilterBottomSheet(
              initialSortBy: _sortBy,
              initialCategory: _selectedCategory,
            ),
          );

          if (result != null) {
            setState(() {
              _sortBy = result['sortBy'] as String;
              _selectedCategory = result['category'] as DealCategory?;
              _simulateLoading();
            });
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
        label: const Text('Filtros', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
