import 'package:flutter/material.dart';
import 'map/routes_tab.dart';
import 'map/map_tab.dart';
import 'map/details_tab.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> routes = [];
  List<Map<String, dynamic>> tracerouteDetails = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trace Route"),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MapTab(onMapInteraction: (isInteracting) {}),
          RoutesTab(
            routes: routes,
            onRouteUpdate: (index, newRoute) {},
          ),
          DetailsTab(
            routes: routes,
            tracerouteDetails: tracerouteDetails,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.router),
            label: 'Routes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.details),
            label: 'Details',
          ),
        ],
      ),
    );
  }
}
