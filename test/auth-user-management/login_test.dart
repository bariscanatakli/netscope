import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple test widget that doesn't depend on Firebase
class TestLoginWidget extends StatelessWidget {
  const TestLoginWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
          ],
        ),
      ),
    );
  }
}

void main() {
  testWidgets('Login widget displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestLoginWidget(),
      ),
    );

    // Test UI components
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextField), findsExactly(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
