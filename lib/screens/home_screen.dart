import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this line for localization
import 'login_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Intl.message("NetScope")), // Localize this line
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: Intl.message("Logout"), // Localize this line
            onPressed: () {
              // Navigate to the login screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns for better spacing
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: 6, // Reduced to 6 tiles for simplicity
          itemBuilder: (context, index) {
            // Define the content for the tiles
            final isMapTile = index == 0;
            final isSpeedtestTile = index == 1;

            return GestureDetector(
              onTap: () {
                if (isMapTile) {
                  // Navigate to the Map screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen()),
                  );
                }
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isMapTile
                          ? Icons.map
                          : isSpeedtestTile
                              ? Icons.speed
                              : Icons.category,
                      size: 40,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isMapTile
                          ? Intl.message("Map") // Localize this line
                          : isSpeedtestTile
                              ? Intl.message("Speedtest") // Localize this line
                              : Intl.message("Blank"), // Localize this line
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isMapTile
                          ? Intl.message("Updated today") // Localize this line
                          : isSpeedtestTile
                              ? Intl.message(
                                  "Upcoming...") // Localize this line
                              : Intl.message("Blank"), // Localize this line
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, // Set Homepage as the active tab
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: Intl.message("Profile"), // Localize this line
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: Intl.message("Favorites"), // Localize this line
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: Intl.message("Homepage"), // Localize this line
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: Intl.message("Contribute"), // Localize this line
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: Intl.message("Updates"), // Localize this line
          ),
        ],
      ),
    );
  }
}
