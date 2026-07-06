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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.card, Color(0xFF16213E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: deal.isHot
                ? AppColors.hot.withValues(alpha: 0.4)
                : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: deal.isHot
                  ? AppColors.hot.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(deal),
            _buildImage(deal),
            _buildContent(deal, currencyFormatter),
            _buildFooter(deal),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Deal deal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Row(
        children: [
          // Store logo
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                deal.storeLogoUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, url, error) => Center(
                  child: Text(
                    deal.store[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      deal.store,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (deal.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: AppColors.verified,
                      ),
                    ],
                  ],
                ),
                Text(
                  'por ${deal.postedBy}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Badges
          Row(
            children: [
              if (deal.isHot)
                _buildIconBadge(
                  Icons.local_fire_department_rounded,
                  'HOT',
                  AppColors.hot,
                  AppColors.hot.withValues(alpha: 0.15),
                ),
              if (deal.hasFreeShipping) ...[
                const SizedBox(width: 4),
                _buildIconBadge(
                  Icons.local_shipping_rounded,
                  'GRÁTIS',
                  AppColors.savings,
                  AppColors.savings.withValues(alpha: 0.12),
                ),
              ],
            ],
          ),
        ],
      ),
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
      height: 180,
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
              size: 52,
            ),
            const SizedBox(height: 8),
            Text(
              deal.store,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(Deal deal) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 180,
          child: deal.imageUrl.startsWith('assets/')
              ? ClipRRect(
                  child: Image.asset(
                    deal.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorBuilder: (context, url, error) => _buildImageFallback(deal),
                  ),
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
        // Discount badge overlay
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.hot, Color(0xFFDC2626)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.hot.withValues(alpha: 0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '-${deal.discountPercent.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // Gradient overlay bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppColors.card.withValues(alpha: 0.9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(Deal deal, NumberFormat currencyFormatter) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            deal.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currencyFormatter.format(deal.originalPrice),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    currencyFormatter.format(deal.dealPrice),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.savings,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Economia de',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    currencyFormatter.format(deal.savings),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.coupon,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (deal.couponCode != null) ...[
            const SizedBox(height: 10),
            _buildCouponChip(deal.couponCode!),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponChip(String code) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.coupon.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.coupon.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_offer_rounded, size: 14, color: AppColors.coupon),
          const SizedBox(width: 6),
          Text(
            'Cupom: $code',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.coupon,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.copy_rounded, size: 12, color: AppColors.coupon),
        ],
      ),
    );
  }

  Widget _buildFooter(Deal deal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          _buildVoteButton(
            icon: Icons.keyboard_arrow_up_rounded,
            count: _upvotes,
            isActive: _hasVotedUp,
            activeColor: AppColors.savings,
            onTap: () {
              setState(() {
                if (_hasVotedUp) {
                  _hasVotedUp = false;
                  _upvotes--;
                } else {
                  _hasVotedUp = true;
                  _upvotes++;
                  if (_hasVotedDown) _hasVotedDown = false;
                }
              });
            },
          ),
          const SizedBox(width: 4),
          _buildVoteButton(
            icon: Icons.keyboard_arrow_down_rounded,
            count: widget.deal.downvotes,
            isActive: _hasVotedDown,
            activeColor: AppColors.hot,
            onTap: () {
              setState(() {
                if (_hasVotedDown) {
                  _hasVotedDown = false;
                } else {
                  _hasVotedDown = true;
                  if (_hasVotedUp) {
                    _hasVotedUp = false;
                    _upvotes--;
                  }
                }
              });
            },
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: '${deal.comments}',
            color: AppColors.textMuted,
          ),
          const Spacer(),
          Text(
            _timeAgo(deal.postedAt),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Ver oferta',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
