import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:netscope/screens/apps/traceroute/map/services/trace_route_service.dart';

class MockClient extends Mock implements http.Client {}

void main() {
  late TraceRouteService traceRouteService;
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient();
    traceRouteService = TraceRouteService(httpClient: mockClient);
  });

  group('TraceRouteService', () {
    test('getDeviceIpAddress returns IP address on success', () async {
      when(mockClient.get(Uri.parse('https://api.ipify.org?format=json')))
          .thenAnswer((_) async => http.Response('{"ip": "192.168.1.1"}', 200));

      final ip = await traceRouteService.getDeviceIpAddress();
      expect(ip, '192.168.1.1');
    });

    test('getDeviceIpAddress throws exception on error', () async {
      when(mockClient.get(Uri.parse('https://api.ipify.org?format=json')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(() => traceRouteService.getDeviceIpAddress(), throwsException);
    });

    test('getGeolocation returns location data on success', () async {
      when(mockClient.get(Uri.parse('http://ip-api.com/json/192.168.1.1')))
          .thenAnswer((_) async => http.Response(
              '{"city": "Test City", "country": "Test Country", "lat": 41.0, "lon": 29.0}',
              200));

      final location = await traceRouteService.getGeolocation('192.168.1.1');
      expect(location['city'], 'Test City');
      expect(location['country'], 'Test Country');
      expect(location['lat'], 41.0);
      expect(location['lon'], 29.0);
    });

    test('getGeolocation returns unknown location on error', () async {
      when(mockClient.get(Uri.parse('http://ip-api.com/json/192.168.1.1')))
          .thenAnswer((_) async => http.Response('Error', 500));

      final location = await traceRouteService.getGeolocation('192.168.1.1');
      expect(location['city'], 'Unknown');
      expect(location['country'], 'Unknown');
    });

    test('pingIpAddress returns response time on success', () async {
      when(mockClient.get(Uri.parse('http://192.168.1.1')))
          .thenAnswer((_) async => http.Response('', 200));

      final responseTime = await traceRouteService.pingIpAddress('192.168.1.1');
      expect(responseTime, isA<int>());
    });

    test('pingIpAddress returns -1 on error', () async {
      when(mockClient.get(Uri.parse('http://192.168.1.1')))
          .thenAnswer((_) async => http.Response('Error', 500));

      final responseTime = await traceRouteService.pingIpAddress('192.168.1.1');
      expect(responseTime, -1);
    });

    test('trace returns list of traceroute results', () async {
      when(mockClient.get(Uri.parse('http://localhost:3000/trace')))
          .thenAnswer((_) async => http.Response(
              jsonEncode([
                {
                  'hopNumber': 1,
                  'address': '192.168.1.1',
                  'responseTime': 10.0,
                  'isSuccess': true,
                }
              ]),
              200));

      final results = await traceRouteService.trace();
      expect(results, isNotEmpty);
      expect(results[0].hopNumber, 1);
      expect(results[0].address, '192.168.1.1');
    });

    test('trace throws exception on API error', () async {
      when(mockClient.get(Uri.parse('http://localhost:3000/trace')))
          .thenAnswer((_) async => http.Response('Error', 500));

      expect(() => traceRouteService.trace(), throwsException);
    });

    test('extractIpAddress extracts IP from various formats', () {
      expect(traceRouteService.extractIpAddress('192.168.1.1'), '192.168.1.1');
      expect(traceRouteService.extractIpAddress('Reply from 192.168.1.1: bytes=32 time=10ms TTL=64'),
          '192.168.1.1');
      expect(traceRouteService.extractIpAddress('Request timed out.'), '');
    });
  });
} 