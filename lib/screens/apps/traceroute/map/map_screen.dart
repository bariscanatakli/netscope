import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this line for localization
import 'routes_tab.dart';
import 'map_tab.dart';
import 'details_tab.dart';
import 'services/trace_route_service.dart';
import 'hops_tab.dart'; // Import the HopsTab class

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
  final user = FirebaseAuth.instance.currentUser;
  DateTime? currentTraceTime;
  String? destinationAddress;
  bool isHistoricalTrace = false;

  @override
  void initState() {
    super.initState();
    _fetchLastTraceroute();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchLastTraceroute() async {
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('traceroutes')
        .doc(user!.uid)
        .collection('results')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      setState(() {
        hops = List<Map<String, dynamic>>.from(data['hops']);
        tracerouteDetails = hops;
        currentTraceTime = (data['timestamp'] as Timestamp).toDate();
        isHistoricalTrace = true;
      });
    }
  }

  Future<void> _traceRoute() async {
    print('Traceroute button pressed');
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _traceRouteService.trace();

      if (!mounted) return;

      // Reverse the results to show from user's network to the destination
      final reversedResults = results.reversed.toList();

      // Adjust hop numbers to start from 1
      for (int i = 0; i < reversedResults.length; i++) {
        reversedResults[i] = reversedResults[i].copyWith(
          hopNumber: i + 1,
        );
      }

      // Get the first hop as destination (since the list is reversed)
      final firstHop = reversedResults.first;
      final destination = firstHop.address;

      setState(() {
        hops = reversedResults
            .map((result) => {
                  'hopNumber': result.hopNumber,
                  'address': result.address,
                  'responseTime':
                      result.responseTime, // Use responseTime (ping time)
                  'pingTime': result.pingTime,
                  'details': result.toString(),
                  'geolocation': result.geolocation,
                })
            .toList();
        tracerouteDetails = hops;
        _isLoading = false;
        _selectedIndex = 1;
        currentTraceTime = DateTime.now();
        isHistoricalTrace = false;
        destinationAddress = destination; // Ensure destination is set
      });

      // Save to Firestore with destination
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('traceroutes')
            .doc(user!.uid)
            .collection('results')
            .add({
          'timestamp': FieldValue.serverTimestamp(),
          'hops': hops,
          'destination': destination, // Store destination
        });
      }
    } catch (e) {
      print('Error during traceroute: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during traceroute: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
        centerTitle: true,
        title: _isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getLocalizedString("Trace Route"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              )
            : Text(
                _getLocalizedString("Trace Route"),
                style: const TextStyle(color: Colors.white),
              ),
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
          HopsTab(hops: hops), // Use the HopsTab class
          DetailsTab(tracerouteDetails: tracerouteDetails),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: _getLocalizedString('Map'), // Localize this line
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions),
            label: _getLocalizedString('Hops'), // Localize this line
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.details),
            label: _getLocalizedString('Details'), // Localize this line
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  String _getLocalizedString(String key) {
    return Intl.message(key);
  }
}
