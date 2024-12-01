import 'package:flutter/material.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final List<Map<String, dynamic>> _routes = [
    {
      'flag': '🇹🇷',
      'hop': 'Hop 1',
      'ip': '192.168.1.254',
      'host': 'local-router.local',
      'location': 'Local Network',
      'time': '2ms'
    },
    {
      'flag': '🇹🇷',
      'hop': 'Hop 2',
      'ip': '10.1.0.1',
      'host': 'isp-gateway',
      'location': 'Istanbul, Turkey',
      'time': '10ms'
    },
    {
      'flag': '🇹🇷',
      'hop': 'Hop 3',
      'ip': '203.0.113.1',
      'host': 'isp-backbone',
      'location': 'Ankara, Turkey',
      'time': '15ms'
    },
    {
      'flag': '🇩🇪',
      'hop': 'Hop 4',
      'ip': '192.0.2.1',
      'host': 'intl-gateway',
      'location': 'Frankfurt, Germany',
      'time': '30ms'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Trace Route"),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Map"),
              Tab(text: "Routes"),
              Tab(text: "Details"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Map Tab with Image
            Center(
              child: Image.asset(
                'assets/map.jpg', // Make sure to place the image in the assets folder.
                width: 290,
              ),
            ),

            // Routes Tab
            ListView.builder(
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final route = _routes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Text(
                      route['flag'],
                      style: const TextStyle(fontSize: 32),
                    ),
                    title: Text(route['hop']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("IP Address: ${route['ip']}"),
                        Text("Host: ${route['host']}"),
                        Text("Location: ${route['location']}"),
                      ],
                    ),
                    trailing: Text(
                      route['time'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),

            // Details Tab
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Source IP: 192.168.1.1",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Destination IP: 172.217.16.174",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: 2,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favorites",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Homepage",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: "Contribute",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Updates",
            ),
          ],
        ),
      ),
    );
  }
}
