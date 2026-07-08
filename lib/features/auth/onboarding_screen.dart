import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../app/theme.dart';
import '../../services/app_config_service.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Bem-vindo ao\nAchouAchado',
      'subtitle': 'Os melhores descontos e cupons do Brasil na palma da sua mão. Preparamos uma seleção exclusiva para você economizar todos os dias.',
      'icon': 'shopping_bag_rounded',
    },
    {
      'title': 'Economia\nde Verdade',
      'subtitle': 'Nossa comunidade de caçadores de ofertas compartilha promoções relâmpago que você não encontra em nenhum outro lugar.',
      'icon': 'local_fire_department_rounded',
    },
    {
      'title': 'Seja um\nAfiliado',
      'subtitle': 'Crie sua vitrine personalizada, recomende seus achados favoritos e ganhe comissões pelas suas indicações.',
      'icon': 'workspace_premium_rounded',
    },
  ];

  IconData _getIconData(String name) {
    switch (name) {
      case 'shopping_bag_rounded':
        return Icons.shopping_bag_rounded;
      case 'local_fire_department_rounded':
        return Icons.local_fire_department_rounded;
      case 'workspace_premium_rounded':
        return Icons.workspace_premium_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await AppConfigService().completeOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    Color(0xFF1E103A),
                    Color(0xFF0A0A14),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: AppGradients.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getIconData(page['icon']!),
                                size: 50,
                                color: Colors.white,
                              ),
                            ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 50),
                            Text(
                              page['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 20),
                            Text(
                              page['subtitle']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Dots Indicator
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.primary : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      // Next / Start Button
                      GestureDetector(
                        onTap: _nextPage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.symmetric(
                            horizontal: _currentPage == _pages.length - 1 ? 24 : 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppGradients.primaryGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1 ? 'Começar' : 'Próximo',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (_currentPage < _pages.length - 1) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                              ]
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
