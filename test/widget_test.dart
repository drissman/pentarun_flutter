import 'package:flutter_test/flutter_test.dart';
import 'package:pentarun_flutter/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PentarunRoot());
    expect(find.text('CONFIGURATION VAGUE'), findsOneWidget);
  });
}
