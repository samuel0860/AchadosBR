import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app/theme.dart';
import 'features/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'services/review_service.dart';
import 'services/product_service.dart';
import 'services/user_data_service.dart';
import 'shared/widgets/main_scaffold.dart';
import 'shared/widgets/affiliate_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Permite que o conteúdo Flutter seja desenhado atrás das barras do sistema
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  Animate.restartOnHotReload = true;

  // Initialize all services
  final authService = AuthService();
  final themeService = ThemeService();
  final reviewService = ReviewService();
  final productService = ProductService();
  final userDataService = UserDataService();

  await Future.wait([
    authService.init(),
    themeService.init(),
    reviewService.init(),
    productService.init(),
    userDataService.init(),
  ]);

  runApp(AchadosBRApp(
    authService: authService,
    themeService: themeService,
  ));
}

class AchadosBRApp extends StatelessWidget {
  final AuthService authService;
  final ThemeService themeService;

  const AchadosBRApp({
    super.key,
    required this.authService,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        ThemeMode flutterThemeMode;
        switch (themeService.mode) {
          case AppThemeMode.dark:
            flutterThemeMode = ThemeMode.dark;
          case AppThemeMode.light:
            flutterThemeMode = ThemeMode.light;
          case AppThemeMode.system:
            flutterThemeMode = ThemeMode.system;
        }

        return MaterialApp(
          title: 'AchadosBR',
          debugShowCheckedModeBanner: false,
          theme: appThemeLight(),
          darkTheme: appTheme(),
          themeMode: flutterThemeMode,
          home: _AuthGate(authService: authService),
        );
      },
    );
  }
}

class _AuthGate extends StatelessWidget {
  final AuthService authService;

  const _AuthGate({required this.authService});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authService,
      builder: (context, _) {
        if (!authService.isLoggedIn) {
          return const LoginScreen();
        }
        // Rota diferente para Afiliado e Cliente
        if (authService.isAffiliate) {
          return const AffiliateScaffold();
        }
        return const MainScaffold();
      },
    );
  }
}
