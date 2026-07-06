import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../data/mock_deals.dart';
import '../../services/user_data_service.dart';
import '../deal_detail/deal_detail_screen.dart';

class SavedDealsScreen extends StatefulWidget {
  const SavedDealsScreen({super.key});

  @override
  State<SavedDealsScreen> createState() => _SavedDealsScreenState();
}

class _SavedDealsScreenState extends State<SavedDealsScreen> {
  final _userDataService = UserDataService();

  @override
  Widget build(BuildContext context) {
    final savedIds = _userDataService.savedDealIds;
    final saved = mockDeals.where((d) => savedIds.contains(d.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Itens Salvos'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
      ),
      body: saved.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: saved.length,
              itemBuilder: (context, index) {
                final deal = saved[index];
                return _buildDealTile(context, deal, index);
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bookmark_outline_rounded,
              size: 72, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('Nenhum item salvo',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          const Text('Salve achados para encontrá-los aqui',
              style: TextStyle(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildDealTile(BuildContext context, deal, int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DealDetailScreen(deal: deal)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                deal.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.surface,
                  child: const Icon(Icons.image_rounded,
                      color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(deal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'R\$ ${deal.dealPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.savings),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'R\$ ${deal.originalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmark_rounded,
                  color: AppColors.primary, size: 20),
              onPressed: () {
                _userDataService.toggleSave(deal.id);
                setState(() {});
              },
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: index * 60)),
    );
  }
}
