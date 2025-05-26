// filepath: d:\netscope\test\examples\network_mocking_example_test_fixed.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/models/speedtest_models.dart';
import '../setup.dart';

// This example shows how to mock network operations for SpeedTest

void main() {
  group('Network Info Mocking Example', () {
    test('Example of network info testing', () {
      // This is just a placeholder to show how you would test network info
      // In a real test, you would create instances of MockNetworkInfoService
      final mockNetworkInfo = MockNetworkInfoService();

      // The methods are now implemented directly in the mock class
      expect(mockNetworkInfo.getConnectionType(), completion(equals('WiFi')));
      expect(mockNetworkInfo.getWifiName(), completion(equals('Test_Network')));
    });
  });

  group('SpeedTest with Network Conditions', () {
    test('should test speed with mock service', () async {
      // Create the mock service
      final mockSpeedTest = MockSpeedTestService();

      // Track progress updates
      final progressUpdates = <TestProgress>[];

      // Act - run the test
      final result = await mockSpeedTest.runTest((progress) {
        progressUpdates.add(progress);
      });

      // Assert - verify results
      expect(result, isNotNull);
      expect(result.downloadSpeed, 50.0);
      expect(result.uploadSpeed, 25.0);
      expect(result.ping, 15);

      // Verify progress was tracked
      expect(progressUpdates.length, 2);
      expect(progressUpdates[0].status, 'Testing download speed');
      expect(progressUpdates[1].status, 'Testing upload speed');
    });

    test('should recognize slow network connections', () {
      // Example of creating slow network test result
      final slowResult = SpeedTestResult(
        downloadSpeed: 1.5,
        uploadSpeed: 0.5,
        ping: 200,
      );

      // Verify slow network metrics
      expect(slowResult.downloadSpeed, lessThan(5.0));
      expect(slowResult.uploadSpeed, lessThan(2.0));
      expect(slowResult.ping, greaterThan(100));
    });
  });
}
