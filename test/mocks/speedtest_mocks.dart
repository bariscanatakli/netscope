import 'package:mockito/mockito.dart';
import 'package:netscope/models/speedtest_models.dart';
import 'package:netscope/screens/apps/speedtest/services/speedtest_service.dart';
import 'package:http/http.dart' as http;

// Mock for HTTP client
class MockHttpClient extends Mock implements http.Client {}

// Mock for the ImprovedSpeedTest service
class MockImprovedSpeedTest extends Mock implements ImprovedSpeedTest {
  @override
  Future<SpeedTestResult> runTest(
      void Function(TestProgress) onProgress) async {
    // Simulate progress updates
    onProgress(TestProgress(
      status: 'Testing download speed',
      progress: 0.25,
      currentSpeed: 25.0,
    ));

    await Future.delayed(const Duration(milliseconds: 100));

    onProgress(TestProgress(
      status: 'Testing upload speed',
      progress: 0.75,
      currentSpeed: 10.0,
    ));

    await Future.delayed(const Duration(milliseconds: 100));

    // Return a simulated result
    return SpeedTestResult(
      downloadSpeed: 50.0,
      uploadSpeed: 25.0,
      ping: 15,
    );
  }
}

// Sample helper method to create a ready-to-use mock speed test
MockImprovedSpeedTest createMockSpeedTest() {
  final mock = MockImprovedSpeedTest();

  // Setup any additional when/then logic here if needed

  return mock;
}

// This file serves as a central place for all speed test mocks
// Add more mock classes or methods as needed for comprehensive testing
