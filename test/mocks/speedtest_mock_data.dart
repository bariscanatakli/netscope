import 'package:netscope/models/speedtest_models.dart';

// Helper class for creating test data for SpeedTest module
class SpeedTestMockData {
  // Create a sample SpeedTestResult
  static SpeedTestResult createSampleResult({
    double downloadSpeed = 50.5,
    double uploadSpeed = 25.3,
    int ping = 15,
  }) {
    return SpeedTestResult(
      downloadSpeed: downloadSpeed,
      uploadSpeed: uploadSpeed,
      ping: ping,
    );
  }

  // Create a sample TestProgress update
  static TestProgress createSampleProgress({
    String status = 'Testing download speed',
    double progress = 0.75,
    double currentSpeed = 45.2,
  }) {
    return TestProgress(
      status: status,
      progress: progress,
      currentSpeed: currentSpeed,
    );
  }

  // Create multiple sample test results for history display
  static List<Map<String, dynamic>> createSampleHistoryData() {
    return [
      {
        'downloadSpeed': 75.2,
        'uploadSpeed': 22.5,
        'ping': 12,
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      },
      {
        'downloadSpeed': 65.8,
        'uploadSpeed': 20.3,
        'ping': 15,
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
      },
      {
        'downloadSpeed': 82.1,
        'uploadSpeed': 25.7,
        'ping': 10,
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
      },
    ];
  }
}
