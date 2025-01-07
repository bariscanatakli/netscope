import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this line for localization

class RouteDetailsScreen extends StatelessWidget {
  const RouteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> hop =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(Intl.message('Hop Details')), // Localize this line
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${Intl.message('Hop Number')}: ${hop['hopNumber']}'), // Localize this line
            Text(
                '${Intl.message('IP Address')}: ${hop['address']}'), // Localize this line
            Text(
                '${Intl.message('Response Time')}: ${hop['responseTime']} ms'), // Localize this line
            Text(
                '${Intl.message('City')}: ${hop['geolocation']['city']}'), // Localize this line
            Text(
                '${Intl.message('Country')}: ${hop['geolocation']['country_name']}'), // Localize this line
            Text(
                '${Intl.message('Details')}: ${hop['details']}'), // Localize this line
          ],
        ),
      ),
    );
  }
}
