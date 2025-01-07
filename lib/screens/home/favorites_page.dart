import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../apps/traceroute/map/map_screen.dart';
import '../apps/speedtest/speedtest_screen.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final favorites = authProvider.favorites ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final appId = favorites[index];
          return FavoriteCard(appId: appId);
        },
      ),
    );
  }
}

class FavoriteCard extends StatelessWidget {
  final String appId;

  const FavoriteCard({required this.appId, super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isMapTile = appId == 'traceroute';
    final isSpeedtestTile = appId == 'speedtest';

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
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.redAccent,
                ),
                onPressed: () async {
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
        return 'Network Scanner';
      default:
        return 'Unknown App';
    }
  }
}
