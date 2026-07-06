import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../features/affiliate/affiliate_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/post_deal/post_deal_screen.dart';
import '../../services/auth_service.dart';
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
    AffiliateHomeScreen(),   // Home do afiliado (stats + achados)
    AffiliateScreen(),       // Painel completo do afiliado
    PostDealScreen(),        // Publicar achado
    NotificationsScreen(),   // Alertas
    ProfileScreen(),         // Perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0800),
        border: const Border(
          top: BorderSide(color: Color(0xFF2A1F00), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
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
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    const goldColor = Color(0xFFD4AF37);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? goldColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
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
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: AppColors.hot,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? goldColor : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    final isSelected = _currentIndex == 2;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        child: const Icon(
          Icons.add_rounded,
          color: Color(0xFF1A0A00),
          size: 26,
        ),
      ),
    );
  }
}
