import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/screens/apps/traceroute/map/hops_tab.dart';

void main() {
  group('Hops Tab Tests', () {
    testWidgets('Hops tab shows data correctly', (WidgetTester tester) async {
      // Create mock hop data
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 5,
          'flag': '🏠',
        },
        {
          'hopNumber': 2,
          'address': '10.0.0.1',
          'responseTime': 15,
          'flag': '🌐',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      expect(find.text('Hop 1'), findsOneWidget);
      expect(find.text('IP: 192.168.1.1'), findsOneWidget);
      expect(find.text('5 ms'), findsOneWidget);
      expect(find.text('🏠'), findsOneWidget);

      expect(find.text('Hop 2'), findsOneWidget);
      expect(find.text('IP: 10.0.0.1'), findsOneWidget);
      expect(find.text('15 ms'), findsOneWidget);
      expect(find.text('🌐'), findsOneWidget);
    });

    // More tests would go here
  });
}
