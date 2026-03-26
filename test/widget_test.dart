import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pentarun_flutter/app.dart';
import 'package:pentarun_flutter/state/app_state.dart';
import 'package:pentarun_flutter/theme/a2ui_theme.dart';

// Wrapper minimal sans Supabase — teste l'UI de l'app directement
Widget _appUnderTest() {
  final state = AppState();
  return AppStateProvider(
    state: state,
    child: MaterialApp(
      theme: A2Theme.dark,
      home: const Scaffold(body: PentarunApp()),
    ),
  );
}

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(_appUnderTest());
    await tester.pump();
    expect(find.text('CONFIGURATION VAGUE'), findsOneWidget);
  });
}
