import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../shared/utils/app_snackbar.dart';
import '../../data/mock_affiliates.dart';
import '../../models/deal.dart';
import '../../models/store_brand.dart';
import '../../services/user_data_service.dart';
import '../affiliate/affiliate_page_screen.dart';
import '../review/reviews_section.dart';

class DealDetailScreen extends StatefulWidget {
  final Deal deal;
  final String heroTagPrefix;

  const DealDetailScreen({
    super.key,
    required this.deal,
    this.heroTagPrefix = '',
  });

  @override
  State<DealDetailScreen> createState() => _DealDetailScreenState();
}

class _DealDetailScreenState extends State<DealDetailScreen> {
  bool _hasVotedUp = false;
  late bool _isSaved;
  late int _upvotes;
  final _userDataService = UserDataService();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _upvotes = widget.deal.upvotes;
    _isSaved = _userDataService.isSaved(widget.deal.id);
    // Track visit
    _userDataService.addVisit(
      widget.deal.id,
      widget.deal.title,
      widget.deal.imageUrl,
    );
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deal = widget.deal;
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CustomScrollView(
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
                      const SizedBox(height: 16),
                      _buildAffiliateCard(deal),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ReviewsSection(deal: deal),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(deal, currencyFormatter),
    );
  }

  Widget _buildSliverAppBar(Deal deal) {
    final colors = context.appColors;
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: colors.background,
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
          onTap: () {
            HapticFeedback.lightImpact();
            _userDataService.toggleSave(widget.deal.id);
            setState(() => _isSaved = !_isSaved);
          },
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
          onTap: () {
            HapticFeedback.lightImpact();
          },
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
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: '${widget.heroTagPrefix}deal_image_${deal.id}',
              child: (deal.imageUrl.startsWith('assets/')
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
                    )).animate().scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 800.ms, curve: Curves.easeOut),
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
        StoreLogo(
          store: findStoreBrandByName(deal.store) ??
              StoreBrand(
                id: 'custom',
                name: deal.store,
                emoji: deal.store.isNotEmpty ? deal.store[0].toUpperCase() : '?',
                primaryColor: AppColors.primary,
                textColor: Colors.white,
              ),
          size: 28,
          borderRadius: BorderRadius.circular(7),
        ),
        const SizedBox(width: 8),
        Text(deal.store,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(width: 4),
        const Icon(Icons.verified_rounded, size: 14, color: AppColors.verified),
        const Spacer(),
        Text('por ${deal.postedBy}',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildTitle(Deal deal) {
    return Text(
      deal.title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: context.appColors.textPrimary,
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
        HapticFeedback.lightImpact();
        Clipboard.setData(ClipboardData(text: code));
        _confettiController.play();
        AppSnackBar.show(context, 'Cupom "$code" copiado!');
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
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _hasVotedUp = !_hasVotedUp;
                  _hasVotedUp ? _upvotes++ : _upvotes--;
                });
              },
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colors = context.appColors;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
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
              Text('Preço atual',
                  style: TextStyle(fontSize: 11, color: colors.textMuted)),
              Text(
                currencyFormatter.format(deal.dealPrice),
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.savings),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _confettiController.play();
                // TODO: url_launcher open deal.link
              },
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

  // ─── Card do Afiliado ──────────────────────────────────────────────────────

  Widget _buildAffiliateCard(Deal deal) {
    final colors = context.appColors;

    // Tenta encontrar o afiliado pelo ID primeiro, depois pelo nome
    final affiliate = deal.affiliateId.isNotEmpty
        ? findAffiliateById(deal.affiliateId)
        : findAffiliateByName(deal.postedBy);

    // Se não encontrar dados, usa o postedBy como nome simples
    final name = affiliate?.name ?? deal.postedBy;
    final bio = affiliate?.bio ?? 'Afiliado verificado AchouAchado';
    final colorHex = affiliate?.themeColorHex ?? '#7C3AED';
    final totalDeals = affiliate?.totalDeals ?? 0;
    final rating = affiliate?.rating ?? 4.5;

    Color themeColor;
    try {
      themeColor = Color(
          int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      themeColor = AppColors.primary;
    }

    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AffiliatePageScreen(
              affiliateId: deal.affiliateId.isNotEmpty
                  ? deal.affiliateId
                  : 'affiliate_${deal.postedBy.toLowerCase()}',
              affiliateName: name,
              isOwner: false,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: themeColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Row(
              children: [
                Icon(Icons.storefront_rounded,
                    size: 13, color: themeColor),
                const SizedBox(width: 5),
                Text(
                  'PUBLICADO POR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: themeColor,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('⭐', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: themeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Avatar + info
            Row(
              children: [
                // Avatar circular com inicial e cor temática
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeColor,
                        themeColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(
                        color: colors.background, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Nome + bio
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                      if (totalDeals > 0) ...[
                        const SizedBox(height: 5),
                        Text(
                          '$totalDeals ofertas publicadas',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Botão ver vitrine
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: themeColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_rounded,
                      size: 16, color: themeColor),
                  const SizedBox(width: 8),
                  Text(
                    'Ver Vitrine do Afiliado',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      size: 14, color: themeColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

