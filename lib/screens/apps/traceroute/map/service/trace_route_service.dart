import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dart_ping/dart_ping.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

class TracerouteOptions {
  final String host;
  final int ttl;
  final int timeout;

  TracerouteOptions({
    required this.host,
    required this.ttl,
    required this.timeout,
  });
}

class TraceRouteService {
  final Logger _logger = Logger('TraceRouteService');

  Future<String> _getDeviceIpAddress() async {
    try {
      _logger.info('Getting device IP address...');
      final response =
          await http.get(Uri.parse('https://api.ipify.org?format=json'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _logger.info('Device IP address: ${data['ip']}');
        return data['ip'];
      } else {
        throw Exception('Failed to get IP address');
      }
    } catch (e) {
      _logger.severe('Error getting IP address: $e');
      throw Exception('Error getting IP address: $e');
    }
  }

  Future<Map<String, dynamic>> _getGeolocation(String ipAddress) async {
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        _logger.info('Getting geolocation for IP address: $ipAddress');
        final response = await http.get(
            Uri.parse('http://ip-api.com/json/$ipAddress')); // Use ip-api.com

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _logger.info('Geolocation data: $data');
          if (data['status'] == 'success') {
            return data;
          } else {
            throw Exception(
                'Failed to get geolocation data: ${data['message']}');
          }
        } else {
          throw Exception('Failed to get geolocation data');
        }
      } catch (e) {
        _logger.severe('Error getting geolocation data for $ipAddress: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          return {
            'city': 'Unknown',
            'country': 'Unknown',
          }; // Return default values on error
        }
      }
    }

    return {
      'city': 'Unknown',
      'country': 'Unknown',
    }; // Return default values on error
  }

  @visibleForTesting
  Future<String> getDeviceIpAddress() =>
      _getDeviceIpAddress(); // Add this line for unit testing

  @visibleForTesting
  Future<Map<String, dynamic>> getGeolocation(String ipAddress) =>
      _getGeolocation(ipAddress); // Add this line for unit testing

  Future<List<TracerouteResult>> trace() async {
    List<TracerouteResult> results = [];
    final ipAddress = await _getDeviceIpAddress();

    try {
      _logger.info('Starting traceroute for IP address: $ipAddress');
      final response = await http.post(
        Uri.parse('https://api.siterelic.com/mtr'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key':
              '09ceeb18-b9c4-47b9-9cdb-df86f3664c4f', // Replace 'YOUR-API-KEY' with your actual API key
        },
        body: json.encode({'url': ipAddress}),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final data = json.decode(response.body);
        _logger.info('Traceroute API response: $data');
        for (var hop in data['data']) {
          final ip = _extractIpAddress(hop['host']);
          final geolocation = await _getGeolocation(ip);
          results.add(TracerouteResult(
            hopNumber: hop['hop'],
            address: hop['host'] ?? '*',
            responseTime: (hop['avg'] as num)
                .toDouble(), // Ensure responseTime is a double
            isSuccess: true,
            geolocation: geolocation,
          ));
        }
      } else {
        throw Exception('Traceroute API failed: ${response.body}');
      }
    } catch (e) {
      _logger.severe('Error executing traceroute: $e');
      throw Exception('Error executing traceroute: $e');
    }

    return results;
  }

  String _extractIpAddress(String? host) {
    if (host == null) return '*';
    final match = RegExp(r'\((.*?)\)').firstMatch(host);
    return match != null ? match.group(1)! : host;
  }

  TracerouteResult? _parseTracerouteLine(String line) {
    // Implement parsing logic based on the traceroute output format
    // Example line: " 1  192.168.1.1 (192.168.1.1)  2.123 ms"
    final regex = RegExp(r'^\s*(\d+)\s+(.*?)\s+\((.*?)\)\s+(.*?ms)');
    final match = regex.firstMatch(line);

    if (match != null) {
      int hopNumber = int.parse(match.group(1)!);
      String address = match.group(3)!;
      String responseTimeStr = match.group(4)!;
      double responseTime = double.parse(responseTimeStr.replaceAll(' ms', ''));

      return TracerouteResult(
        hopNumber: hopNumber,
        address: address,
        responseTime: responseTime,
        isSuccess: true,
        geolocation: {}, // Placeholder for geolocation data
      );
    } else {
      // Handle lines that don't match the expected format
      return null;
    }
  }
}

class TracerouteResult {
  final int hopNumber;
  final String address;
  final double responseTime;
  final bool isSuccess;
  final Map<String, dynamic> geolocation; // Add geolocation field

  TracerouteResult({
    required this.hopNumber,
    required this.address,
    required this.responseTime,
    required this.isSuccess,
    required this.geolocation, // Add geolocation field
  });

  @override
  String toString() {
    return isSuccess
        ? 'Hop $hopNumber: $address (${responseTime} ms) - Location: ${geolocation['city']}, ${geolocation['country']}'
        : 'Hop $hopNumber: **** (No response)';
  }
}
