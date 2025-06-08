import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple test widget for forgot password functionality
class TestForgotPasswordWidget extends StatelessWidget {
  const TestForgotPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter your email to reset password'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Send Reset Email'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Forgot password widget displays correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestForgotPasswordWidget(),
      ),
    );

    // Test UI components
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Enter your email to reset password'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Send Reset Email'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
