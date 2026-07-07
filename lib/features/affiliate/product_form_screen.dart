import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import '../../models/affiliate_product.dart';
import '../../models/store_brand.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';

class ProductFormScreen extends StatefulWidget {
  final AffiliateProduct? product; // null = new product

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _titleCtrl = TextEditingController(text: widget.product?.title ?? '');
  late final _descCtrl = TextEditingController(text: widget.product?.description ?? '');
  late final _priceCtrl = TextEditingController(
      text: widget.product?.price.toStringAsFixed(2) ?? '');
  late final _origPriceCtrl = TextEditingController(
      text: widget.product?.originalPrice.toStringAsFixed(2) ?? '');
  late final _discountCtrl = TextEditingController(
      text: widget.product?.discountPercent.toStringAsFixed(0) ?? '');
  late final _couponCtrl = TextEditingController(text: widget.product?.couponCode ?? '');

  late BadgePosition _badgePosition = widget.product?.badgePosition ?? BadgePosition.topLeft;
  late String _highlightColor = widget.product?.highlightColor ?? '#EF4444';
  late String _category = widget.product?.category ?? 'eletronicos';
  late bool _hasFreeShipping = widget.product?.hasFreeShipping ?? false;
  late List<String> _imageAssets = List<String>.from(widget.product?.imageUrls ?? []);
  late String _selectedStoreId = widget.product?.storeId ?? '';

  bool _isLoading = false;

  final _colorOptions = [
    ('#EF4444', 'Vermelho'),
    ('#7C3AED', 'Roxo'),
    ('#10B981', 'Verde'),
    ('#F59E0B', 'Dourado'),
    ('#3B82F6', 'Azul'),
    ('#EC4899', 'Rosa'),
    ('#D4AF37', 'Ouro'),
    ('#F97316', 'Laranja'),
  ];

  // MethodChannel para galeria nativa do Android
  static const _galleryChannel = MethodChannel('com.achadosapp/gallery');

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _origPriceCtrl.dispose();
    _discountCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final user = AuthService().currentUser;
    final price = double.tryParse(_priceCtrl.text.replaceAll(',', '.')) ?? 0;
    final origPrice = double.tryParse(_origPriceCtrl.text.replaceAll(',', '.')) ?? 0;
    final discount = double.tryParse(_discountCtrl.text) ?? 0;

    final brand = findStoreBrand(_selectedStoreId);
    final storeName = brand?.name ?? '';

    final product = AffiliateProduct(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: price,
      originalPrice: origPrice,
      discountPercent: discount,
      badgePosition: _badgePosition,
      imageUrls: _imageAssets,
      highlightColor: _highlightColor,
      isActive: widget.product?.isActive ?? true,
      affiliateId: user?.id ?? '',
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      couponCode: _couponCtrl.text.trim().isEmpty ? null : _couponCtrl.text.trim(),
      store: storeName,
      storeId: _selectedStoreId,
      category: _category,
      hasFreeShipping: _hasFreeShipping,
    );

    if (widget.product == null) {
      await ProductService().addProduct(product);
    } else {
      await ProductService().updateProduct(product);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.product == null ? 'Novo Produto' : 'Editar Produto'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                : const Text('Salvar',
                    style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            // ─── Preview ────────────────────────────────────────────────────
            _buildPreview(),
            const SizedBox(height: 20),

            // ─── Informações do Produto ──────────────────────────────────────
            _buildSectionTitle('Informações do Produto'),
            _buildField(_titleCtrl, 'Título', Icons.title_rounded,
                validator: (v) =>
                    v?.isEmpty == true ? 'Informe o título' : null),
            const SizedBox(height: 12),
            _buildField(_descCtrl, 'Descrição', Icons.description_rounded,
                maxLines: 3),
            const SizedBox(height: 20),

            // ─── Loja / Marketplace ──────────────────────────────────────────
            _buildSectionTitle('Loja / Marketplace'),
            _buildStorePicker(),
            const SizedBox(height: 20),

            // ─── Preços e Desconto ───────────────────────────────────────────
            _buildSectionTitle('Preços e Desconto'),
            Row(
              children: [
                Expanded(
                  child: _buildField(_origPriceCtrl, 'Preço original',
                      Icons.price_change_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                      ],
                      validator: (v) =>
                          v?.isEmpty == true ? 'Obrigatório' : null),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildField(_priceCtrl, 'Preço promocional',
                      Icons.local_offer_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))
                      ],
                      validator: (v) =>
                          v?.isEmpty == true ? 'Obrigatório' : null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    _discountCtrl,
                    'Desconto (%)',
                    Icons.percent_rounded,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) =>
                        v?.isEmpty == true ? 'Obrigatório' : null,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildField(
                      _couponCtrl, 'Cupom (opcional)', Icons.discount_rounded),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ─── Imagem do Produto ───────────────────────────────────────────
            _buildSectionTitle('Imagem do Produto'),
            _buildImagePicker(),
            const SizedBox(height: 20),

            // ─── Selo de Desconto ────────────────────────────────────────────
            _buildSectionTitle('Selo de Desconto'),
            _buildBadgePositionPicker(),
            const SizedBox(height: 20),

            // ─── Cor de Destaque do Selo ─────────────────────────────────────
            _buildSectionTitle('Cor de Destaque do Selo'),
            _buildColorPicker(),
            const SizedBox(height: 20),

            // ─── Categoria ───────────────────────────────────────────────────
            _buildSectionTitle('Categoria'),
            _buildCategoryPicker(),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: _hasFreeShipping,
                  activeColor: AppColors.primary,
                  onChanged: (v) =>
                      setState(() => _hasFreeShipping = v ?? false),
                ),
                const Text('Frete grátis',
                    style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Store Picker ──────────────────────────────────────────────────────────

  Widget _buildStorePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner da loja selecionada
        if (_selectedStoreId.isNotEmpty) ...[
          _buildSelectedStoreBanner(),
          const SizedBox(height: 12),
        ],
        // Grade de logos das lojas
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kStoreBrands.map((store) {
            final isSelected = _selectedStoreId == store.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedStoreId = store.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? store.primaryColor
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? store.primaryColor : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: store.primaryColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo da loja (imagem real com fallback)
                    StoreLogo(
                      store: store,
                      size: 28,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      store.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? store.textColor
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_circle_rounded,
                          size: 14,
                          color: store.textColor.withValues(alpha: 0.9)),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedStoreBanner() {
    final store = findStoreBrand(_selectedStoreId)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: store.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: store.primaryColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          StoreLogo(
            store: store,
            size: 36,
            borderRadius: BorderRadius.circular(9),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: store.primaryColor,
                  ),
                ),
                const Text(
                  'Loja selecionada',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _selectedStoreId = ''),
            child: const Icon(Icons.close_rounded,
                size: 18, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ─── Preview ───────────────────────────────────────────────────────────────

  Widget _buildPreview() {
    final color = _hexColor(_highlightColor);
    final discount = _discountCtrl.text.isEmpty ? '0' : _discountCtrl.text;
    final store = findStoreBrand(_selectedStoreId);
    final firstImage = _imageAssets.isNotEmpty ? _imageAssets.first : null;

    Widget imageWidget;
    if (firstImage != null) {
      if (firstImage.startsWith('assets/')) {
        imageWidget = Image.asset(firstImage, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.image_rounded, size: 48, color: AppColors.textMuted)));
      } else {
        imageWidget = Image.file(File(firstImage), fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Center(
                child: Icon(Icons.image_rounded, size: 48, color: AppColors.textMuted)));
      }
    } else {
      imageWidget = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_rounded, size: 48, color: AppColors.textMuted),
            SizedBox(height: 8),
            Text('Preview da imagem',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: _imageAssets.length < 5 ? _pickFromGallery : null,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _imageAssets.isEmpty
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Positioned.fill(child: imageWidget),
              // Ícone de adicionar imagem quando vazio
              if (firstImage == null)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.add_photo_alternate_rounded,
                        size: 18, color: AppColors.primary),
                  ),
                ),
              // Selo de desconto
              if (firstImage != null)
                Positioned.fill(
                  child: Align(
                    alignment: _badgePosition.alignment,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Text('-$discount%',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              // Badge da loja
              if (store != null)
                Positioned(
                  top: 8, left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StoreLogo(store: store, size: 18, borderRadius: BorderRadius.circular(4)),
                        const SizedBox(width: 5),
                        Text(store.name, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              // Label de preview
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                    ),
                  ),
                  child: Text(
                    firstImage == null
                        ? 'Toque para adicionar foto'
                        : '← Preview em tempo real →',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: firstImage == null
                          ? AppColors.primary.withValues(alpha: 0.9)
                          : Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Image Picker ─────────────────────────────────────────────────────────

  Future<void> _pickFromGallery() async {
    try {
      final remaining = 5 - _imageAssets.length;
      if (remaining <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Máximo de 5 imagens atingido.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final List<dynamic>? paths = await _galleryChannel.invokeMethod('pickImages');
      if (paths != null && paths.isNotEmpty) {
        setState(() {
          for (final p in paths) {
            if (_imageAssets.length < 5) _imageAssets.add(p as String);
          }
        });
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao acessar galeria: ${e.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickFromCamera() async {
    // Câmera via galeria nativa — na versão sem image_picker, abrimos galeria
    await _pickFromGallery();
  }

  Widget _buildImageItem(String path, int i) {
    Widget thumb;
    if (path.startsWith('assets/')) {
      thumb = Image.asset(path, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_rounded, color: AppColors.textMuted));
    } else {
      thumb = Image.file(File(path), fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.image_rounded, color: AppColors.textMuted));
    }

    return Stack(
      key: ValueKey(path + i.toString()),
      children: [
        Container(
          width: 70, height: 70,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: i == 0 ? AppColors.primary : AppColors.border,
              width: i == 0 ? 2.5 : 1,
            ),
          ),
          child: ClipRRect(borderRadius: BorderRadius.circular(9), child: thumb),
        ),
        Positioned(
          top: 0, right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _imageAssets.removeAt(i)),
            child: Container(
              width: 18, height: 18,
              decoration: const BoxDecoration(color: AppColors.hot, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
            ),
          ),
        ),
        if (i == 0)
          Positioned(
            bottom: 2, left: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
              child: const Text('Capa',
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Botões de ação ───────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _imageAssets.length < 5 ? _pickFromGallery : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _imageAssets.length < 5
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library_rounded, size: 20,
                          color: _imageAssets.length < 5
                              ? AppColors.primary
                              : AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text('Galeria',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: _imageAssets.length < 5
                                ? AppColors.primary
                                : AppColors.textMuted,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: _imageAssets.length < 5 ? _pickFromCamera : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _imageAssets.length < 5
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_rounded, size: 20,
                          color: _imageAssets.length < 5
                              ? AppColors.primary
                              : AppColors.textMuted),
                      const SizedBox(width: 8),
                      Text('Câmera',
                          style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: _imageAssets.length < 5
                                ? AppColors.primary
                                : AppColors.textMuted,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          _imageAssets.isEmpty
              ? 'Nenhuma imagem selecionada (máx. 5)'
              : '${_imageAssets.length}/5 imagem(ns) • Toque no ✕ para remover',
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        // ─── Thumbs das imagens selecionadas ─────────────────────────────
        if (_imageAssets.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 76,
            child: ReorderableListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _imageAssets.length,
              buildDefaultDragHandles: true,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final item = _imageAssets.removeAt(oldIndex);
                  _imageAssets.insert(newIndex, item);
                });
              },
              itemBuilder: (context, i) => _buildImageItem(_imageAssets[i], i),
            ),
          ),
          const SizedBox(height: 4),
          const Text('Arraste para reordenar • A primeira é a capa',
              style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ],
    );
  }

  // ─── Badge Position Picker ─────────────────────────────────────────────────

  Widget _buildBadgePositionPicker() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.5,
      children: [
        _buildPositionOption(BadgePosition.topLeft),
        _buildPositionOption(BadgePosition.topRight),
        _buildPositionOption(BadgePosition.center),
        _buildPositionOption(BadgePosition.bottomLeft),
        _buildPositionOption(BadgePosition.bottomRight),
      ],
    );
  }

  Widget _buildPositionOption(BadgePosition pos) {
    final isSelected = _badgePosition == pos;
    return GestureDetector(
      onTap: () => setState(() => _badgePosition = pos),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            pos.label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  // ─── Color Picker ──────────────────────────────────────────────────────────

  Widget _buildColorPicker() {
    return Wrap(
      spacing: 10,
      children: _colorOptions.map((item) {
        final (hex, label) = item;
        final color = _hexColor(hex);
        final isSelected = _highlightColor == hex;
        return GestureDetector(
          onTap: () => setState(() => _highlightColor = hex),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 3)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: color.withValues(alpha: 0.6),
                              blurRadius: 8)
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 18)
                    : null,
              ),
              const SizedBox(height: 3),
              Text(label,
                  style: const TextStyle(
                      fontSize: 9, color: AppColors.textMuted)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── Category Picker ───────────────────────────────────────────────────────

  Widget _buildCategoryPicker() {
    const categories = [
      ('eletronicos', 'Eletrônicos', Icons.devices_rounded),
      ('moda', 'Moda', Icons.checkroom_rounded),
      ('casa', 'Casa', Icons.home_rounded),
      ('beleza', 'Beleza', Icons.face_retouching_natural_rounded),
      ('jogos', 'Jogos', Icons.sports_esports_rounded),
      ('esporte', 'Esporte', Icons.sports_soccer_rounded),
      ('outros', 'Outros', Icons.shopping_bag_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((item) {
        final (value, label, icon) = item;
        final isSelected = _category == value;
        return GestureDetector(
          onTap: () => setState(() => _category = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    size: 14,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textMuted),
                const SizedBox(width: 5),
                Text(label,
                    style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 1),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.hot)),
      ),
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
