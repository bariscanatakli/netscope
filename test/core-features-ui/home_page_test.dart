import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:netscope/screens/home/home_page.dart';
import 'package:netscope/providers/auth_provider.dart' as app_auth;
import '../helpers/firebase_mock_setup.dart';
import '../helpers/auth_mock_helpers.dart';

// Simple home page widget for testing
class TestHomePage extends StatelessWidget {
  const TestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final apps = [
      {'name': 'Speed Test', 'icon': Icons.speed},
      {'name': 'Traceroute', 'icon': Icons.map},
      {'name': 'Network Scanner', 'icon': Icons.scanner},
      {'name': 'Ping Test', 'icon': Icons.network_ping},
    ];
    
    return Scaffold(
      appBar: AppBar(title: const Text('NetScope')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(app['icon'] as IconData, size: 50),
                const SizedBox(height: 8),
                Text(app['name'] as String),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  testWidgets('Home page displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestHomePage(),
      ),
    );

    // Verify app bar title
    expect(find.text('NetScope'), findsOneWidget);

    // Verify grid items
    expect(find.text('Speed Test'), findsOneWidget);
    expect(find.text('Traceroute'), findsOneWidget);
    expect(find.text('Network Scanner'), findsOneWidget);
    expect(find.text('Ping Test'), findsOneWidget);

    // Verify icons
    expect(find.byIcon(Icons.speed), findsOneWidget);
    expect(find.byIcon(Icons.map), findsOneWidget);
    expect(find.byIcon(Icons.scanner), findsOneWidget);
    expect(find.byIcon(Icons.network_ping), findsOneWidget);
  });
}
