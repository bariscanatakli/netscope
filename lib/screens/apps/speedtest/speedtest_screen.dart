import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/speedtest_service.dart';
import 'speed_test_results_screen.dart';

class SpeedTestScreen extends StatefulWidget {
  final ImprovedSpeedTest? speedTest; // Make this parameter optional

  const SpeedTestScreen({Key? key, this.speedTest}) : super(key: key);

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  late final ImprovedSpeedTest _speedTest;
  bool _isTesting = false;
  String _status = '';
  double _progress = 0;
  double _currentSpeed = 0;
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;
  int _ping = 0;

  @override
  void initState() {
    super.initState();
    _speedTest = widget.speedTest ??
        ImprovedSpeedTest(); // Use injected service or create new one
  }

  Future<void> _startTest() async {
    setState(() {
      _isTesting = true;
      _status = 'Starting test...';
      _progress = 0;
      _currentSpeed = 0;
      _downloadSpeed = 0;
      _uploadSpeed = 0;
      _ping = 0;
    });

    try {
      final result = await _speedTest.runTest((progress) {
        setState(() {
          _status = progress.status;
          _progress = progress.progress;
          _currentSpeed = progress.currentSpeed;
        });
      });

      setState(() {
        _downloadSpeed = result.downloadSpeed;
        _uploadSpeed = result.uploadSpeed;
        _ping = result.ping;
        _status = 'Test completed';
      });

      // Save results to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('speed_tests')
            .doc(user.uid)
            .collection('results')
            .add({
          'downloadSpeed': _downloadSpeed,
          'uploadSpeed': _uploadSpeed,
          'ping': _ping,
          'timestamp': Timestamp.now(),
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Test failed';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speed Test')),
      // Wrap with SingleChildScrollView to fix overflow
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 0,
                      maximum: 100,
                      ranges: <GaugeRange>[
                        GaugeRange(
                          startValue: 0,
                          endValue: _currentSpeed,
                          color: Colors.green,
                        ),
                      ],
                      pointers: <GaugePointer>[
                        NeedlePointer(value: _currentSpeed),
                      ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_currentSpeed.toStringAsFixed(2)} Mbps',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(_status),
                            ],
                          ),
                          angle: 90,
                          positionFactor: 0.5,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Ping: $_ping ms'),
                Text('Download: ${_downloadSpeed.toStringAsFixed(2)} Mbps'),
                Text('Upload: ${_uploadSpeed.toStringAsFixed(2)} Mbps'),
                const SizedBox(height: 20),
                if (_isTesting)
                  Column(
                    children: [
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 10),
                      Text(_status),
                    ],
                  )
                else
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _startTest,
                        child: const Text('Start Test'),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const SpeedTestResultsScreen()),
                          );
                        },
                        child: const Text('View Results'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
