import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../apps/traceroute/map/map_screen.dart';
import '../apps/speedtest/speedtest_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.fetchFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4, // Updated to include new apps
        itemBuilder: (context, index) {
          final appId = getAppId(index);
          final isMapTile = appId == 'traceroute';
          final isSpeedtestTile = appId == 'speedtest';

          return HomeTile(
            appId: appId,
            isMapTile: isMapTile,
            isSpeedtestTile: isSpeedtestTile,
          );
        },
      ),
    );
  }

  String getAppId(int index) {
    switch (index) {
      case 0:
        return 'traceroute';
      case 1:
        return 'speedtest';
      case 2:
        return 'pingtest';
      case 3:
        return 'networkscanner';
      default:
        return 'unknown';
    }
  }
}

class HomeTile extends StatelessWidget {
  final String appId;
  final bool isMapTile;
  final bool isSpeedtestTile;

  const HomeTile({
    required this.appId,
    required this.isMapTile,
    required this.isSpeedtestTile,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isFavorite = authProvider.favorites.contains(appId);

    return GestureDetector(
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(child: CircularProgressIndicator());
          },
        );

        if (isMapTile) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        } else if (isSpeedtestTile) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SpeedTestScreen()),
          );
        } else {
          // Handle dummy app navigation
          await Future.delayed(const Duration(seconds: 1)); // Simulate loading
        }

        Navigator.pop(context); // Close the loading dialog
      },
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      getIconForApp(appId),
                      size: 50,
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      getAppName(appId),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (appId == 'pingtest' || appId == 'networkscanner')
                      const Text(
                        'In Progress',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : Colors.grey,
                ),
                onPressed: () async {
                  if (isFavorite) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Remove Favorite'),
                          content: const Text(
                              'Are you sure you want to remove this favorite?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Remove'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      authProvider.removeFavorite(appId);
                    }
                  } else {
                    authProvider.addFavorite(appId);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData getIconForApp(String appId) {
    switch (appId) {
      case 'traceroute':
        return Icons.map;
      case 'speedtest':
        return Icons.speed;
      case 'pingtest':
        return Icons.network_ping;
      case 'networkscanner':
        return Icons.scanner;
      default:
        return Icons.device_unknown;
    }
  }

  String getAppName(String appId) {
    switch (appId) {
      case 'traceroute':
        return 'Traceroute';
      case 'speedtest':
        return 'Speed Test';
      case 'pingtest':
        return 'Ping Test';
      case 'networkscanner':
        return 'Scanner';
      default:
        return 'Unknown App';
    }
  }
}
