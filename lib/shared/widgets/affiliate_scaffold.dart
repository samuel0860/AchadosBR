import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../features/affiliate/affiliate_screen.dart';
import '../../features/affiliate/product_manager_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import 'affiliate_home_screen.dart';

/// Scaffold exclusivo para usuários AFILIADOS
class AffiliateScaffold extends StatefulWidget {
  const AffiliateScaffold({super.key});

  @override
  State<AffiliateScaffold> createState() => _AffiliateScaffoldState();
}

class _AffiliateScaffoldState extends State<AffiliateScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AffiliateHomeScreen(),       // Home do afiliado (stats + achados)
    AffiliateScreen(),           // Painel completo do afiliado
    ProductManagerScreen(),      // Gerenciar produtos
    NotificationsScreen(),       // Alertas
    ProfileScreen(),             // Perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true, // Needed for floating nav bar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0800).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
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
                _buildNavItem(Icons.home_rounded, 'Início', 0),
                _buildNavItem(Icons.workspace_premium_rounded, 'Painel', 1),
                _buildPublishButton(),
                _buildNavItem(Icons.notifications_rounded, 'Alertas', 3),
                _buildNavItem(Icons.person_rounded, 'Perfil', 4),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    const goldColor = Color(0xFFD4AF37);

    Widget item = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? goldColor.withValues(alpha: 0.15)
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
                color: isSelected ? goldColor : AppColors.textMuted,
                size: 24,
              ),
              if (index == 3)
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
              color: isSelected ? goldColor : Colors.transparent,
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

  Widget _buildPublishButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFC8922A)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              color: Color(0xFF1A0A00),
              size: 22,
            ),
            SizedBox(width: 6),
            Text(
              'Novo produto',
              style: TextStyle(
                color: Color(0xFF1A0A00),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
