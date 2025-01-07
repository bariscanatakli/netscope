import 'package:flutter/material.dart';

class HopDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> hop;

  const HopDetailsScreen({Key? key, required this.hop}) : super(key: key);

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final iconColor = isDarkMode ? Colors.white : theme.primaryColor;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 28,
          color: iconColor,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final accentColor =
        isDarkMode ? Colors.lightBlueAccent : theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hop ${hop['hopNumber']} Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Implement edit functionality if needed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: accentColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.router,
                        size: 40,
                        color: accentColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hop Details',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Node ${hop['hopNumber']}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.textTheme.titleMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Network Information
              Text(
                'Network Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoCard(
                context,
                title: 'IP Address',
                value: hop['address'] ?? 'Unknown',
                icon: Icons.language,
              ),
              _buildInfoCard(
                context,
                title: 'Response Time',
                value: '${hop['responseTime']} ms',
                icon: Icons.timer,
              ),

              const SizedBox(height: 24),

              // Location Information
              if (hop['geolocation'] != null) ...[
                Text(
                  'Location Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildInfoCard(
                  context,
                  title: 'City',
                  value: hop['geolocation']['city'] ?? 'Unknown',
                  icon: Icons.location_city,
                ),
                _buildInfoCard(
                  context,
                  title: 'Country',
                  value: hop['geolocation']['country'] ?? 'Unknown',
                  icon: Icons.public,
                ),
                _buildInfoCard(
                  context,
                  title: 'Region',
                  value: hop['geolocation']['region'] ?? 'Unknown',
                  icon: Icons.map,
                ),
                _buildInfoCard(
                  context,
                  title: 'ISP',
                  value: hop['isp'] ?? 'Unknown',
                  icon: Icons.wifi,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
