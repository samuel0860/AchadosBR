import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../features/home/home_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';

/// Scaffold exclusivo para CLIENTES — sem botão de publicar produto
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  // Cliente não pode publicar produtos — apenas 4 abas
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      extendBody: true, // Needed for floating nav bar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final colors = context.appColors;
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: colors.navBarBackground.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.shopping_bag_rounded, 'Achados', 0),
                _buildNavItem(Icons.search_rounded, 'Buscar', 1),
                _buildNavItem(Icons.notifications_rounded, 'Alertas', 2),
                _buildNavItem(Icons.person_rounded, 'Perfil', 3),
              ],
            ),
          ),
        ),
      ),
    )).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final colors = context.appColors;
    
    Widget item = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : colors.textMuted,
                size: 24,
              ),
              if (index == 2)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.hot,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: isSelected ? 11 : 0,
              fontWeight: FontWeight.w700,
              color: isSelected ? AppColors.primary : Colors.transparent,
              height: isSelected ? 1 : 0,
            ),
            child: Text(label),
          ),
        ],
      ),
    );

    if (isSelected) {
      item = item.animate(key: ValueKey(index)).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 300.ms,
          curve: Curves.easeOutBack);
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: item,
    );
  }
}
