import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/fake_login_screen.dart';

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: FakeLoginScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Login'), findsOneWidget);
  });
}