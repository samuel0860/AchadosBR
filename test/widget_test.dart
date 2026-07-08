import 'package:flutter_test/flutter_test.dart';
import 'package:achados_br/main.dart';
import 'package:achados_br/services/auth_service.dart';
import 'package:achados_br/services/theme_service.dart';

void main() {
  testWidgets('AchouAchado smoke test', (WidgetTester tester) async {
    final auth = AuthService();
    final theme = ThemeService();
    await auth.init();
    await theme.init();
    await tester.pumpWidget(
      AchouAchadoApp(authService: auth, themeService: theme),
    );
    expect(find.byType(AchouAchadoApp), findsOneWidget);
  });
}
