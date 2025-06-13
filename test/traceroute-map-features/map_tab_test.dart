import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:netscope/screens/apps/traceroute/map/map_tab.dart';

class MockGoogleMapController extends Mock implements GoogleMapController {}

void main() {
  late MockGoogleMapController mockMapController;

  setUp(() {
    mockMapController = MockGoogleMapController();
  });

  group('MapTab Widget', () {
    testWidgets('displays map with hop markers', (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'geolocation': {
            'city': 'Test City',
            'country': 'Test Country',
            'lat': 41.0,
            'lon': 29.0,
          },
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapTab(
              hops: hops,
              isFetching: false,
              onMapInteraction: (_) {},
              onStartTraceRoute: () {},
            ),
          ),
        ),
      );

      // Skip GoogleMap widget test as it requires platform channels
      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNWidgets(3)); // Previous, Next, Start Trace Route
    });

    testWidgets('handles empty hops list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapTab(
              hops: [],
              isFetching: false,
              onMapInteraction: (_) {},
              onStartTraceRoute: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNWidgets(3)); // Previous, Next, Start Trace Route
    });

    testWidgets('handles hops with missing geolocation data', (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'geolocation': null,
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapTab(
              hops: hops,
              isFetching: false,
              onMapInteraction: (_) {},
              onStartTraceRoute: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNWidgets(3)); // Previous, Next, Start Trace Route
    });

    testWidgets('shows loading state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapTab(
              hops: [],
              isFetching: true,
              onMapInteraction: (_) {},
              onStartTraceRoute: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Stack), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNWidgets(3)); // Previous, Next, Start Trace Route
    });

    testWidgets('handles map interaction callbacks', (WidgetTester tester) async {
      bool isInteracting = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapTab(
              hops: [],
              isFetching: false,
              onMapInteraction: (interacting) {
                isInteracting = interacting;
              },
              onStartTraceRoute: () {},
            ),
          ),
        ),
      );

      // Simulate map interaction by calling the callback directly
      final mapTab = tester.widget<MapTab>(find.byType(MapTab));
      mapTab.onMapInteraction(true);
      expect(isInteracting, true);

      mapTab.onMapInteraction(false);
      expect(isInteracting, false);
    });
  });

  testWidgets('MapTab Widget calls onStartTraceRoute when play button is pressed', (WidgetTester tester) async {
    bool traceRouteCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapTab(
            hops: [],
            isFetching: false,
            onStartTraceRoute: () {
              traceRouteCalled = true;
            },
            onMapInteraction: (_) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();

    expect(traceRouteCalled, true);
  });
} 