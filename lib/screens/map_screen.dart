import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this line for localization
import 'map/routes_tab.dart';
import 'map/map_tab.dart';
import 'map/details_tab.dart';
import 'map/service/trace_route_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> hops = [];
  List<Map<String, dynamic>> tracerouteDetails = [];
  bool _isLoading = false;
  final TraceRouteService _traceRouteService = TraceRouteService();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _traceRoute() async {
    print('Traceroute button pressed');
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _traceRouteService.trace();

      if (!mounted) return; // Check if the widget is still mounted

      setState(() {
        hops = results
            .map((result) => {
                  'hopNumber': result.hopNumber,
                  'address': result.address,
                  'responseTime': result.responseTime,
                  'details': result.toString(),
                  'geolocation': result.geolocation,
                })
            .toList();
        tracerouteDetails = hops; // Pass the hops to tracerouteDetails
        _isLoading = false;
        _selectedIndex = 1; // Switch to hops tab
      });
    } catch (e) {
      print('Error during traceroute: $e');
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(Intl.message("Trace Route")), // Localize this line
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MapTab(
            hops: hops,
            onMapInteraction: (isInteracting) {},
            onStartTraceRoute: _traceRoute,
            isFetching: _isLoading,
          ),
          HopsTab(hops: hops, onHopUpdate: (index, newHop) {}),
          DetailsTab(tracerouteDetails: tracerouteDetails),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: Intl.message('Map'), // Localize this line
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions),
            label: Intl.message('Hops'), // Localize this line
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.details),
            label: Intl.message('Details'), // Localize this line
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
