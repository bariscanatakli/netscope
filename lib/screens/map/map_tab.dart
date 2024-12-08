import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';

class MapTab extends StatefulWidget {
  final Function(bool isInteracting) onMapInteraction;

  const MapTab({
    super.key,
    required this.onMapInteraction,
  });

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  late GoogleMapController _mapController;
  bool _isInteracting = false;
  final TextEditingController _ipController = TextEditingController();

  // Channel to communicate with native code
  static const platform = MethodChannel('com.example.traceroute/traceroute');

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default location (San Francisco)
    zoom: 10,
  );

  String _tracerouteOutput = ''; // Store traceroute result

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map with Traceroute')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onCameraMoveStarted: () {
              if (!_isInteracting) {
                setState(() {
                  _isInteracting = true;
                });
                widget.onMapInteraction(true);
              }
            },
            onCameraIdle: () {
              if (_isInteracting) {
                setState(() {
                  _isInteracting = false;
                });
                widget.onMapInteraction(false);
              }
            },
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
          ),
          Positioned(
            bottom: 100, // Adjusted to make space for input field and button
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _ipController,
                    decoration: InputDecoration(
                      labelText: 'Enter IP/Domain',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        TextInputType.text, // Ensure proper keyboard type
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _getTraceroute,
                  child: const Text('Start Traceroute'),
                ),
              ],
            ),
          ),
          // Optionally show traceroute output
          if (_tracerouteOutput.isNotEmpty)
            Positioned(
              bottom: 150,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.7),
                child: Text(
                  _tracerouteOutput,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Trigger the traceroute action
  Future<void> _getTraceroute() async {
    final ip = _ipController.text;
    if (ip.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an IP/domain")),
      );
      return;
    }

    try {
      final String result =
          await platform.invokeMethod('getTraceroute', {'ip': ip});
      setState(() {
        _tracerouteOutput = result;
      });
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get traceroute: ${e.message}")),
      );
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    _ipController.dispose();
    super.dispose();
  }
}
