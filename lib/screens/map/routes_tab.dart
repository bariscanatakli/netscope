import 'package:flutter/material.dart';

class RoutesTab extends StatelessWidget {
  final List<Map<String, dynamic>> routes;
  final Function(int index, Map<String, dynamic> newRoute) onRouteUpdate;

  const RoutesTab({
    super.key,
    required this.routes,
    required this.onRouteUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: routes.length,
      itemBuilder: (context, index) {
        final route = routes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: Text(
              route['flag'] ?? '🚩',
              style: const TextStyle(fontSize: 32),
            ),
            title: Text(route['hop'] ?? 'Hop Name'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("IP Address: ${route['ip'] ?? 'Unknown'}"),
                Text("Host: ${route['host'] ?? 'Unknown'}"),
                Text("Location: ${route['location'] ?? 'Unknown'}"),
              ],
            ),
            trailing: Text(
              route['time'] ?? '0ms',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
