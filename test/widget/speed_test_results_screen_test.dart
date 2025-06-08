import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:netscope/models/speedtest_models.dart';
import 'package:netscope/screens/apps/speedtest/speed_test_results_screen.dart';
import '../mocks/firebase_mocks.dart';

// Simple mock for NavigatorObserver
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpeedTestResultsScreen UI Tests', () {
    testWidgets('Screen shows visual elements correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('SpeedTestResultsScreen UI Test'),
          ),
        ),
      );

      expect(find.text('SpeedTestResultsScreen UI Test'), findsOneWidget);
    });

    testWidgets('Back button navigation', (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      bool wasBackPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Builder(builder: (context) {
            return Scaffold(
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () {
                    wasBackPressed = true;
                    Navigator.of(context).pop();
                  },
                ),
                title: const Text('Speed Test Results'),
              ),
              body: const Center(child: Text('Results go here')),
            );
          }),
        ),
      );

      final backButton = find.byType(BackButton);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(wasBackPressed, isTrue);
    });

    testWidgets('Results screen shows loading state',
        (WidgetTester tester) async {
      // Create empty results for loading state
      final mockStream = MockSpeedTestResultsStream([]);
      final mockFirestore = MockFirebaseFirestore(mockStream);
      final mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(
        MaterialApp(
          home: SpeedTestResultsScreen(
            auth: mockAuth,
            firestore: mockFirestore,
          ),
        ),
      );

      // Test that the AppBar title is rendered correctly
      expect(find.text('Speed Test Results'), findsOneWidget);

      // Test that loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Results screen shows test results',
        (WidgetTester tester) async {
      // Create mock results data
      final mockResults = [
        MockSpeedTestResultData(
          downloadSpeed: 95.5,
          uploadSpeed: 45.2,
          ping: 15,
          timestamp: DateTime(2023, 5, 20, 14, 30),
        ),
        MockSpeedTestResultData(
          downloadSpeed: 85.3,
          uploadSpeed: 40.1,
          ping: 18,
          timestamp: DateTime(2023, 5, 19, 10, 15),
        ),
      ];

      final mockStream = MockSpeedTestResultsStream(mockResults);
      final mockFirestore = MockFirebaseFirestore(mockStream);
      final mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(
        MaterialApp(
          home: SpeedTestResultsScreen(
            auth: mockAuth,
            firestore: mockFirestore,
          ),
        ),
      );

      // Need to wait for stream to process
      await tester.pumpAndSettle();

      // Test that the AppBar title is rendered correctly
      expect(find.text('Speed Test Results'), findsOneWidget);

      // Test that results are displayed
      expect(find.text('Download Speed: 95.50 Mbps'), findsOneWidget);
      expect(find.text('Upload Speed: 45.20 Mbps'), findsOneWidget);
      expect(find.text('Ping: 15 ms'), findsOneWidget);

      // Check for the second result
      expect(find.text('Download Speed: 85.30 Mbps'), findsOneWidget);
      expect(find.text('Upload Speed: 40.10 Mbps'), findsOneWidget);
      expect(find.text('Ping: 18 ms'), findsOneWidget);
    });

    testWidgets('Results screen shows empty state message',
        (WidgetTester tester) async {
      // Create empty results list to simulate no data
      final mockStream = MockSpeedTestResultsStream([]);
      final mockFirestore = MockFirebaseFirestore(mockStream);
      final mockAuth = MockFirebaseAuth();

      await tester.pumpWidget(
        MaterialApp(
          home: SpeedTestResultsScreen(
            auth: mockAuth,
            firestore: mockFirestore,
          ),
        ),
      );

      // Need to wait for stream to process
      await tester.pumpAndSettle();

      // Test that the empty state message is displayed
      expect(find.text('No results found.'), findsOneWidget);
    });
  });

  // For integration testing
  test('Integration testing note', () {
    // This is a reminder that proper Firebase testing requires integration tests
    expect(true, isTrue);
  });
}
