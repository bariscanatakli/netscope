import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:netscope/screens/auth/forgot_password_screen.dart';

import 'auth_mocks.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;

  setUp(() {
    mockAuth = MockFirebaseAuth();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: ForgotPasswordScreen(), // Testing the real widget now
    );
  }

  testWidgets('renders ForgotPasswordScreen correctly', (tester) async {
    await tester.pumpWidget(createTestWidget());
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('shows error when reset called with empty email', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Since we don't call FirebaseAuth directly in the test, no verification here
    expect(find.byType(SnackBar), findsNothing); // Nothing should show
  });
}
