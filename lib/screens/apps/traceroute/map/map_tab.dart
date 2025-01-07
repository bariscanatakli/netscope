import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Add this line for localization

class MapTab extends StatefulWidget {
  final Function(bool isInteracting) onMapInteraction;
  final Function() onStartTraceRoute;
  final bool isFetching;
  final List<Map<String, dynamic>> hops;

  const MapTab({
    super.key,
    required this.onMapInteraction,
    required this.onStartTraceRoute,
    required this.isFetching,
    required this.hops,
  });

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  late GoogleMapController _mapController;
  bool _isInteracting = false;
  final TextEditingController _ipController = TextEditingController();
  final Set<Marker> _markers = {};

  // Channel to communicate with native code
  static const platform = MethodChannel('com.example.traceroute/traceroute');

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.7749, -122.4194), // Default location (San Francisco)
    zoom: 10,
  );

  String _tracerouteOutput = ''; // Store traceroute result

  @override
  void didUpdateWidget(MapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hops != oldWidget.hops) {
      _updateMarkers();
    }
  }

  void _updateMarkers() {
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      _markers.clear();
      for (var hop in widget.hops) {
        if (hop['geolocation']['lat'] != null &&
            hop['geolocation']['lon'] != null) {
          _markers.add(
            Marker(
              markerId: MarkerId(hop['address']),
              position:
                  LatLng(hop['geolocation']['lat'], hop['geolocation']['lon']),
              infoWindow: InfoWindow(
                title: 'Hop ${hop['hopNumber']}',
                snippet:
                    '${hop['geolocation']['city']}, ${hop['geolocation']['country']}',
              ),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
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
            bottom: 16,
            left: 16,
            child: FloatingActionButton(
              onPressed: widget.onStartTraceRoute,
              child: const Icon(Icons.play_arrow),
              tooltip: Intl.message('Start Trace Route'), // Localize this line
            ),
          ),
          if (widget.isFetching)
            Positioned(
              bottom: 80,
              left: 16,
              child: CircularProgressIndicator(),
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
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        _tracerouteOutput = result;
      });
    } on PlatformException catch (e) {
      if (!mounted) return; // Check if the widget is still mounted
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
