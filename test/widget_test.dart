import 'package:flutter_test/flutter_test.dart';
import 'package:proyek2/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows login screen when no session exists', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('JASAKU'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
