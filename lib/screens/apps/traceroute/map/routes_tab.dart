import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this line for localization

class HopsTab extends StatelessWidget {
  final List<Map<String, dynamic>> hops;
  final Function(int index, Map<String, dynamic> newHop) onHopUpdate;

  const HopsTab({
    super.key,
    required this.hops,
    required this.onHopUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return hops.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  Intl.message('Waiting for data...'), // Localize this line
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: hops.length,
            itemBuilder: (context, index) {
              final hop = hops[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Text(
                    hop['flag'] ?? '🚩',
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text('Hop ${hop['hopNumber']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("IP Address: ${hop['address']}"),
                      Text("Response Time: ${hop['responseTime']} ms"),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/routeDetails',
                      arguments: hop,
                    );
                  },
                ),
              );
            },
          );
  }
}
