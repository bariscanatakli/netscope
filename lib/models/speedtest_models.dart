class TestProgress {
  final String status;
  final double progress;
  final double currentSpeed;

  TestProgress({
    required this.status,
    required this.progress,
    required this.currentSpeed,
  });
}

class SpeedTestResult {
  final double downloadSpeed;
  final double uploadSpeed;
  final int ping;

  SpeedTestResult({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.ping,
  });
}

// Add this class for mocking results in tests
class MockSpeedTestResultData {
  final double downloadSpeed;
  final double uploadSpeed;
  final int ping;
  final DateTime timestamp;

  MockSpeedTestResultData({
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.ping,
    required this.timestamp,
  });

  // Convert to map (similar to Firestore document)
  Map<String, dynamic> toMap() {
    return {
      'downloadSpeed': downloadSpeed,
      'uploadSpeed': uploadSpeed,
      'ping': ping,
      'timestamp': timestamp,
    };
  }
}
