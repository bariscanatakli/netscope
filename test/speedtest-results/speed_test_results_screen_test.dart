import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/models/speedtest_models.dart';
import 'package:netscope/screens/apps/speedtest/speed_test_results_screen.dart';
import '../mocks/firebase_mocks.dart';

void main() {
  group('Speed Test Results Screen Tests', () {
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

      expect(find.text('Speed Test Results'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // More tests would go here
  });
}
