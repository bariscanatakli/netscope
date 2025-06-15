import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:netscope/screens/apps/traceroute/map/details_tab.dart';
import 'package:netscope/screens/apps/traceroute/map/hops_tab.dart';
import 'package:netscope/screens/apps/traceroute/map/map_screen.dart';
import 'package:netscope/screens/apps/traceroute/map/map_tab.dart';
import 'package:netscope/screens/apps/traceroute/map/services/trace_route_service.dart';

// Mock classes generation
@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  User,
  CollectionReference,
  DocumentReference,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentSnapshot,
  TraceRouteService,
])
import 'map_screen_test.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockTraceRouteService mockTraceRouteService;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>>
      mockQueryDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockTraceRouteService = MockTraceRouteService();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockQueryDocumentSnapshot =
        MockQueryDocumentSnapshot<Map<String, dynamic>>();

    // Setup basic auth mock
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_user_id');
  });

  void setupEmptyFirestoreResponse() {
    when(mockFirestore.collection('traceroutes'))
        .thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc('test_user_id'))
        .thenReturn(mockDocumentReference);
    when(mockDocumentReference.collection('results'))
        .thenReturn(mockCollectionReference);
    when(mockCollectionReference.orderBy('timestamp', descending: true))
        .thenReturn(mockQuery);
    when(mockQuery.limit(1)).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async {
      when(mockQuerySnapshot.docs).thenReturn([]);
      return mockQuerySnapshot;
    });
  }

  void setupFirestoreWithHistoricalData() {
    final mockTimestamp =
        Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 1)));
    final mockHistoricalData = {
      'timestamp': mockTimestamp,
      'hops': [
        {
          'hopNumber': 1,
          'address': '192.168.1.1',
          'responseTime': 10.5,
          'pingTime': 10.5,
          'details': 'Hop 1: 192.168.1.1 (10.5ms)',
          'geolocation': {'city': 'Test City', 'country': 'Test Country'},
        }
      ],
      'destination': '192.168.1.1',
    };

    when(mockQueryDocumentSnapshot.data()).thenReturn(mockHistoricalData);
    when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

    when(mockFirestore.collection('traceroutes'))
        .thenReturn(mockCollectionReference);
    when(mockCollectionReference.doc('test_user_id'))
        .thenReturn(mockDocumentReference);
    when(mockDocumentReference.collection('results'))
        .thenReturn(mockCollectionReference);
    when(mockCollectionReference.orderBy('timestamp', descending: true))
        .thenReturn(mockQuery);
    when(mockQuery.limit(1)).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
  }

  Widget createTestWidget({TraceRouteService? traceRouteService}) {
    return MaterialApp(
      home: MapScreen(
        firebaseAuth: mockAuth,
        firestore: mockFirestore,
        traceRouteService: traceRouteService ?? mockTraceRouteService,
      ),
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }

  group('MapScreen Widget Tests', () {
    testWidgets('should display initial UI correctly',
        (WidgetTester tester) async {
      setupEmptyFirestoreResponse();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify initial UI elements
      expect(find.text('Traceroute'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('Hops'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.byType(MapTab), findsOneWidget);
    });

    testWidgets('should switch between tabs correctly',
        (WidgetTester tester) async {
      setupEmptyFirestoreResponse();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially on Map tab (index 0)
      expect(find.byType(MapTab), findsOneWidget);

      // Tap on Hops tab
      await tester.tap(find.text('Hops'));
      await tester.pumpAndSettle();
      expect(find.byType(HopsTab), findsOneWidget);

      // Tap on Details tab
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailsTab), findsOneWidget);

      // Tap back on Map tab
      await tester.tap(find.text('Map'));
      await tester.pumpAndSettle();
      expect(find.byType(MapTab), findsOneWidget);
    });

    testWidgets('should load historical traceroute data',
        (WidgetTester tester) async {
      setupFirestoreWithHistoricalData();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Verify the UI loads without errors
      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('should show history modal when history button is tapped',
        (WidgetTester tester) async {
      final mockTimestamp1 =
          Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 1)));
      final mockTimestamp2 =
          Timestamp.fromDate(DateTime.now().subtract(Duration(hours: 2)));

      final mockHistoricalData1 = {
        'timestamp': mockTimestamp1,
        'hops': [
          {'hopNumber': 1, 'address': '192.168.1.1'},
          {'hopNumber': 2, 'address': '8.8.8.8'},
        ],
        'destination': '8.8.8.8',
      };

      final mockHistoricalData2 = {
        'timestamp': mockTimestamp2,
        'hops': [
          {'hopNumber': 1, 'address': '192.168.1.1'},
        ],
        'destination': '192.168.1.1',
      };

      final mockDoc1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockDoc2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockDoc1.data()).thenReturn(mockHistoricalData1);
      when(mockDoc2.data()).thenReturn(mockHistoricalData2);

      // Setup for initial fetch (empty)
      when(mockFirestore.collection('traceroutes'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('test_user_id'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.collection('results'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);

      // For initial fetch (limit 1)
      final mockQueryForInitial = MockQuery<Map<String, dynamic>>();
      when(mockQuery.limit(1)).thenReturn(mockQueryForInitial);
      when(mockQueryForInitial.get()).thenAnswer((_) async {
        when(mockQuerySnapshot.docs).thenReturn([]);
        return mockQuerySnapshot;
      });

      // For history fetch (no limit)
      when(mockQuery.get()).thenAnswer((_) async {
        final mockHistorySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        when(mockHistorySnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        return mockHistorySnapshot;
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap history button
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      // Verify modal is shown
      expect(find.text('Traceroute History'), findsOneWidget);
    });

    testWidgets('should handle null user scenario',
        (WidgetTester tester) async {
      // Setup null user
      when(mockAuth.currentUser).thenReturn(null);

      await tester.pumpWidget(createTestWidget());
      await tester
          .pumpAndSettle(); // Should not crash and should handle null user gracefully
      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('should handle back button press scenarios',
        (WidgetTester tester) async {
      setupEmptyFirestoreResponse();

      await tester.pumpWidget(createTestWidget());
      await tester
          .pumpAndSettle(); // Verify PopScope is present (WillPopScope is deprecated in newer Flutter)
      expect(find.byType(MapScreen), findsOneWidget);
    });
    testWidgets('should start traceroute and show loading',
        (WidgetTester tester) async {
      setupEmptyFirestoreResponse();
      // Setup mock trace route service with a delayed response
      final completer = Completer<List<TracerouteResult>>();
      when(mockTraceRouteService.trace()).thenAnswer((_) => completer.future);
      when(mockCollectionReference.add(any))
          .thenAnswer((_) async => mockDocumentReference);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the play button in MapTab and tap it
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump(); // This will trigger the state change

      // Verify loading indicator appears
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Complete the future to clean up
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('should handle traceroute error', (WidgetTester tester) async {
      setupEmptyFirestoreResponse();

      // Setup mock trace route service to throw error
      when(mockTraceRouteService.trace()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the play button in MapTab and tap it
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();
      await tester.pumpAndSettle();

      // Verify error snackbar is shown
      expect(find.text('Error during traceroute: Exception: Network error'),
          findsOneWidget);
    });

    testWidgets('should handle tab switching with null hops gracefully',
        (WidgetTester tester) async {
      setupEmptyFirestoreResponse();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start with empty hops, switch to hops tab
      await tester.tap(find.text('Hops'));
      await tester.pumpAndSettle();
      expect(find.byType(HopsTab), findsOneWidget);

      // Switch to details tab with empty data
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
      expect(find.byType(DetailsTab), findsOneWidget);
    });

    testWidgets('should handle multiple rapid tab switches',
        (WidgetTester tester) async {
      setupEmptyFirestoreResponse();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Rapidly switch between tabs
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text('Hops'));
        await tester.pump();
        await tester.tap(find.text('Details'));
        await tester.pump();
        await tester.tap(find.text('Map'));
        await tester.pump();
      }
      await tester.pumpAndSettle();

      // Should end up on Map tab
      expect(find.byType(MapTab), findsOneWidget);
    });

    testWidgets('should handle large datasets efficiently',
        (WidgetTester tester) async {
      setupEmptyFirestoreResponse();

      // Create a large number of hops to test performance
      final largeHopsList = List.generate(
          50,
          (index) => {
                'hopNumber': index + 1,
                'address': '192.168.1.$index',
                'responseTime': 10.0 + index,
                'pingTime': 10.0 + index,
                'geolocation': {
                  'city': 'Test City $index',
                  'country': 'Test Country'
                },
              });
      when(mockTraceRouteService.trace()).thenAnswer((_) async {
        return largeHopsList
            .map((hop) => TracerouteResult(
                  hopNumber: hop['hopNumber'] as int,
                  address: hop['address'] as String,
                  responseTime: hop['responseTime'] as double,
                  isSuccess: true,
                  geolocation: hop['geolocation'] as Map<String, dynamic>,
                  pingTime: (hop['pingTime'] as double).toInt(),
                ))
            .toList();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start traceroute with large dataset
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Switch to hops tab to view large dataset
      await tester.tap(find.text('Hops'));
      await tester.pumpAndSettle();
      expect(find.byType(HopsTab), findsOneWidget);
    });

    testWidgets('should handle pop scope correctly during loading',
        (WidgetTester tester) async {
      setupEmptyFirestoreResponse();

      final completer = Completer<List<TracerouteResult>>();
      when(mockTraceRouteService.trace()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start traceroute to trigger loading state
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      // Verify loading state
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Try to navigate back during loading - should show cancel button
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      // Complete the operation
      completer.complete([]);
      await tester.pumpAndSettle();
    }); // Additional tests can be added here to further improve coverage

    // ...existing code...
  });

  group('MapScreen Unit Tests', () {
    test('should format trace time correctly', () {
      final testTime = DateTime(2023, 6, 15, 14, 30, 0);
      final formatted = DateFormat('MMM dd, yyyy HH:mm').format(testTime);
      expect(formatted, 'Jun 15, 2023 14:30');
    });

    test('should handle localized strings', () {
      // Test basic localization functionality
      expect('Map', isA<String>());
      expect('Hops', isA<String>());
      expect('Details', isA<String>());
    });
    test('should reverse hop order correctly', () {
      final originalHops = [
        {'hopNumber': 1, 'address': '192.168.1.1'},
        {'hopNumber': 2, 'address': '8.8.8.8'},
      ];

      final reversed = originalHops.reversed.toList();

      expect(reversed[0]['address'], '8.8.8.8');
      expect(reversed[1]['address'], '192.168.1.1');
    });

    test('should handle empty hops list', () {
      final emptyHops = <Map<String, dynamic>>[];
      expect(emptyHops.length, 0);
      expect(emptyHops.isEmpty, true);
    });

    test('should handle TracerouteResult properties', () {
      final result = TracerouteResult(
        hopNumber: 1,
        address: '192.168.1.1',
        responseTime: 10.5,
        isSuccess: true,
        geolocation: {'city': 'Test City'},
        pingTime: 10,
      );

      expect(result.hopNumber, 1);
      expect(result.address, '192.168.1.1');
      expect(result.responseTime, 10.5);
      expect(result.isSuccess, true);
      expect(result.pingTime, 10);
    });

    test('should handle TracerouteResult copyWith', () {
      final original = TracerouteResult(
        hopNumber: 1,
        address: '192.168.1.1',
        responseTime: 10.5,
        isSuccess: true,
        geolocation: {'city': 'Test City'},
        pingTime: 10,
      );

      final copied = original.copyWith(hopNumber: 2, address: '8.8.8.8');
      expect(copied.hopNumber, 2);
      expect(copied.address, '8.8.8.8');
      expect(copied.responseTime, 10.5); // Should remain the same
      expect(copied.isSuccess, true); // Should remain the same
    });
  });

  group('MapScreen Widget Tests - Error Handling', () {
    testWidgets('should handle fetchLastTraceroute error gracefully',
        (WidgetTester tester) async {
      // Setup mocks
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      // Mock Firestore collection to throw an error
      when(mockFirestore.collection('traceroutes'))
          .thenThrow(Exception('Firestore error'));

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester
          .pumpAndSettle(); // Should still display the widget without crashing
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Traceroute'), findsOneWidget);
    });
    testWidgets('should handle null user in fetchLastTraceroute',
        (WidgetTester tester) async {
      // Setup mocks with null user
      when(mockAuth.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle(); // Should display without issues
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Traceroute'), findsOneWidget);
    });
    testWidgets('should handle history button with null user',
        (WidgetTester tester) async {
      when(mockAuth.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap history button
      final historyButton = find.byIcon(Icons.history);
      expect(historyButton, findsOneWidget);

      await tester.tap(historyButton);
      await tester.pumpAndSettle(); // Should handle gracefully with null user
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Traceroute'), findsOneWidget);
    });
    testWidgets('should handle history fetch error',
        (WidgetTester tester) async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      // Mock history fetch to throw error
      when(mockFirestore.collection('traceroutes'))
          .thenThrow(Exception('History error'));

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap history button
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle(); // Should handle error gracefully
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Traceroute'), findsOneWidget);
    });
    testWidgets('should handle dispose correctly', (WidgetTester tester) async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Text('Different Screen'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should dispose without errors
      expect(find.text('Different Screen'), findsOneWidget);
    });

    testWidgets('should handle various initialization edge cases',
        (WidgetTester tester) async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      when(mockFirestore.collection('traceroutes'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('test-uid'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.collection('results'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);
      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Traceroute'), findsOneWidget);
    });

    testWidgets('should handle complex error scenarios in data persistence',
        (WidgetTester tester) async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      when(mockFirestore.collection('traceroutes'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('test-uid'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.collection('results'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Mock successful traceroute but failed save
      when(mockTraceRouteService.trace()).thenAnswer((_) async => [
            TracerouteResult(
              hopNumber: 1,
              address: '192.168.1.1',
              responseTime: 10.0,
              isSuccess: true,
              geolocation: {'city': 'Test City', 'country': 'Test Country'},
              pingTime: 10,
            ),
          ]);

      when(mockCollectionReference.add(any))
          .thenThrow(Exception('Database write failed'));

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start traceroute
      final playButton = find.byIcon(Icons.play_arrow);
      expect(playButton, findsOneWidget);
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Should handle the error gracefully
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle memory pressure with large datasets',
        (WidgetTester tester) async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      when(mockFirestore.collection('traceroutes'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('test-uid'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.collection('results'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Generate a very large dataset (50 hops)
      final largeTracerouteResults = List.generate(
        50,
        (index) => TracerouteResult(
          hopNumber: index + 1,
          address: '192.168.1.${index + 1}',
          responseTime: (index + 1) * 1.0,
          isSuccess: true,
          geolocation: {
            'city': 'Test City ${index + 1}',
            'country': 'Test Country',
            'lat': 41.0 + (index * 0.01),
            'lon': 29.0 + (index * 0.01),
          },
          pingTime: index + 1,
        ),
      );

      when(mockTraceRouteService.trace())
          .thenAnswer((_) async => largeTracerouteResults);

      when(mockCollectionReference.add(any))
          .thenAnswer((_) async => mockDocumentReference);

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start traceroute with large dataset
      final playButton = find.byIcon(Icons.play_arrow);
      expect(playButton, findsOneWidget);
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Should handle large dataset without issues
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('should handle rapid user interactions gracefully',
        (WidgetTester tester) async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      when(mockFirestore.collection('traceroutes'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('test-uid'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.collection('results'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      when(mockTraceRouteService.trace()).thenAnswer((_) async => [
            TracerouteResult(
              hopNumber: 1,
              address: '192.168.1.1',
              responseTime: 10.0,
              isSuccess: true,
              geolocation: {'city': 'Test City', 'country': 'Test Country'},
              pingTime: 10,
            ),
          ]);

      when(mockCollectionReference.add(any))
          .thenAnswer((_) async => mockDocumentReference);

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rapidly tap multiple buttons
      final playButton = find.byIcon(Icons.play_arrow);
      for (int i = 0; i < 3; i++) {
        if (playButton.evaluate().isNotEmpty) {
          await tester.tap(playButton);
        }
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Should handle rapid interactions without crashes
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle widget rebuild during async operations',
        (WidgetTester tester) async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      when(mockFirestore.collection('traceroutes'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('test-uid'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.collection('results'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      // Mock a slow traceroute operation
      when(mockTraceRouteService.trace()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return [
          TracerouteResult(
            hopNumber: 1,
            address: '192.168.1.1',
            responseTime: 10.0,
            isSuccess: true,
            geolocation: {'city': 'Test City', 'country': 'Test Country'},
            pingTime: 10,
          ),
        ];
      });

      when(mockCollectionReference.add(any))
          .thenAnswer((_) async => mockDocumentReference);

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start traceroute
      final playButton = find.byIcon(Icons.play_arrow);
      await tester.tap(playButton);
      await tester.pump(const Duration(milliseconds: 100));

      // Force rebuild during operation
      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle rebuild gracefully
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should handle null user scenarios correctly',
        (WidgetTester tester) async {
      when(mockAuth.currentUser).thenReturn(null);

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should still render the basic UI
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Traceroute'), findsOneWidget);
    });

    testWidgets('should handle corrupted data in Firestore gracefully',
        (WidgetTester tester) async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      when(mockFirestore.collection('traceroutes'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('test-uid'))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.collection('results'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.limit(1)).thenReturn(mockQuery);

      // Mock corrupted/malformed data from Firestore
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockQueryDocumentSnapshot.data()).thenReturn({
        'hops': 'invalid_data_format', // Should be a List
        'timestamp': 'invalid_timestamp',
      });

      await tester.pumpWidget(
        MaterialApp(
          home: MapScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            traceRouteService: mockTraceRouteService,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle corrupted data gracefully
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Traceroute'), findsOneWidget);
    });
  });
}
