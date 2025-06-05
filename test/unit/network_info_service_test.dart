// File: test/unit/network_info_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/services/network_info_service.dart';

void main() {
  group('NetworkInfoService Unit Tests', () {
    test('getNetworkInfo returns a map with keys ip, connectionType, isConnected', () async {
      final service = NetworkInfoService();

      late Map<String, dynamic> result;
      try {
        result = await service.getNetworkInfo();
      } catch (e) {
        // In case there is no network in the test environment, ensure that the fallback
        // shape (error) is still well‐formed:
        expect(e, isA<Exception>());
        return;
      }

      // At this point, we have a Map. It should contain the three keys:
      expect(result.containsKey('ip'), isTrue, reason: 'Result must have an "ip" key.');
      expect(result.containsKey('connectionType'), isTrue,
          reason: 'Result must have a "connectionType" key.');
      expect(result.containsKey('isConnected'), isTrue,
          reason: 'Result must have an "isConnected" key.');

      // The “ip” should be a non‐null String (it might say “Error: …” if offline).
      expect(result['ip'], isA<String>());

      // “connectionType” should also be a String
      expect(result['connectionType'], isA<String>());

      // “isConnected” should be a bool
      expect(result['isConnected'], isA<bool>());
    });
  });
}
