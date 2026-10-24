import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rootin_mobile/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App smoke test', () {
    testWidgets('app launches successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: RootinApp()));
      await tester.pumpAndSettle();

      // Verify the app launches and shows initial placeholder
      expect(find.text('Rootin Mobile'), findsOneWidget);
    });
  });
}
