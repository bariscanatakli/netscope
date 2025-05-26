// filepath: d:\netscope\test\examples\speedtest_mock_example_test_fixed.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/models/speedtest_models.dart';
import '../mocks/firebase_mocks.dart';
import '../setup.dart';

void main() {
  group('SpeedTest with Firebase Mocks', () {
    late MockFirebaseAuth mockAuth;
    late MockFirestore mockFirestore;
    late MockSpeedTestService mockSpeedTestService;

    setUp(() {
      // Setup fresh mocks for each test
      mockAuth = getMockAuth();
      mockFirestore = getMockFirestore(withSampleData: true);
      mockSpeedTestService = MockSpeedTestService();
    });

    test('User should be authenticated with mockAuth', () {
      // Verify the mock auth has a user
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser?.uid, 'test-user-id');
    });

    test('MockFirestore should have sample data', () async {
      // Access the mock Firestore
      final collection = mockFirestore.collection('speed_tests');
      final userDoc = collection.doc('test-user-id');
      final resultsCollection = userDoc.collection('results');

      // Get the results
      final querySnapshot = await resultsCollection.get();

      // Verify we have data
      expect(querySnapshot.empty, isFalse);
      expect(querySnapshot.docs.length, 2);

      // Verify data content
      expect(querySnapshot.docs[0].data()['downloadSpeed'], 75.2);
    });

    test('MockSpeedTestService should simulate a test', () async {
      // Track progress updates
      final progressUpdates = <TestProgress>[];

      // Run the mock test
      final result = await mockSpeedTestService.runTest((progress) {
        progressUpdates.add(progress);
      });

      // Verify progress was tracked
      expect(progressUpdates.length, 2);
      expect(progressUpdates[0].status, 'Testing download speed');
      expect(progressUpdates[1].status, 'Testing upload speed');

      // Verify result values
      expect(result.downloadSpeed, 50.0);
      expect(result.uploadSpeed, 25.0);
      expect(result.ping, 15);
    });
  });
}
