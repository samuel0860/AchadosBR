import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../data/mock_deals.dart';
import '../../shared/widgets/deal_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<(IconData, String)> _trending = [
    (Icons.smartphone_rounded, 'iPhone 15'),
    (Icons.sports_esports_rounded, 'PS5'),
    (Icons.directions_run_rounded, 'Nike'),
    (Icons.laptop_rounded, 'Notebook'),
    (Icons.tv_rounded, 'Smart TV'),
    (Icons.headphones_rounded, 'Fones'),
    (Icons.kitchen_rounded, 'Air Fryer'),
    (Icons.tablet_rounded, 'Tablet'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _query.isEmpty
        ? <dynamic>[]
        : mockDeals
            .where((d) =>
                d.title.toLowerCase().contains(_query.toLowerCase()) ||
                d.store.toLowerCase().contains(_query.toLowerCase()) ||
                d.category.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Buscar Achados'),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Buscar por produto, loja ou categoria...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        child: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _query.isEmpty
                ? _buildTrending()
                : results.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) => DealCard(deal: results[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrending() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.hot.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.trending_up_rounded,
                    color: AppColors.hot, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Em alta agora',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trending.map((item) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = item.$2;
                  setState(() => _query = item.$2);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.$1, size: 15, color: AppColors.primary),
                      const SizedBox(width: 7),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 38, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum achado encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tente outro termo de busca',
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
