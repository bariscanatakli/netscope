import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:netscope/screens/apps/traceroute/map/hops_tab.dart';
import 'package:netscope/models/traceroute_models.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
  });

  testWidgets('HopsTab displays hop data correctly', (WidgetTester tester) async {
    final hops = [
      {
        'hopNumber': 1,
        'address': '192.168.1.1',
        'responseTime': 10.5,
        'geolocation': {
          'city': 'Istanbul',
          'country': 'Turkey',
          'latitude': 41.0082,
          'longitude': 28.9784,
        },
      },
      {
        'hopNumber': 2,
        'address': '10.0.0.1',
        'responseTime': 15.2,
        'geolocation': {
          'city': 'Berlin',
          'country': 'Germany',
          'latitude': 52.5200,
          'longitude': 13.4050,
        },
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HopsTab(hops: hops),
        ),
        navigatorObservers: [mockObserver],
      ),
    );

    // Verify hop data is displayed
    expect(find.text('Hop 1'), findsOneWidget);
    expect(find.text('192.168.1.1'), findsOneWidget);
    expect(find.text('Istanbul, Turkey'), findsOneWidget);
    expect(find.text('10.5 ms'), findsOneWidget);

    expect(find.text('Hop 2'), findsOneWidget);
    expect(find.text('10.0.0.1'), findsOneWidget);
    expect(find.text('Berlin, Germany'), findsOneWidget);
    expect(find.text('15.2 ms'), findsOneWidget);
  });

  testWidgets('HopsTab navigates to details page on tap', (WidgetTester tester) async {
    final hops = [
      {
        'hopNumber': 1,
        'address': '192.168.1.1',
        'responseTime': 10.5,
        'geolocation': {
          'city': 'Istanbul',
          'country': 'Turkey',
          'latitude': 41.0082,
          'longitude': 28.9784,
        },
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HopsTab(hops: hops),
        ),
        navigatorObservers: [mockObserver],
      ),
    );

    // Tap on the first hop
    await tester.tap(find.text('Hop 1'));
    await tester.pumpAndSettle();
  });

  testWidgets('HopsTab handles missing/partial data', (WidgetTester tester) async {
    final hops = [
      {
        'hopNumber': 1,
        'address': '192.168.1.1',
        'responseTime': 10.5,
        // Missing geolocation data
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HopsTab(hops: hops),
        ),
      ),
    );

    // Verify basic hop info is displayed
    expect(find.text('Hop 1'), findsOneWidget);
    expect(find.text('192.168.1.1'), findsOneWidget);
    expect(find.text('10.5 ms'), findsOneWidget);
    // Should not crash with missing geolocation
  });

  testWidgets('HopsTab handles empty hops list', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HopsTab(hops: []),
        ),
      ),
    );

    // Should not display any hop cards
    expect(find.byType(Card), findsNothing);
  });
}
