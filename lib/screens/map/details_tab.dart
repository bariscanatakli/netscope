import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this line for localization

class DetailsTab extends StatelessWidget {
  final List<Map<String, dynamic>> tracerouteDetails;

  const DetailsTab({
    super.key,
    required this.tracerouteDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Intl.message('Traceroute Details'), // Localize this line
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              Intl.message(
                  'Traceroute is a network diagnostic tool used to track the pathway taken by a packet on an IP network from source to destination. It helps in identifying the route and measuring transit delays of packets across the network.'), // Localize this line
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (tracerouteDetails.isEmpty)
              Center(
                child: Column(
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
            else ...[
              Text(
                '${Intl.message('Destination')}: ${tracerouteDetails.first['address']}', // Localize this line
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                Intl.message('Hops:'), // Localize this line
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              ...tracerouteDetails.map((details) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hop ${details['hopNumber']}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Text('IP Address: ${details['address']}'),
                        Text('Response Time: ${details['responseTime']} ms'),
                        Text('Details: ${details['details']}'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
