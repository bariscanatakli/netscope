import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:netscope/screens/auth/signup_screen.dart';

/// Mock FirebaseAuth and supporting classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {
  @override
  String get email => 'test@example.com';
}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: const SignupScreen(),
    );
  }

  testWidgets('renders all input fields and sign up button', (tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('shows snackbar when passwords do not match', (tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.enterText(find.byType(TextField).at(2), 'different123');

    await tester.tap(find.text('Sign Up'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('shows snackbar on FirebaseAuth error', (tester) async {
    when(mockFirebaseAuth.createUserWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password123',
    )).thenThrow(
      FirebaseAuthException(message: 'Fake error', code: 'error'),
    );

    await tester.pumpWidget(createTestWidget());

    await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'password123');
    await tester.enterText(find.byType(TextField).at(2), 'password123');

    await tester.tap(find.text('Sign Up'));
    await tester.pump(const Duration(seconds: 1)); // Wait for snackbar

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Fake error'), findsOneWidget);
  });
}
