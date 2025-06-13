import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:netscope/screens/apps/traceroute/map/map_screen.dart';
import 'package:netscope/screens/apps/traceroute/map/hops_tab.dart';
import 'package:netscope/screens/apps/traceroute/map/details_tab.dart';
import 'package:netscope/screens/apps/traceroute/map/map_tab.dart';
import 'package:netscope/screens/apps/traceroute/map/services/trace_route_service.dart';

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  User? get currentUser => MockUser();
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  Map<String, dynamic> get data => {
        'hops': [
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
        ],
        'timestamp': Timestamp.now(),
      };
}

class MockTraceRouteService extends Mock implements TraceRouteService {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockDocumentSnapshot mockDocumentSnapshot;
  late MockTraceRouteService mockTraceRouteService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockTraceRouteService = MockTraceRouteService();

    // Set up mock responses
    when(mockFirestore.collection('traceroutes')).thenReturn(mockCollection);
    when(mockCollection.doc('test-uid')).thenReturn(mockCollection);
    when(mockCollection.collection('results')).thenReturn(mockCollection);
    when(mockCollection.orderBy('timestamp', descending: true)).thenReturn(mockCollection);
    when(mockCollection.limit(1)).thenReturn(mockCollection);
    when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn([mockDocumentSnapshot]);
  });

  testWidgets('renders basic UI elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(),
      ),
    );

    expect(find.byType(MapScreen), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });

  testWidgets('shows loading indicator during trace', (WidgetTester tester) async {
    when(mockTraceRouteService.trace()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(),
      ),
    );

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays historical trace data', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Hop 1'), findsOneWidget);
    expect(find.text('IP: 192.168.1.1'), findsOneWidget);
    expect(find.text('10.0 ms'), findsOneWidget);
  });

  testWidgets('handles trace errors', (WidgetTester tester) async {
    when(mockTraceRouteService.trace()).thenThrow(Exception('Trace failed'));

    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(),
      ),
    );

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pumpAndSettle();

    expect(find.text('Error: Trace failed'), findsOneWidget);
  });

  testWidgets('navigates between tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MapScreen(),
      ),
    );

    await tester.tap(find.byIcon(Icons.list));
    await tester.pumpAndSettle();

    expect(find.byType(HopsTab), findsOneWidget);

    await tester.tap(find.byIcon(Icons.map));
    await tester.pumpAndSettle();

    expect(find.byType(MapTab), findsOneWidget);
  });
}
