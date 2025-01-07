import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class NetworkInfoService {
  Future<Map<String, dynamic>> getNetworkInfo() async {
    try {
      // Try multiple IP API services
      final apis = [
        'https://api.ipify.org?format=json',
        'https://api.myip.com',
        'https://api64.ipify.org/json',
        'https://ipapi.co/json/'
      ];

      for (final api in apis) {
        try {
          final response = await http.get(Uri.parse(api));
          if (response.statusCode == 200) {
            final ipData = json.decode(response.body);
            final ip = ipData['ip'] ?? 'Not available';
            return {
              'ip': ip,
              'connectionType': await _getConnectionType(),
              'isConnected': true,
            };
          }
        } catch (_) {
          continue;
        }
      }

      // Fallback to local network interfaces
      final interfaces = await NetworkInterface.list();
      final ipAddress = interfaces
          .expand((interface) => interface.addresses)
          .where((addr) =>
              !addr.isLoopback && addr.type == InternetAddressType.IPv4)
          .map((addr) => addr.address)
          .firstOrNull;

      return {
        'ip': ipAddress ?? 'Not available (Emulator)',
        'connectionType': await _getConnectionType(),
        'isConnected': true,
      };
    } catch (e) {
      return {
        'ip': 'Error: Check internet connection',
        'connectionType': 'Unknown',
        'isConnected': false,
      };
    }
  }

  Future<String> _getConnectionType() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return 'Connected';
      }
    } catch (_) {
      return 'No Connection';
    }
    return 'Unknown';
  }
}
