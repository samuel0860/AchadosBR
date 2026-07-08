import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/deal.dart';

class FilterBottomSheet extends StatefulWidget {
  final String initialSortBy;
  final DealCategory? initialCategory;

  const FilterBottomSheet({
    super.key,
    required this.initialSortBy,
    this.initialCategory,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _sortBy;
  late DealCategory? _category;

  @override
  void initState() {
    super.initState();
    _sortBy = widget.initialSortBy;
    _category = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Filtrar e Ordenar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ORDENAR POR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSortOption('hot', 'Mais Quentes', Icons.local_fire_department_rounded),
              _buildSortOption('new', 'Mais Novos', Icons.auto_awesome_rounded),
              _buildSortOption('discount', 'Maior Desconto', Icons.sell_rounded),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'CATEGORIA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryOption(null, 'Todas', Icons.all_inclusive_rounded),
              ...DealCategory.values.map((cat) => _buildCategoryOption(
                    cat,
                    cat.name[0].toUpperCase() + cat.name.substring(1),
                    _categoryIcon(cat),
                  )),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'sortBy': _sortBy,
                  'category': _category,
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSortOption(String value, String label, IconData icon) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryOption(DealCategory? value, String label, IconData icon) {
    final isSelected = _category == value;
    return GestureDetector(
      onTap: () => setState(() => _category = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
}
