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

    testWidgets('navigates to details page on tap', (WidgetTester tester) async {
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
      expect(find.byType(Card), findsNothing);
    });
  });
}
