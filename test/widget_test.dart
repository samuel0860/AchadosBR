import 'package:flutter_test/flutter_test.dart';
import 'package:achados_br/main.dart';
import 'package:achados_br/services/auth_service.dart';

void main() {
  testWidgets('AchadosBR smoke test', (WidgetTester tester) async {
    final auth = AuthService();
    await auth.init();
    await tester.pumpWidget(AchadosBRApp(authService: auth));
    expect(find.byType(AchadosBRApp), findsOneWidget);
  });
}
