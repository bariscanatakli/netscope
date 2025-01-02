import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_notifier.dart';
import '../auth/login_screen.dart';
import '../map_screen.dart';
import '../auth/forgot_password_screen.dart';

/// This is your root screen that shows the nav bar, app bar, etc.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  // 2 = index for HomePage by default
  int _currentIndex = 0;

  // Sub-pages: Home, Favorites, Profile
  final List<Widget> _pages = const [
    HomePage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The *only* AppBar for the entire app
      appBar: AppBar(
        title: Text(Intl.message("NetScope")),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: Intl.message("Logout"),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            tooltip: Intl.message("Toggle Theme"),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],

      // The *only* BottomNavigationBar for the entire app
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: Intl.message("Homepage"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: Intl.message("Favorites"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: Intl.message("Profile"),
          ),
        ],
      ),
    );
  }
}

/// This is the actual “homepage” content.
/// No Scaffold or AppBar here: it just provides content.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          final isMapTile = (index == 0);
          final isSpeedtestTile = (index == 1);

          return GestureDetector(
            onTap: () {
              if (isMapTile) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              }
              // Add other onTap logic here if needed
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
                        ? Intl.message("Traceroute")
                        : isSpeedtestTile
                        ? Intl.message("Speedtest")
                        : Intl.message("Blank"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMapTile
                        ? Intl.message("")
                        : isSpeedtestTile
                        ? Intl.message("Upcoming...")
                        : Intl.message(""),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Simple Profile page content — no Scaffold here.
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Grab the current user from FirebaseAuth.
    final User? user = FirebaseAuth.instance.currentUser;

    // If the user is logged in, display their displayName (username).
    // Otherwise, show a fallback message.
    final String username = user?.displayName ?? 'No username found';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Display username (pulled from user.displayName)
          Text(
            "Username: $username",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Change Password button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              );
            },
            child: const Text("Change Password"),
          ),
        ],
      ),
    );
  }
}

/// Simple Favorites page content — no Scaffold here.
/// Simple Favorites page content — modified to include Traceroute and Speedtest widgets.
/// Simple Favorites page content — modified to include Traceroute and Speedtest widgets.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Traceroute widget
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 40,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Intl.message("Traceroute"),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.favorite,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Speedtest widget
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.speed,
                        size: 40,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        Intl.message("Speedtest"),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.favorite,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

