// filepath: d:\netscope\test\unit\speedtest_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/models/speedtest_models.dart';

void main() {
  group('SpeedTest Models', () {
    group('SpeedTestResult', () {
      test('should create with required values', () {
        final result = SpeedTestResult(
          downloadSpeed: 50.5,
          uploadSpeed: 25.3,
          ping: 15,
        );

        expect(result.downloadSpeed, 50.5);
        expect(result.uploadSpeed, 25.3);
        expect(result.ping, 15);
      });
    });

    group('TestProgress', () {
      test('should create with required values', () {
        final progress = TestProgress(
          status: 'Testing download speed',
          progress: 0.75,
          currentSpeed: 45.2,
        );

        expect(progress.status, 'Testing download speed');
        expect(progress.progress, 0.75);
        expect(progress.currentSpeed, 45.2);
      });

      test('should handle progress values', () {
        // This test assumes progress values should be between 0 and 1
        // for proper display, but the model doesn't enforce limits
        final progress1 = TestProgress(
          status: 'Testing',
          progress: -0.5,
          currentSpeed: 10,
        );

        final progress2 = TestProgress(
          status: 'Testing',
          progress: 1.5,
          currentSpeed: 10,
        );

        expect(progress1.progress, -0.5);
        expect(progress2.progress, 1.5);
      });
    });
  });
}
