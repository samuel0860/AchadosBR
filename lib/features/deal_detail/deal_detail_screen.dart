import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../models/deal.dart';

class DealDetailScreen extends StatefulWidget {
  final Deal deal;

  const DealDetailScreen({super.key, required this.deal});

  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  bool _hasVotedUp = false;
  bool _isSaved = false;
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(deal),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStoreBadge(deal),
                  const SizedBox(height: 12),
                  _buildTitle(deal),
                  const SizedBox(height: 16),
                  _buildPricing(deal, currencyFormatter),
                  if (deal.couponCode != null) ...[
                    const SizedBox(height: 16),
                    _buildCouponSection(deal.couponCode!),
                  ],
                  const SizedBox(height: 16),
                  _buildQuickInfo(deal),
                  const SizedBox(height: 16),
                  _buildDescription(deal),
                  const SizedBox(height: 16),
                  _buildVotingSection(deal),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(deal, currencyFormatter),
    );
  }

  Widget _buildSliverAppBar(Deal deal) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => setState(() => _isSaved = !_isSaved),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                _isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: _isSaved ? AppColors.coupon : Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.share_rounded, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            deal.imageUrl.startsWith('assets/')
                ? Image.asset(
                    deal.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (ctx, err, stack) =>
                        Container(color: AppColors.surfaceElevated),
                  )
                : Image.network(
                    deal.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) =>
                        Container(color: AppColors.surfaceElevated),
                  ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 80,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppGradients.hotGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.hot.withValues(alpha: 0.5),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Text(
                  '-${deal.discountPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreBadge(Deal deal) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              deal.storeLogoUrl,
              fit: BoxFit.contain,
              errorBuilder: (ctx, err, stack) => Center(
                child: Text(deal.store[0],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(deal.store,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
        if (deal.isVerified) ...[
          const SizedBox(width: 4),
          const Icon(Icons.verified_rounded, size: 14, color: AppColors.verified),
        ],
        const Spacer(),
        Text('por ${deal.postedBy}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildTitle(Deal deal) {
    return Text(
      deal.title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
    );
  }

  Widget _buildPricing(Deal deal, NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currencyFormatter.format(deal.originalPrice),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: AppColors.textMuted,
                ),
              ),
              Text(
                currencyFormatter.format(deal.dealPrice),
                style: const TextStyle(
                  fontSize: 32,
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
              const Text('Você economiza',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text(
                currencyFormatter.format(deal.savings),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.coupon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(String code) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.savings, size: 20),
                const SizedBox(width: 8),
                Text('Cupom "$code" copiado!'),
              ],
            ),
            backgroundColor: AppColors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.coupon.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.coupon.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.coupon.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_offer_rounded, color: AppColors.coupon, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cupom de desconto',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.coupon,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.coupon,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Copiar',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfo(Deal deal) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (deal.hasFreeShipping)
          _infoChip(Icons.local_shipping_rounded, 'Frete Grátis', AppColors.savings),
        if (deal.isHot)
          _infoChip(Icons.local_fire_department_rounded, 'Oferta Quente', AppColors.hot),
        if (deal.expiresAt != null)
          _infoChip(Icons.timer_rounded, _formatExpiry(deal.expiresAt!), AppColors.coupon),
      ],
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildDescription(Deal deal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Descrição',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(deal.description,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.6)),
      ],
    );
  }

  Widget _buildVotingSection(Deal deal) {
    return Column(
      children: [
        const Text('Esta oferta é boa?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => setState(() {
                _hasVotedUp = !_hasVotedUp;
                _hasVotedUp ? _upvotes++ : _upvotes--;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: _hasVotedUp ? AppColors.savings.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _hasVotedUp ? AppColors.savings : AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.thumb_up_rounded, size: 18,
                        color: _hasVotedUp ? AppColors.savings : AppColors.textMuted),
                    const SizedBox(width: 8),
                    Text('$_upvotes',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: _hasVotedUp ? AppColors.savings : AppColors.textMuted)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_down_rounded, size: 18, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Text('Expirou',
                      style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(Deal deal, NumberFormat currencyFormatter) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Preço atual',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
              Text(
                currencyFormatter.format(deal.dealPrice),
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.savings),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppGradients.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.open_in_new_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('Ir para a loja',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatExpiry(DateTime expiry) {
    final diff = expiry.difference(DateTime.now());
    if (diff.inHours < 1) return 'Expira em ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'Expira em ${diff.inHours}h';
    return 'Expira em ${diff.inDays}d';
  }
}
