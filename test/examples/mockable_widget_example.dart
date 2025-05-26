// This is an example file showing how you could use the Firebase mocks
// with your actual widgets. You can adapt this pattern for your tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mocks/firebase_mocks.dart';

// Mock version of a widget that would normally use Firebase
class MockableSpeedTestResultsScreen extends StatelessWidget {
  // Accept mock objects that can be injected during tests
  final dynamic firebaseAuth;
  final dynamic firestore;

  const MockableSpeedTestResultsScreen({
    Key? key,
    required this.firebaseAuth,
    required this.firestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the current user from the injected auth
    final user = firebaseAuth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view your results.'),
        ),
      );
    }

    // Use the injected firestore
    return Scaffold(
      appBar: AppBar(title: const Text('Speed Test Results')),
      body: FutureBuilder(
        // Use the injected firestore to get data
        future: firestore
            .collection('speed_tests')
            .doc(user.uid)
            .collection('results')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          final docs = data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('No speed test results found.'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final resultData = doc.data();

              return ListTile(
                title: Text('Download: ${resultData['downloadSpeed']} Mbps'),
                subtitle: Text(
                    'Upload: ${resultData['uploadSpeed']} Mbps | Ping: ${resultData['ping']} ms'),
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  group('Mockable Widget Example', () {
    testWidgets('should show sign in message when not authenticated',
        (tester) async {
      // Get mock with no signed in user
      final mockAuth = getMockAuth(signedIn: false);
      final mockFirestore = getMockFirestore();

      await tester.pumpWidget(
        MaterialApp(
          home: MockableSpeedTestResultsScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
          ),
        ),
      );

      // Verify the sign in message is shown
      expect(find.text('Please sign in to view your results.'), findsOneWidget);
    });

    testWidgets('should show results when authenticated', (tester) async {
      // Get mock with signed in user and sample data
      final mockAuth = getMockAuth(signedIn: true);
      final mockFirestore = getMockFirestore(withSampleData: true);

      await tester.pumpWidget(
        MaterialApp(
          home: MockableSpeedTestResultsScreen(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
          ),
        ),
      );

      // Pump the future builder
      await tester.pump();

      // Verify results are shown
      expect(find.text('Download: 75.2 Mbps'), findsOneWidget);
    });
  });
}
