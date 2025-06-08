import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple test widget for signup functionality
class TestSignupWidget extends StatelessWidget {
  const TestSignupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
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
              child: const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Signup widget displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestSignupWidget(),
      ),
    );

    // Test UI components
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.byType(TextField), findsExactly(3));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
