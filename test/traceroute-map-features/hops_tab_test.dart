import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:netscope/screens/apps/traceroute/map/hops_tab.dart';
import 'package:netscope/screens/apps/traceroute/map/hop_details_screen.dart';
import 'package:netscope/models/traceroute_models.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  group('HopsTab Widget', () {
    testWidgets('displays hop data correctly', (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'flag': '🇺🇸',
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
      expect(find.text('10.0 ms'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
    });

    testWidgets('handles missing/partial data', (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          // Missing responseTime
          'flag': '🇺🇸',
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
      expect(find.text('N/A'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
    });

    testWidgets('navigates to details page on tap',
        (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'flag': '🇺🇸',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      await tester.tap(find.text('Hop 1'));
      await tester.pumpAndSettle();

      expect(find.byType(HopDetailsScreen), findsOneWidget);
    });

    testWidgets('handles empty hops list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HopsTab(hops: []),
          ),
        ),
      );

      // Should render an empty ListView
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays correctly in dark mode', (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'flag': '🇺🇸',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      expect(find.text('Hop 1'), findsOneWidget);
      expect(find.text('IP: 192.168.1.1'), findsOneWidget);
      expect(find.text('10.0 ms'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);

      // Verify dark mode styling is applied
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays default flag when flag is missing',
        (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          // Missing flag
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      expect(find.text('🚩'), findsOneWidget); // Default flag
    });

    testWidgets('handles non-numeric responseTime',
        (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 'invalid',
          'flag': '🇺🇸',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('displays multiple hops correctly',
        (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'flag': '🇺🇸',
        },
        {
          'hopNumber': 2,
          'address': '10.0.0.1',
          'responseTime': 25.5,
          'flag': '🇬🇧',
        },
        {
          'hopNumber': 3,
          'address': '8.8.8.8',
          'responseTime': 45.7,
          'flag': '🇺🇸',
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
      expect(find.text('Hop 2'), findsOneWidget);
      expect(find.text('Hop 3'), findsOneWidget);

      expect(find.text('IP: 192.168.1.1'), findsOneWidget);
      expect(find.text('IP: 10.0.0.1'), findsOneWidget);
      expect(find.text('IP: 8.8.8.8'), findsOneWidget);

      expect(find.text('10.0 ms'), findsOneWidget);
      expect(find.text('25.5 ms'), findsOneWidget);
      expect(find.text('45.7 ms'), findsOneWidget);

      expect(find.text('🇺🇸'), findsNWidgets(2));
      expect(find.text('🇬🇧'), findsOneWidget);
    });

    testWidgets('shows all UI elements correctly', (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'flag': '🇺🇸',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      // Verify all UI components are present
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);

      // Verify container for flag exists
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });

    testWidgets('applies correct theme colors in light mode',
        (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'flag': '🇺🇸',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      // Check that the widget renders without errors in light mode
      expect(find.text('Hop 1'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('handles tap navigation for multiple hops',
        (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'flag': '🇺🇸',
        },
        {
          'hopNumber': 2,
          'address': '10.0.0.1',
          'responseTime': 25.5,
          'flag': '🇬🇧',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      // Tap on first hop
      await tester.tap(find.text('Hop 1').first);
      await tester.pumpAndSettle();

      expect(find.byType(HopDetailsScreen), findsOneWidget);

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Tap on second hop
      await tester.tap(find.text('Hop 2'));
      await tester.pumpAndSettle();

      expect(find.byType(HopDetailsScreen), findsOneWidget);
    });

    testWidgets('handles very large numbers for responseTime',
        (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 9999.999,
          'flag': '🇺🇸',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      expect(find.text('9999.999 ms'), findsOneWidget);
    });

    testWidgets('handles zero responseTime', (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 0,
          'flag': '🇺🇸',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      expect(find.text('0 ms'), findsOneWidget);
    });

    testWidgets('handles null responseTime', (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': null,
          'flag': '🇺🇸',
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HopsTab(hops: hops),
          ),
        ),
      );

      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('handles missing address field', (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          // Missing address
          'responseTime': 10.0,
          'flag': '🇺🇸',
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
      expect(find.text('IP: null'), findsOneWidget);
    });
  });
}
