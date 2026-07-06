import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app/theme.dart';
import 'features/auth/login_screen.dart';
import 'services/auth_service.dart';
import 'shared/widgets/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure flutter_animate
  Animate.restartOnHotReload = true;

  // Initialize auth service to check persisted session
  final authService = AuthService();
  await authService.init();

  runApp(AchadosBRApp(authService: authService));
}

class AchadosBRApp extends StatelessWidget {
  final AuthService authService;

  const AchadosBRApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AchadosBR',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: _AuthGate(authService: authService),
    );
  }
}

/// Auth gate: checks session and routes accordingly
class _AuthGate extends StatelessWidget {
  final AuthService authService;

  const _AuthGate({required this.authService});

  @override
  Widget build(BuildContext context) {
    // If already authenticated, go directly to home
    if (authService.isLoggedIn) {
      return const MainScaffold();
    }
    return const LoginScreen();
  }
}
