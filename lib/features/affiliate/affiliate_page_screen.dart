import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../data/mock_affiliates.dart';
import '../../data/mock_deals.dart';
import '../../models/affiliate_page_model.dart';
import '../../models/affiliate_product.dart';
import '../../models/deal.dart';
import '../../services/affiliate_page_service.dart';
import '../../services/product_service.dart';
import '../deal_detail/deal_detail_screen.dart';
import '../../shared/widgets/deal_card.dart';

/// Vitrine pública + editor da página personalizada do afiliado
class AffiliatePageScreen extends StatefulWidget {
  final String affiliateId;
  final String affiliateName;
  final bool isOwner; // true = afiliado logado vendo a própria página

  const AffiliatePageScreen({
    super.key,
    required this.affiliateId,
    required this.affiliateName,
    this.isOwner = false,
  });

  @override
  State<AffiliatePageScreen> createState() => _AffiliatePageScreenState();
}

class _AffiliatePageScreenState extends State<AffiliatePageScreen>
    with SingleTickerProviderStateMixin {
  final _pageService = AffiliatePageService();
  final _productService = ProductService();

  AffiliatePageModel? _page;
  List<AffiliateProduct> _affiliateProducts =
      []; // produtos cadastrados pelo afiliado
  List<Deal> _deals = []; // deals publicados pelo afiliado nos mockDeals
  MockAffiliate? _mockData;
  bool _loading = true;
  int _bannerIndex = 0;
  late TabController _tabController;

  // Editor
  bool _editMode = false;
  late TextEditingController _bioCtrl;
  String _editColorHex = '#7C3AED';

  static const _colorOptions = [
    ('#7C3AED', 'Roxo'),
    ('#D4AF37', 'Dourado'),
    ('#EF4444', 'Vermelho'),
    ('#10B981', 'Verde'),
    ('#3B82F6', 'Azul'),
    ('#EC4899', 'Rosa'),
    ('#F97316', 'Laranja'),
    ('#6366F1', 'Índigo'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bioCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Carrega dados mock do afiliado
    final mockData =
        findAffiliateById(widget.affiliateId) ??
        findAffiliateByName(widget.affiliateName);

    // Carrega configurações da página (bio, cor salva)
    final page = await _pageService.getPage(
      widget.affiliateId,
      mockData?.name ?? widget.affiliateName,
    );

    // Carrega produtos cadastrados pelo afiliado
    await _productService.init();
    final affiliateProds = _productService.getActiveByAffiliate(
      widget.affiliateId,
    );

    // Carrega deals publicados pelo afiliado nos mockDeals
    final deals = mockDeals
        .where(
          (d) =>
              d.affiliateId == widget.affiliateId ||
              (mockData != null &&
                  d.postedBy.toLowerCase() == mockData.name.toLowerCase()),
        )
        .toList();

    if (mounted) {
      setState(() {
        _mockData = mockData;
        _page = page;
        _affiliateProducts = affiliateProds;
        _deals = deals;
        _bioCtrl.text = page.bio.isNotEmpty ? page.bio : (mockData?.bio ?? '');
        _editColorHex = page.themeColorHex != '#7C3AED'
            ? page.themeColorHex
            : (mockData?.themeColorHex ?? '#7C3AED');
        _loading = false;
      });
    }
  }

  Color get _themeColor {
    final hex = _page?.themeColorHex ?? _mockData?.themeColorHex ?? '#7C3AED';
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  String get _displayName =>
      _mockData?.name ?? _page?.displayName ?? widget.affiliateName;

  String get _bio =>
      _bioCtrl.text.isNotEmpty ? _bioCtrl.text : (_mockData?.bio ?? '');

  Future<void> _saveEdits() async {
    if (_page == null) return;
    final updated = _page!.copyWith(
      bio: _bioCtrl.text.trim(),
      themeColorHex: _editColorHex,
    );
    await _pageService.savePage(updated);
    setState(() {
      _page = updated;
      _editMode = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vitrine atualizada com sucesso!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final themeColor = _themeColor;

    return Scaffold(
      backgroundColor: colors.background,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(child: _buildHeader(themeColor, colors)),
                if (_bio.isNotEmpty)
                  SliverToBoxAdapter(child: _buildBio(colors, themeColor)),
                if (widget.isOwner)
                  SliverToBoxAdapter(
                    child: _buildOwnerPanel(themeColor, colors),
                  ),
                SliverToBoxAdapter(child: _buildTabBar(themeColor, colors)),
              ],
              body: SafeArea(
                bottom: false,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDealsTab(colors, themeColor),
                    _buildProductsTab(colors, themeColor),
                  ],
                ),
              ),
            ),
    );
  }

  // ─── Tab Bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar(Color themeColor, AppThemeColors colors) {
    return Container(
      color: colors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: themeColor,
        unselectedLabelColor: colors.textMuted,
        indicatorColor: themeColor,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_offer_rounded, size: 15),
                const SizedBox(width: 6),
                Text('Deals (${_deals.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag_rounded, size: 15),
                const SizedBox(width: 6),
                Text('Produtos (${_affiliateProducts.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Deals Tab ──────────────────────────────────────────────────────────────

  Widget _buildDealsTab(AppThemeColors colors, Color themeColor) {
    if (_deals.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.local_offer_rounded,
        title: 'Nenhum deal publicado ainda',
        subtitle: 'Os deals deste afiliado aparecerão aqui.',
        themeColor: themeColor,
        colors: colors,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
      itemCount: _deals.length,
      itemBuilder: (context, index) {
        final deal = _deals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child:
              DealCard(
                    deal: deal,
                    heroTagPrefix: 'affiliate_page_',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DealDetailScreen(
                          deal: deal,
                          heroTagPrefix: 'affiliate_page_',
                        ),
                      ),
                    ),
                  )
                  .animate(delay: Duration(milliseconds: index * 50))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.05, end: 0),
        );
      },
    );
  }

  // ─── Products Tab ───────────────────────────────────────────────────────────

  Widget _buildProductsTab(AppThemeColors colors, Color themeColor) {
    if (_affiliateProducts.isEmpty) {
      return _buildEmptyTab(
        icon: Icons.shopping_bag_rounded,
        title: 'Nenhum produto na vitrine',
        subtitle: widget.isOwner
            ? 'Adicione produtos pelo painel de afiliado.'
            : 'Este afiliado ainda não adicionou produtos.',
        themeColor: themeColor,
        colors: colors,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _affiliateProducts.length,
      itemBuilder: (context, i) =>
          _buildProductCard(_affiliateProducts[i], themeColor, colors),
    );
  }

  Widget _buildEmptyTab({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color themeColor,
    required AppThemeColors colors,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: themeColor),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: colors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(Color themeColor, AppThemeColors colors) {
    final initial = _displayName.isNotEmpty
        ? _displayName[0].toUpperCase()
        : 'A';

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        image: DecorationImage(
          image: const AssetImage('assets/images/pattern.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            colors.background.withValues(alpha: 0.95),
            BlendMode.darken,
          ),
        ),
        boxShadow: [
          BoxShadow(color: colors.background, blurRadius: 30, spreadRadius: 10),
        ],
      ),
      child: Stack(
        children: [
          // Efeito de Glow ao fundo
          Positioned(
            top: -50,
            left: -50,
            right: -50,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              // Back + editar
              SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surfaceElevated.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colors.border.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: colors.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (widget.isOwner)
                      GestureDetector(
                        onTap: () => setState(() => _editMode = !_editMode),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: themeColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _editMode
                                    ? Icons.close_rounded
                                    : Icons.edit_rounded,
                                color: themeColor,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _editMode ? 'Cancelar' : 'Personalizar',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Avatar
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [themeColor, themeColor.withValues(alpha: 0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: colors.background, width: 3),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 12),

              // Nome
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _displayName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statChip(
                    icon: Icons.local_offer_rounded,
                    label:
                        '${_deals.length + (_mockData?.totalDeals ?? 0)} deals',
                    color: themeColor,
                  ),
                  const SizedBox(width: 8),
                  _statChip(
                    icon: Icons.star_rounded,
                    label: '${_mockData?.rating.toStringAsFixed(1) ?? "4.8"}',
                    color: themeColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required Color color,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor ?? color,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bio ────────────────────────────────────────────────────────────────────

  Widget _buildBio(AppThemeColors colors, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: themeColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.format_quote_rounded, color: themeColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _bio,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Owner Panel ─────────────────────────────────────────────────────────────

  Widget _buildOwnerPanel(Color themeColor, AppThemeColors colors) {
    if (!_editMode) return const SizedBox();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERSONALIZAR VITRINE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: themeColor,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 14),

          // Bio
          TextFormField(
            controller: _bioCtrl,
            maxLines: 3,
            style: TextStyle(color: colors.textPrimary, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Bio / Apresentação',
              labelStyle: TextStyle(color: colors.textMuted),
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: themeColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Cor temática
          Text(
            'COR TEMÁTICA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _colorOptions.map((item) {
              final (hex, label) = item;
              final col = _hexColor(hex);
              final isSelected = _editColorHex == hex;
              return GestureDetector(
                onTap: () => setState(() => _editColorHex = hex),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: col,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: col.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // Botão salvar
          GestureDetector(
            onTap: _saveEdits,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColor, themeColor.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Salvar Alterações',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05);
  }

  // ─── Product Card ────────────────────────────────────────────────────────────

  Widget _buildProductCard(
    AffiliateProduct product,
    Color themeColor,
    AppThemeColors colors,
  ) {
    return GestureDetector(
      onTap: () => _showProductSheet(product, themeColor),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: product.imageUrls.isNotEmpty
                    ? Image.asset(
                        product.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: colors.surfaceElevated,
                          child: Icon(
                            Icons.image_rounded,
                            color: colors.textMuted,
                            size: 32,
                          ),
                        ),
                      )
                    : Container(
                        color: colors.surfaceElevated,
                        child: Icon(
                          Icons.image_rounded,
                          color: colors.textMuted,
                          size: 32,
                        ),
                      ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.savings,
                      ),
                    ),
                    if (product.discountPercent > 0)
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${product.discountPercent.toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: themeColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductSheet(AffiliateProduct product, Color themeColor) {
    final colors = context.appColors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (ctx, scrollCtrl) => Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    if (product.imageUrls.isNotEmpty)
                      _buildImageCarousel(
                        product.imageUrls,
                        themeColor,
                        colors,
                      ),
                    const SizedBox(height: 16),
                    Text(
                      product.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'R\$ ${product.price.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.savings,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'R\$ ${product.originalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                'https://AchouAchado.com/produto/${product.id}?ref=${product.affiliateId}',
                          ),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Link de afiliado copiado!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: themeColor,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.link_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Copiar Link de Afiliado',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(
    List<String> urls,
    Color themeColor,
    AppThemeColors colors,
  ) {
    if (urls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.asset(
            urls.first,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: colors.surfaceElevated,
              child: Icon(
                Icons.image_rounded,
                color: colors.textMuted,
                size: 36,
              ),
            ),
          ),
        ),
      );
    }

    final pageCtrl = PageController();
    int currentPage = 0;
    return StatefulBuilder(
      builder: (ctx, setS) {
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: PageView.builder(
                  controller: pageCtrl,
                  itemCount: urls.length,
                  onPageChanged: (i) => setS(() => currentPage = i),
                  itemBuilder: (_, i) => Image.asset(
                    urls[i],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: colors.surfaceElevated,
                      child: Icon(
                        Icons.image_rounded,
                        color: colors.textMuted,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                urls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == currentPage ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == currentPage ? themeColor : colors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }
}
