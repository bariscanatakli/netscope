import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:netscope/services/network_info_service.dart';

// Generate mock class
@GenerateMocks([http.Client])
import 'network_info_service_test.mocks.dart';

void main() {
  group('NetworkInfoService', () {
    late NetworkInfoService service;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      service = NetworkInfoService(client: mockClient);
    });

    test('should return IP info from API', () async {
      // Arrange - Setup mock to return successful response for the first API
      when(mockClient.get(Uri.parse('https://api.ipify.org?format=json')))
          .thenAnswer((_) async => http.Response(
              jsonEncode({'ip': '123.123.123.123'}), 200));

      // Act
      final result = await service.getNetworkInfo();

      // Assert
      expect(result['ip'], '123.123.123.123');
      expect(result['isConnected'], true);
      expect(result['connectionType'], anyOf(['Connected', 'Unknown']));
    });

    test('should fallback to local interface if all APIs fail', () async {
      // Arrange - Setup all API calls to fail
      when(mockClient.get(any)).thenAnswer(
          (_) async => http.Response('{"error":"API not available"}', 404));

      // Act
      final result = await service.getNetworkInfo();

      // Assert - Should fallback to local IP
      expect(result['ip'], isNotNull);
      expect(result['isConnected'], true);
    });

    test('should return error info if there is no network', () async {
      // Arrange - Setup mock to throw exception for any request
      when(mockClient.get(any)).thenThrow(Exception('No network'));

      // Act
      final result = await service.getNetworkInfo();

      // Assert - Should return error info
      expect(result['ip'], 'Error: Check internet connection');
      expect(result['isConnected'], false);
    });
  });
}