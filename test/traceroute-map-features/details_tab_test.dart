import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/screens/apps/traceroute/map/details_tab.dart';

void main() {
  group('DetailsTab Widget', () {
    final mockHops = [
      {
        'hopNumber': 1,
        'address': '192.168.1.1',
        'responseTime': 10.5,
        'geolocation': {'city': 'Istanbul', 'country': 'Turkey'},
      },
      {
        'hopNumber': 2,
        'address': '10.0.0.1',
        'responseTime': 20.0,
        'geolocation': {'city': 'Berlin', 'country': 'Germany'},
      },
    ];

    testWidgets('renders hop details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DetailsTab(tracerouteDetails: mockHops),
        ),
      );

      // Tap to expand first hop
      await tester.tap(find.text('Hop 1'));
      await tester.pumpAndSettle();

      expect(find.text('Hop 1'), findsOneWidget);
      expect(find.text('192.168.1.1'), findsOneWidget);
      expect(find.text('Istanbul'), findsOneWidget);
      expect(find.text('Turkey'), findsOneWidget);
      expect(find.text('10.5ms'), findsOneWidget);

      // Tap to expand second hop
      await tester.tap(find.text('Hop 2'));
      await tester.pumpAndSettle();

      expect(find.text('Hop 2'), findsOneWidget);
      expect(find.text('10.0.0.1'), findsOneWidget);
      expect(find.text('Berlin'), findsOneWidget);
      expect(find.text('Germany'), findsOneWidget);
      expect(find.text('20.0ms'), findsOneWidget);
    });
  });
} 