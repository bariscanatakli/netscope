import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:math';
import '../../../../models/speedtest_models.dart';

class ImprovedSpeedTest {
  static const int testDuration = 10;
  static const int chunkSize = 1024 * 1024;

  final SpeedTestServer _server = SpeedTestServer(
    name: 'Cloudflare Speed',
    host: 'speed.cloudflare.com',
    location: 'Global CDN',
    distance: 0,
  );

  Future<SpeedTestResult> runTest(
    void Function(TestProgress) onProgress,
  ) async {
    final client = http.Client();

    try {
      onProgress(TestProgress(
        status: 'Initializing connection...',
        progress: 0.05,
        currentSpeed: 0,
      ));

      await _warmUpConnection(client);

      onProgress(TestProgress(
        status: 'Measuring latency...',
        progress: 0.1,
        currentSpeed: 0,
      ));

      final ping = await _optimizedPing(client);

      final downloadSpeed = await _testDownload(
        client,
        (progress, speed) {
          onProgress(TestProgress(
            status: 'Testing download...',
            progress: 0.1 + progress * 0.45,
            currentSpeed: speed,
          ));
        },
      );

      final uploadSpeed = await _testUpload(
        client,
        (progress, speed) {
          onProgress(TestProgress(
            status: 'Testing upload...',
            progress: 0.55 + progress * 0.45,
            currentSpeed: speed,
          ));
        },
      );

      return SpeedTestResult(
        downloadSpeed: downloadSpeed,
        uploadSpeed: uploadSpeed,
        ping: ping,
      );
    } catch (e) {
      print('Test failed: $e');
      throw Exception('Speed test failed: $e');
    } finally {
      client.close();
    }
  }

  Future<void> _warmUpConnection(http.Client client) async {
    try {
      await client
          .get(Uri.https(_server.host, 'cdn-cgi/trace'))
          .timeout(const Duration(milliseconds: 1000));
    } catch (e) {
      print('Warm up connection error: $e');
    }
  }

  Future<int> _optimizedPing(http.Client client) async {
    final samples = <int>[];
    const attempts = 5;

    for (var i = 0; i < attempts; i++) {
      final stopwatch = Stopwatch()..start();
      try {
        await client
            .get(Uri.https(_server.host, 'cdn-cgi/trace'))
            .timeout(const Duration(milliseconds: 1000));
        final ping = stopwatch.elapsedMilliseconds;
        if (ping > 0) {
          samples.add(ping);
          print('Ping sample $i: ${ping}ms');
        }
      } catch (e) {
        print('Ping attempt $i failed: $e');
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    if (samples.isEmpty) return 999;
    samples.sort();

    final validSamples = samples.take(3).toList();
    final medianPing =
        (validSamples.reduce((a, b) => a + b) / validSamples.length).round();
    print('Final ping: ${medianPing}ms');
    return medianPing;
  }

  Future<double> _testDownload(
    http.Client client,
    void Function(double progress, double speed) onProgress,
  ) async {
    final speeds = <double>[];
    final endTime = DateTime.now().add(Duration(seconds: testDuration));
    var chunks = 0;

    while (DateTime.now().isBefore(endTime)) {
      try {
        final stopwatch = Stopwatch()..start();

        final response = await client.get(
          Uri.https(_server.host, '__down', {
            'bytes': '26214400',
          }),
          headers: {
            'Cache-Control': 'no-cache',
            'pragma': 'no-cache',
          },
        ).timeout(const Duration(seconds: 20)); // Increased timeout duration

        if (response.statusCode == 200) {
          final bytesReceived = response.bodyBytes.length;
          final duration = stopwatch.elapsed.inMilliseconds / 1000;
          final speedMbps = (bytesReceived * 8) / (duration * 1000000);

          print('Download chunk $chunks: $speedMbps Mbps');

          if (speedMbps > 0) {
            speeds.add(speedMbps);
            chunks++;
            onProgress(chunks / testDuration, speedMbps);
          }
        } else {
          print('Download response status: ${response.statusCode}');
        }
      } catch (e) {
        print('Download chunk error: $e');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (speeds.isEmpty) {
      print('No valid download speeds recorded');
      return 0;
    }

    speeds.sort();
    print('All recorded speeds: $speeds');

    final validSpeeds = speeds.length >= 4
        ? speeds.sublist(speeds.length ~/ 4, (speeds.length * 3) ~/ 4)
        : speeds;

    print('Valid speeds for averaging: $validSpeeds');

    if (validSpeeds.isNotEmpty) {
      final avgSpeed = validSpeeds.reduce((a, b) => a + b) / validSpeeds.length;
      print('Average download speed: $avgSpeed Mbps');
      return avgSpeed;
    } else {
      print('No valid download speeds recorded');
      return 0;
    }
  }

  Future<double> _testUpload(
    http.Client client,
    void Function(double progress, double speed) onProgress,
  ) async {
    final speeds = <double>[];
    final testData = List.generate(chunkSize, (i) => Random().nextInt(256));
    final endTime = DateTime.now().add(Duration(seconds: testDuration));
    var chunks = 0;

    while (DateTime.now().isBefore(endTime)) {
      try {
        final stopwatch = Stopwatch()..start();

        final response = await client.post(
          Uri.https(_server.host, '__up'),
          body: testData,
          headers: {
            'Content-Type': 'application/octet-stream',
            'Cache-Control': 'no-cache',
          },
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final duration = stopwatch.elapsed.inMilliseconds / 1000;
          final speedMbps = (testData.length * 8) / (duration * 1000000);

          print('Upload chunk $chunks: $speedMbps Mbps');

          if (speedMbps > 0) {
            speeds.add(speedMbps);
            chunks++;
            onProgress(chunks / testDuration, speedMbps);
          }
        }
      } catch (e) {
        print('Upload chunk error: $e');
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    if (speeds.isEmpty) {
      print('No valid upload speeds recorded');
      return 0;
    }

    speeds.sort();
    final validSpeeds = speeds.sublist(
      speeds.length ~/ 4,
      (speeds.length * 3) ~/ 4,
    );

    final avgSpeed = validSpeeds.reduce((a, b) => a + b) / validSpeeds.length;
    print('Average upload speed: $avgSpeed Mbps');
    return avgSpeed;
  }
}

class SpeedTestServer {
  final String name;
  final String host;
  final String location;
  final double distance;

  SpeedTestServer({
    required this.name,
    required this.host,
    required this.location,
    required this.distance,
  });
}
