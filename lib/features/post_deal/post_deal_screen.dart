import 'package:flutter/material.dart';
import '../../app/theme.dart';

class PostDealScreen extends StatefulWidget {
  const PostDealScreen({super.key});

  @override
  State<PostDealScreen> createState() => _PostDealScreenState();
}

class _PostDealScreenState extends State<PostDealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _dealPriceController = TextEditingController();
  final _couponController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;
  bool _hasFreeShipping = false;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _originalPriceController.dispose();
    _dealPriceController.dispose();
    _couponController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Postar Achado'),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(Icons.link_rounded, 'Link da Oferta'),
              _buildTextField(
                controller: _urlController,
                hint: 'Cole o link do produto aqui...',
                icon: Icons.link_rounded,
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(Icons.title_rounded, 'Título do Produto'),
              _buildTextField(
                controller: _titleController,
                hint: 'Ex: iPhone 15 Pro Max 256GB...',
                icon: Icons.title_rounded,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(Icons.attach_money_rounded, 'Preços'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _originalPriceController,
                      hint: 'Preço original',
                      icon: Icons.price_change_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _dealPriceController,
                      hint: 'Preço achado',
                      icon: Icons.local_offer_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(Icons.confirmation_number_rounded, 'Cupom (opcional)'),
              _buildTextField(
                controller: _couponController,
                hint: 'Ex: PROMO50',
                icon: Icons.confirmation_number_rounded,
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(Icons.category_rounded, 'Categoria'),
              _buildCategorySelector(),
              const SizedBox(height: 20),
              _buildFreteToggle(),
              const SizedBox(height: 20),
              _buildSectionTitle(Icons.description_rounded, 'Descrição'),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Descreva os detalhes da oferta...',
                icon: Icons.description_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      (Icons.devices_rounded, 'Eletrônicos', 'eletronicos'),
      (Icons.checkroom_rounded, 'Moda', 'moda'),
      (Icons.home_rounded, 'Casa', 'casa'),
      (Icons.face_rounded, 'Beleza', 'beleza'),
      (Icons.restaurant_rounded, 'Alimentação', 'alimentacao'),
      (Icons.sports_esports_rounded, 'Jogos', 'jogos'),
      (Icons.sports_soccer_rounded, 'Esporte', 'esporte'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat.$3;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat.$3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(cat.$1,
                    size: 14,
                    color: isSelected ? AppColors.primary : AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  cat.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFreteToggle() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.savings.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_shipping_rounded,
                color: AppColors.savings, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Frete Grátis',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Marque se o produto tem frete grátis',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: _hasFreeShipping,
            onChanged: (val) => setState(() => _hasFreeShipping = val),
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.savings,
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.savings, size: 20),
                SizedBox(width: 8),
                Text('Achado postado com sucesso!'),
              ],
            ),
            backgroundColor: AppColors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                'Publicar Achado',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
