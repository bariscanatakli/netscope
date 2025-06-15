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

    testWidgets('displays hop details without geolocation data',
        (WidgetTester tester) async {
      final hop = {
        'hopNumber': 2,
        'address': '192.168.1.2',
        'responseTime': 25.0,
        'geolocation': null,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: HopDetailsScreen(hop: hop),
        ),
      );

      await tester.pumpAndSettle();

      // Check if app bar is displayed with correct title
      expect(find.text('Hop 2 Details'), findsOneWidget);

      // Check if IP address is displayed
      expect(find.text('IP Address'), findsOneWidget);
      expect(find.text('192.168.1.2'), findsOneWidget);

      // Check if response time is displayed
      expect(find.text('Response Time'), findsOneWidget);
      expect(find.text('25.0 ms'), findsOneWidget);

      // Location information should not be displayed
      expect(find.text('Location Information'), findsNothing);
    });

    testWidgets('displays hop details with missing data fields',
        (WidgetTester tester) async {
      final hop = {
        'hopNumber': 4,
        'address': null,
        'responseTime': null,
        'geolocation': {
          'city': null,
          'country': null,
          'region': null,
        },
        'isp': null,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: HopDetailsScreen(hop: hop),
        ),
      );

      await tester.pumpAndSettle();

      // Check if app bar is displayed with correct title
      expect(find.text('Hop 4 Details'), findsOneWidget);

      // Check if unknown values are displayed
      expect(find.text('Unknown'), findsWidgets);
    });

    testWidgets('handles edit button press', (WidgetTester tester) async {
      final hop = {
        'hopNumber': 5,
        'address': '1.1.1.1',
        'responseTime': 20.0,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: HopDetailsScreen(hop: hop),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the edit button
      final editButton = find.byIcon(Icons.edit);
      expect(editButton, findsOneWidget);

      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // The button should be tappable (no exception thrown)
      expect(editButton, findsOneWidget);
    });

    testWidgets('renders correctly in dark mode', (WidgetTester tester) async {
      final hop = {
        'hopNumber': 6,
        'address': '192.168.1.6',
        'responseTime': 30.0,
        'geolocation': {
          'city': 'Dark City',
          'country': 'Dark Country',
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: HopDetailsScreen(hop: hop),
        ),
      );

      await tester.pumpAndSettle();

      // Check if the screen renders without issues in dark mode
      expect(find.text('Hop 6 Details'), findsOneWidget);
      expect(find.text('192.168.1.6'), findsOneWidget);
      expect(find.text('Dark City'), findsOneWidget);
    });

    testWidgets('displays all required icons', (WidgetTester tester) async {
      final hop = {
        'hopNumber': 8,
        'address': '192.168.1.8',
        'responseTime': 40.0,
        'geolocation': {
          'city': 'Icon City',
          'country': 'Icon Country',
          'region': 'Icon Region',
        },
        'isp': 'Icon ISP',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: HopDetailsScreen(hop: hop),
        ),
      );

      await tester.pumpAndSettle();

      // Check if various icons are present
      expect(find.byIcon(Icons.router), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.byIcon(Icons.location_city), findsOneWidget);
      expect(find.byIcon(Icons.public), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('verifies scroll functionality', (WidgetTester tester) async {
      final hop = {
        'hopNumber': 9,
        'address': '192.168.1.9',
        'responseTime': 45.0,
        'geolocation': {
          'city': 'Scroll City',
          'country': 'Scroll Country',
          'region': 'Scroll Region',
        },
        'isp': 'Scroll ISP',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: HopDetailsScreen(hop: hop),
        ),
      );

      await tester.pumpAndSettle();

      // Check if ScrollView is present
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify content is visible
      expect(find.text('Hop 9 Details'), findsOneWidget);
    });

    testWidgets('builds info cards correctly', (WidgetTester tester) async {
      final hop = {
        'hopNumber': 10,
        'address': '192.168.1.10',
        'responseTime': 50.0,
        'geolocation': {
          'city': 'Card City',
          'country': 'Card Country',
        },
      };

      await tester.pumpWidget(
        MaterialApp(
          home: HopDetailsScreen(hop: hop),
        ),
      );

      await tester.pumpAndSettle();

      // Check if Cards are built correctly
      expect(find.byType(Card), findsAtLeastNWidgets(1));
      expect(find.byType(ListTile), findsAtLeastNWidgets(1));
    });
  });
}
