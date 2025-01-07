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
  final Set<Marker> _visitedMarkers = {}; // Track visited markers
  int _currentHopIndex = 0; // Track the current hop index
  List<Map<String, dynamic>> _validHops =
      []; // List of hops with valid geolocation
  CameraPosition? _initialPosition;

  // Channel to communicate with native code
  static const platform = MethodChannel('com.example.traceroute/traceroute');

  String _tracerouteOutput = ''; // Store traceroute result

  @override
  void initState() {
    super.initState();
    _updateMarkers();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setInitialPosition();
    });
  }

  @override
  void didUpdateWidget(MapTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hops != oldWidget.hops) {
      _updateMarkers();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setInitialPosition();
      });
    }
  }

  void _setInitialPosition() {
    if (_validHops.isNotEmpty) {
      final firstHop = _validHops.first;
      final lat =
          firstHop['geolocation']['lat'] ?? firstHop['coordinates']['lat'];
      final lon =
          firstHop['geolocation']['lon'] ?? firstHop['coordinates']['lon'];
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(lat, lon),
          zoom: 10,
        );
      });
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(_initialPosition!),
      );
    }
  }

  void _updateMarkers() {
    if (!mounted) return; // Check if the widget is still mounted
    setState(() {
      _markers.clear();
      _validHops = widget.hops.where((hop) {
        return (hop['geolocation']['lat'] != null &&
                hop['geolocation']['lon'] != null) ||
            (hop['coordinates'] != null &&
                hop['coordinates']['lat'] != null &&
                hop['coordinates']['lon'] != null);
      }).toList();
      for (var hop in _validHops) {
        final lat = hop['geolocation']['lat'] ?? hop['coordinates']['lat'];
        final lon = hop['geolocation']['lon'] ?? hop['coordinates']['lon'];
        _markers.add(
          Marker(
            markerId: MarkerId(hop['address']),
            position: LatLng(lat, lon),
            infoWindow: InfoWindow(
              title: 'Hop ${hop['hopNumber']}',
              snippet:
                  '${hop['geolocation']['city'] ?? hop['coordinates']['city']}, ${hop['geolocation']['country'] ?? hop['coordinates']['country']}',
              onTap: () {
                _showHopDetails(hop);
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _visitedMarkers
                      .contains(Marker(markerId: MarkerId(hop['address'])))
                  ? BitmapDescriptor.hueGreen
                  : BitmapDescriptor.hueRed,
            ),
          ),
        );
      }
    });
  }

  void _navigateToHop(int index) {
    if (_validHops.isEmpty) return;

    // Ensure the index is within bounds
    index = index % _validHops.length;
    if (index < 0) {
      index += _validHops.length;
    }

    final hop = _validHops[index];
    final lat = hop['geolocation']['lat'] ?? hop['coordinates']['lat'];
    final lon = hop['geolocation']['lon'] ?? hop['coordinates']['lon'];
    print('Navigating to hop: $index, ${hop['address']}');
    _mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(lat, lon),
      ),
    );
    setState(() {
      _currentHopIndex = index;
      _visitedMarkers.add(Marker(markerId: MarkerId(hop['address'])));
      _updateMarkers();
    });
    _mapController.showMarkerInfoWindow(MarkerId(hop['address']));
  }

  void _showHopDetails(Map<String, dynamic> hop) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HopDetailsScreen(hop: hop),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition ??
                CameraPosition(
                  target: LatLng(
                      37.7749, -122.4194), // Default location (San Francisco)
                  zoom: 10,
                ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_initialPosition != null) {
                _mapController.animateCamera(
                  CameraUpdate.newCameraPosition(_initialPosition!),
                );
              }
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
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _navigateToHop(_currentHopIndex + 1);
                  },
                  child: const Icon(Icons.arrow_upward),
                  tooltip: 'Next Hop',
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: widget.onStartTraceRoute,
                  child: const Icon(Icons.play_arrow),
                  tooltip:
                      Intl.message('Start Trace Route'), // Localize this line
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  onPressed: () {
                    _navigateToHop(_currentHopIndex - 1);
                  },
                  child: const Icon(Icons.arrow_downward),
                  tooltip: 'Previous Hop',
                ),
              ],
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
}

class HopDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> hop;

  const HopDetailsScreen({Key? key, required this.hop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hop Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hop Number: ${hop['hopNumber']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Address: ${hop['address']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Response Time: ${hop['responseTime']}ms',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            if (hop['geolocation'] != null) ...[
              Text('Location: ${hop['geolocation']['city'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Country: ${hop['geolocation']['country'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}
