import 'package:flutter/material.dart';

class RoutesTab extends StatelessWidget {
  final List<Map<String, dynamic>> hops;

  const RoutesTab({Key? key, required this.hops}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: hops.length,
      itemBuilder: (context, index) {
        final hop = hops[index];
        return ListTile(
          leading: Text(
            hop['flag'] ?? '🚩',
            style: const TextStyle(fontSize: 32),
          ),
          title: Text('Hop ${hop['hopNumber']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("IP Address: ${hop['address']}"),
              Text(
                  "Ping Time: ${hop['pingTime'] != -1 ? '${hop['pingTime']} ms' : 'N/A'}"), // Display pingTime or N/A
            ],
          ),
          trailing: const Icon(Icons.arrow_forward),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HopDetailsScreen(hop: hop),
              ),
            );
          },
        );
      },
    );
  }
}

class HopDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> hop;

  const HopDetailsScreen({Key? key, required this.hop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hop Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hop Number: ${hop['hopNumber']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Address: ${hop['address']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Response Time: ${hop['responseTime']}ms',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            if (hop['geolocation'] != null) ...[
              Text('Location: ${hop['geolocation']['city'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text('Country: ${hop['geolocation']['country'] ?? 'Unknown'}',
                  style: TextStyle(fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}
