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
