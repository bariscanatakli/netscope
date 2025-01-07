import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this line for localization

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

  Future<void> _showHistory() async {
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('traceroutes')
        .doc(user!.uid)
        .collection('results')
        .orderBy('timestamp', descending: true)
        .get();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Traceroute History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.docs[index].data();
                      final timestamp = data['timestamp'] as Timestamp;
                      final hopCount = (data['hops'] as List).length;

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text('${index + 1}'),
                          ),
                          title: Text('AWS EC2 Instance (172.18.0.1)'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat.yMMMd()
                                    .add_jm()
                                    .format(timestamp.toDate()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Hops: $hopCount',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.map),
                            onPressed: () {
                              setState(() {
                                hops = List<Map<String, dynamic>>.from(
                                    data['hops']);
                                tracerouteDetails = hops;
                                currentTraceTime = timestamp.toDate();
                                isHistoricalTrace = true;
                                _selectedIndex = 0; // Switch to map tab
                              });
                              Navigator.pop(context);
                            },
                          ),
                          onTap: () {
                            setState(() {
                              hops =
                                  List<Map<String, dynamic>>.from(data['hops']);
                              tracerouteDetails = hops;
                              currentTraceTime = timestamp.toDate();
                              isHistoricalTrace = true;
                              _selectedIndex = 1; // Switch to hops tab
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _traceRoute() async {
    print('Traceroute button pressed');
    setState(() {
      _isLoading = true;
      isHistoricalTrace =
          false; // Ensure this is set to false when starting a new trace
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

  Future<void> _confirmDisruption() async {
    final shouldDisrupt = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disrupt Traceroute'),
        content: Text('Do you want to disrupt the traceroute process?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldDisrupt == true) {
      // Handle disruption logic here
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_isLoading) {
      await _confirmDisruption();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Traceroute'),
          centerTitle: true, // Center the title
          actions: [
            if (_isLoading)
              IconButton(
                icon: Icon(Icons.cancel),
                onPressed: _confirmDisruption,
              ),
            IconButton(
              icon: Icon(Icons.history),
              onPressed: _showHistory,
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isLoading) LinearProgressIndicator(),
            Expanded(
              child: IndexedStack(
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
            ),
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
      ),
    );
  }

  String _getLocalizedString(String key) {
    return Intl.message(key);
  }
}
