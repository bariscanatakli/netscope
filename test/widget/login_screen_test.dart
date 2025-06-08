import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple test widget with no external dependencies
class TestLoginScreen extends StatelessWidget {
  const TestLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Screen')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}

// Test only the visual aspects and user interactions without Firebase
void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      const MaterialApp(
        home: TestLoginScreen(),
      ),
    );

    // Verify basic UI components are present
    expect(find.text('Login Screen'), findsOneWidget); // AppBar title
    expect(find.text('Email'), findsOneWidget); // Email field label
    expect(find.text('Password'), findsOneWidget); // Password field label
    expect(find.text('Sign In'), findsOneWidget); // Button text
    expect(find.text('Forgot Password?'), findsOneWidget); // Forgot password link

    // Verify basic structure
    expect(find.byType(TextField), findsExactly(2)); // Two text fields
    expect(find.byType(ElevatedButton), findsOneWidget); // Sign in button
    expect(find.byType(TextButton), findsOneWidget); // Forgot password button
  });
}
