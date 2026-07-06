import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../models/deal.dart';
import '../../features/deal_detail/deal_detail_screen.dart';

class DealCard extends StatefulWidget {
  final Deal deal;
  final VoidCallback? onTap;

  const DealCard({super.key, required this.deal, this.onTap});

  @override
  State<DealCard> createState() => _DealCardState();
}

class _DealCardState extends State<DealCard> {
  bool _hasVotedUp = false;
  bool _hasVotedDown = false;
  late int _upvotes;

  @override
  void initState() {
    super.initState();
    _upvotes = widget.deal.upvotes;
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DealDetailScreen(deal: deal)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        height: 170, // Increased to 170 for better vertical space
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.card, Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: deal.isHot
                ? AppColors.hot.withValues(alpha: 0.3)
                : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── LADO ESQUERDO: IMAGEM ─────────────────────────────────────────
            _buildSideImage(deal),
            
            // ─── LADO DIREITO: INFORMAÇÕES ─────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHorizontalHeader(deal),
                    const SizedBox(height: 4),
                    _buildCompactTitle(deal),
                    const Spacer(),
                    _buildPriceSection(deal, currencyFormatter),
                    const SizedBox(height: 8),
                    _buildHorizontalFooter(deal),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideImage(Deal deal) {
    return Stack(
      children: [
        Container(
          width: 130,
          height: double.infinity,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: deal.imageUrl.startsWith('assets/')
                ? Image.asset(
                    deal.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, url, error) => _buildImageFallback(deal),
                  )
                : Image.network(
                    deal.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.surfaceElevated,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, url, error) => _buildImageFallback(deal),
                  ),
          ),
        ),
        // Discount badge overlay
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.hot, Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.hot.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '-${deal.discountPercent.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalHeader(Deal deal) {
    return Row(
      children: [
        // Store logo mini
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              deal.storeLogoUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, url, error) => Center(
                child: Text(
                  deal.store[0],
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            deal.store,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (deal.isHot)
          _buildIconBadge(
            Icons.local_fire_department_rounded,
            'HOT',
            AppColors.hot,
            AppColors.hot.withValues(alpha: 0.15),
          ),
      ],
    );
  }

  Widget _buildCompactTitle(Deal deal) {
    return Text(
      deal.title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPriceSection(Deal deal, NumberFormat currencyFormatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          currencyFormatter.format(deal.originalPrice),
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            decoration: TextDecoration.lineThrough,
          ),
        ),
        Text(
          currencyFormatter.format(deal.dealPrice),
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: AppColors.savings,
            height: 1.1,
          ),
        ),
        if (deal.savings > 0)
          Text(
            'Economize ${currencyFormatter.format(deal.savings)}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.coupon,
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalFooter(Deal deal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildVoteButton(
          icon: Icons.keyboard_arrow_up_rounded,
          count: _upvotes,
          isActive: _hasVotedUp,
          activeColor: AppColors.savings,
          onTap: () => setState(() {
            if (_hasVotedUp) { _hasVotedUp = false; _upvotes--; }
            else { _hasVotedUp = true; _upvotes++; if (_hasVotedDown) _hasVotedDown = false; }
          }),
        ),
        const SizedBox(width: 4),
        _buildActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: '${deal.comments}',
          color: AppColors.textMuted,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DealDetailScreen(deal: deal)),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'Ver mais',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconBadge(
    IconData icon,
    String text,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: textColor),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback(Deal deal) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.dealCardGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _categoryIcon(deal.category),
              color: AppColors.primary.withValues(alpha: 0.6),
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              deal.store,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildVoteButton({
    required IconData icon,
    required int count,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.15) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor.withValues(alpha: 0.5) : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isActive ? activeColor : AppColors.textMuted),
            const SizedBox(width: 3),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? activeColor : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  IconData _categoryIcon(DealCategory cat) {
    switch (cat) {
      case DealCategory.eletronicos: return Icons.devices_rounded;
      case DealCategory.moda: return Icons.checkroom_rounded;
      case DealCategory.casa: return Icons.home_rounded;
      case DealCategory.jogos: return Icons.sports_esports_rounded;
      case DealCategory.livros: return Icons.menu_book_rounded;
      case DealCategory.beleza: return Icons.face_rounded;
      case DealCategory.esporte: return Icons.fitness_center_rounded;
      case DealCategory.viagem: return Icons.flight_rounded;
      case DealCategory.alimentacao: return Icons.restaurant_rounded;
      case DealCategory.outros: return Icons.local_offer_rounded;
    }
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
