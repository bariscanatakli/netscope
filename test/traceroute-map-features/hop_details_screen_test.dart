import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/screens/apps/traceroute/map/hop_details_screen.dart';

void main() {
  group('HopDetailsScreen Widget', () {
    final mockHop = {
      'hopNumber': 3,
      'address': '8.8.8.8',
      'responseTime': 42.0,
      'geolocation': {
        'city': 'Mountain View',
        'country': 'USA',
        'region': 'California',
      },
      'isp': 'Google LLC',
    };

    testWidgets('renders all hop details', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HopDetailsScreen(hop: mockHop),
        ),
      );

      expect(find.text('Hop 3 Details'), findsOneWidget);
      expect(find.text('Node 3'), findsOneWidget);
      expect(find.text('IP Address'), findsOneWidget);
      expect(find.text('8.8.8.8'), findsOneWidget);
      expect(find.text('Response Time'), findsOneWidget);
      expect(find.text('42.0 ms'), findsOneWidget);
      expect(find.text('City'), findsOneWidget);
      expect(find.text('Mountain View'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('USA'), findsOneWidget);
      expect(find.text('Region'), findsOneWidget);
      expect(find.text('California'), findsOneWidget);
      expect(find.text('ISP'), findsOneWidget);
      expect(find.text('Google LLC'), findsOneWidget);
    });
  });
} 