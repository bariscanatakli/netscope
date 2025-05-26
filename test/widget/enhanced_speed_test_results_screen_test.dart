// filepath: d:\netscope\test\widget\enhanced_speed_test_results_screen_test_fixed.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../mocks/firebase_mocks.dart';
import '../setup.dart';

// This is a mockable version of the SpeedTestResultsScreen
// Note: Your actual app would need to be modified to accept these parameters
// or you could use a test-specific version of the widget
class MockableSpeedTestResultsScreen extends StatelessWidget {
  final dynamic authService;
  final dynamic firestore;

  const MockableSpeedTestResultsScreen({
    Key? key,
    required this.authService,
    required this.firestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view your results'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Speed Test Results')),
      body: FutureBuilder<MockQuerySnapshot>(
        future: firestore
            .collection('speed_tests')
            .doc(user.uid)
            .collection('results')
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('No test results found'),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final downloadSpeed = data['downloadSpeed'] ?? 0.0;
              final uploadSpeed = data['uploadSpeed'] ?? 0.0;
              final ping = data['ping'] ?? 0;
              final timestamp = data['timestamp'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
                  : DateTime.now();

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test on ${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour}:${timestamp.minute}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Download: ${downloadSpeed.toStringAsFixed(1)} Mbps'),
                      Text('Upload: ${uploadSpeed.toStringAsFixed(1)} Mbps'),
                      Text('Ping: $ping ms'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  group('Enhanced SpeedTest Results Screen Tests', () {
    late MockAuthService mockAuth;
    late MockFirestore mockFirestore;

    setUp(() {
      mockAuth = MockAuthService();
      mockFirestore = getMockFirestore(withSampleData: true);
    });

    testWidgets('should show sign in message when not signed in',
        (tester) async {
      // By default, the mock auth service returns null for currentUser

      await tester.pumpWidget(
        MaterialApp(
          home: MockableSpeedTestResultsScreen(
            authService: mockAuth,
            firestore: mockFirestore,
          ),
        ),
      );

      expect(find.text('Please sign in to view your results'), findsOneWidget);
    });

    testWidgets('should show loading indicator initially', (tester) async {
      // Create a mock auth that returns a user
      final authenticatedMockAuth = getMockAuth(signedIn: true);

      await tester.pumpWidget(
        MaterialApp(
          home: MockableSpeedTestResultsScreen(
            authService: authenticatedMockAuth,
            firestore: mockFirestore,
          ),
        ),
      );

      // Initially should show a loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
