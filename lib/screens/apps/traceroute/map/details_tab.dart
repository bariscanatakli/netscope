import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this line for localization

class DetailsTab extends StatelessWidget {
  final List<Map<String, dynamic>> tracerouteDetails;

  const DetailsTab({Key? key, required this.tracerouteDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        itemCount: tracerouteDetails.length,
        itemBuilder: (context, index) {
          final hop = tracerouteDetails[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ExpansionTile(
              title: Text(
                'Hop ${hop['hopNumber']}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                hop['address'] ?? 'Unknown',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          'Response Time', '${hop['responseTime']}ms'),
                      if (hop['geolocation'] != null) ...[
                        _buildDetailRow('Location',
                            hop['geolocation']['city'] ?? 'Unknown'),
                        _buildDetailRow('Country',
                            hop['geolocation']['country'] ?? 'Unknown'),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
