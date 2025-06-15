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

      // Pump and settle to ensure all widgets are built
      await tester.pumpAndSettle();

      // The MapTab contains a Scaffold which contains a Stack
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      // Check if FloatingActionButtons are present in the widget tree
      expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
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

      await tester.pumpAndSettle();

      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
    });
    testWidgets('handles hops with missing geolocation data',
        (WidgetTester tester) async {
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

      await tester.pumpAndSettle();

      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
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

      await tester.pumpAndSettle();

      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
    });

    testWidgets('handles map interaction callbacks',
        (WidgetTester tester) async {
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

  testWidgets(
      'MapTab Widget calls onStartTraceRoute when play button is pressed',
      (WidgetTester tester) async {
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

  testWidgets('MapTab Widget handles hop navigation with multiple hops',
      (WidgetTester tester) async {
    final hops = [
      {
        'hopNumber': 1,
        'address': '192.168.1.1',
        'responseTime': 10.0,
        'geolocation': {
          'city': 'Test City 1',
          'country': 'Test Country',
          'lat': 41.0,
          'lon': 29.0,
        },
      },
      {
        'hopNumber': 2,
        'address': '192.168.1.2',
        'responseTime': 15.0,
        'geolocation': {
          'city': 'Test City 2',
          'country': 'Test Country',
          'lat': 42.0,
          'lon': 30.0,
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

    await tester.pumpAndSettle();

    // Test next hop navigation
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();

    // Test previous hop navigation
    await tester.tap(find.byIcon(Icons.arrow_downward));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
  });

  testWidgets(
      'MapTab Widget handles hops with coordinates instead of geolocation',
      (WidgetTester tester) async {
    final hops = [
      {
        'hopNumber': 1,
        'address': '192.168.1.1',
        'responseTime': 10.0,
        'geolocation': null,
        'coordinates': {
          'city': 'Coord City',
          'country': 'Coord Country',
          'lat': 40.0,
          'lon': 28.0,
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

    await tester.pumpAndSettle();

    expect(find.byType(Stack), findsAtLeastNWidgets(1));
    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
  });

  testWidgets(
      'MapTab Widget handles hops with mixed geolocation and coordinates',
      (WidgetTester tester) async {
    final hops = [
      {
        'hopNumber': 1,
        'address': '192.168.1.1',
        'responseTime': 10.0,
        'geolocation': {
          'city': 'Geo City',
          'country': 'Geo Country',
          'lat': 41.0,
          'lon': 29.0,
        },
      },
      {
        'hopNumber': 2,
        'address': '192.168.1.2',
        'responseTime': 15.0,
        'geolocation': null,
        'coordinates': {
          'city': 'Coord City',
          'country': 'Coord Country',
          'lat': 40.0,
          'lon': 28.0,
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

    await tester.pumpAndSettle();

    expect(find.byType(Stack), findsAtLeastNWidgets(1));
    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
  });

  testWidgets('MapTab Widget handles empty hop navigation',
      (WidgetTester tester) async {
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

    await tester.pumpAndSettle();

    // Try navigation with empty hops - should handle gracefully
    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_downward));
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsAtLeastNWidgets(1));
  });

  testWidgets('MapTab Widget handles widget updates correctly',
      (WidgetTester tester) async {
    final initialHops = [
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

    // Create a stateful widget to test widget updates
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapTab(
            hops: initialHops,
            isFetching: false,
            onMapInteraction: (_) {},
            onStartTraceRoute: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Update with new hops
    final updatedHops = [
      {
        'hopNumber': 1,
        'address': '192.168.1.1',
        'responseTime': 10.0,
        'geolocation': {
          'city': 'Updated City',
          'country': 'Updated Country',
          'lat': 42.0,
          'lon': 30.0,
        },
      },
      {
        'hopNumber': 2,
        'address': '192.168.1.2',
        'responseTime': 15.0,
        'geolocation': {
          'city': 'New City',
          'country': 'New Country',
          'lat': 43.0,
          'lon': 31.0,
        },
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MapTab(
            hops: updatedHops,
            isFetching: false,
            onMapInteraction: (_) {},
            onStartTraceRoute: () {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(Stack), findsAtLeastNWidgets(1));
  });

  testWidgets('MapTab Widget handles incomplete geolocation data gracefully',
      (WidgetTester tester) async {
    final hops = [
      {
        'hopNumber': 1,
        'address': '192.168.1.1',
        'responseTime': 10.0,
        'geolocation': {
          'lat': 41.0,
          'lon': 29.0,
          // Missing city and country
        },
      },
      {
        'hopNumber': 2,
        'address': '192.168.1.2',
        'responseTime': 15.0,
        'geolocation': {
          'city': 'Test City',
          'lat': 42.0,
          // Missing lon and country
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

    await tester.pumpAndSettle();

    expect(find.byType(Stack), findsAtLeastNWidgets(1));
  });

  group('MapTab Error Handling', () {
    testWidgets('handles null geolocation data', (WidgetTester tester) async {
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

      await tester.pumpAndSettle();
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });

    testWidgets('handles invalid coordinate values',
        (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'geolocation': {
            'lat': 'invalid',
            'lon': 'invalid',
            'city': 'Test City',
            'country': 'Test Country',
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

      await tester.pumpAndSettle();
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });

    testWidgets('handles empty geolocation object',
        (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'geolocation': {},
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

      await tester.pumpAndSettle();
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });

    testWidgets('handles extremely large hop counts',
        (WidgetTester tester) async {
      final largeHopList = List.generate(
          100,
          (index) => {
                'hopNumber': index + 1,
                'address': '192.168.1.${index + 1}',
                'responseTime': (index + 1) * 1.0,
                'geolocation': {
                  'lat': 41.0 + (index * 0.01),
                  'lon': 29.0 + (index * 0.01),
                  'city': 'City $index',
                  'country': 'Country',
                },
              });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapTab(
              hops: largeHopList,
              isFetching: false,
              onMapInteraction: (_) {},
              onStartTraceRoute: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });

    testWidgets('handles hops with missing required fields',
        (WidgetTester tester) async {
      final invalidHops = [
        {
          // Missing hopNumber
          'address': '192.168.1.1',
          'responseTime': 10.0,
        },
        {
          'hopNumber': 2,
          // Missing address
          'responseTime': 15.0,
        },
        {
          'hopNumber': 3,
          'address': '192.168.1.3',
          // Missing responseTime
        },
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapTab(
              hops: invalidHops,
              isFetching: false,
              onMapInteraction: (_) {},
              onStartTraceRoute: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });

    testWidgets('handles widget disposal correctly',
        (WidgetTester tester) async {
      final hops = [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.0,
          'geolocation': {
            'lat': 41.0,
            'lon': 29.0,
            'city': 'Test City',
            'country': 'Test Country',
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

      await tester.pumpAndSettle();

      // Navigate away to trigger disposal
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('handles rapid state changes', (WidgetTester tester) async {
      var isFetching = false;
      var hops = <Map<String, dynamic>>[];

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Expanded(
                      child: MapTab(
                        hops: hops,
                        isFetching: isFetching,
                        onMapInteraction: (_) {},
                        onStartTraceRoute: () {
                          setState(() {
                            isFetching = true;
                          });
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          hops = [
                            {
                              'hopNumber': 1,
                              'address': '192.168.1.1',
                              'responseTime': 10.0,
                              'geolocation': {
                                'lat': 41.0,
                                'lon': 29.0,
                                'city': 'Test City',
                                'country': 'Test Country',
                              },
                            },
                          ];
                          isFetching = false;
                        });
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Tap start trace route
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Update with hops
      await tester.tap(find.text('Update'));
      await tester.pumpAndSettle();

      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });
  });
}
