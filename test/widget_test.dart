import 'package:flutter_test/flutter_test.dart';
import 'package:space_shooter/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const SpaceShooterApp());
    await tester.pump(const Duration(milliseconds: 100));

    // Verify app loads
    expect(find.text('SPACE SHOOTER'), findsOneWidget);
  });
}
