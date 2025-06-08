import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple favorites page widget for testing
class TestFavoritesPage extends StatelessWidget {
  const TestFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock favorites data
    final favorites = ['Speed Test', 'Traceroute', 'Network Scanner'];

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.favorite),
                    title: Text(favorites[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
    );
  }
}

void main() {
  testWidgets('Favorites page displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestFavoritesPage(),
      ),
    );

    // Test assertions
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('Speed Test'), findsOneWidget);
    expect(find.text('Traceroute'), findsOneWidget);
    expect(find.text('Network Scanner'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsAtLeast(1));
    expect(find.byIcon(Icons.delete), findsAtLeast(1));
  });
}
