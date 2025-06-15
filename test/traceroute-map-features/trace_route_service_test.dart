import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:netscope/screens/apps/traceroute/map/services/trace_route_service.dart';

class MockClient extends Mock implements http.Client {
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) =>
      super.noSuchMethod(
        Invocation.method(#get, [url], {#headers: headers}),
        returnValue: Future.value(http.Response('', 200)),
        returnValueForMissingStub: Future.value(http.Response('', 200)),
      );

  @override
  Future<http.Response> post(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      super.noSuchMethod(
        Invocation.method(#post, [url],
            {#headers: headers, #body: body, #encoding: encoding}),
        returnValue: Future.value(http.Response('', 200)),
        returnValueForMissingStub: Future.value(http.Response('', 200)),
      );
}

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
              '{"status": "success", "city": "Test City", "country": "Test Country", "lat": 41.0, "lon": 29.0}',
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

    test('getGeolocation handles failed API response status', () async {
      when(mockClient.get(Uri.parse('http://ip-api.com/json/192.168.1.1')))
          .thenAnswer((_) async => http.Response(
              '{"status": "fail", "message": "Invalid IP"}', 200));

      final location = await traceRouteService.getGeolocation('192.168.1.1');
      expect(location['city'], 'Unknown');
      expect(location['country'], 'Unknown');
    });

    test('extractIpAddress extracts IP from various formats', () {
      // Test basic IP
      expect(traceRouteService.extractIpAddress('192.168.1.1'), '192.168.1.1');

      // Test IP in parentheses
      expect(traceRouteService.extractIpAddress('hostname (192.168.1.1)'),
          '192.168.1.1');

      // Test with null
      expect(traceRouteService.extractIpAddress(null), '*');

      // Test timeout case
      expect(traceRouteService.extractIpAddress('Request timed out.'),
          'Request timed out.');
    });

    test('TracerouteResult toString formats correctly for success', () {
      final result = TracerouteResult(
        hopNumber: 1,
        address: '192.168.1.1',
        responseTime: 10.5,
        isSuccess: true,
        geolocation: {'city': 'Test City', 'country': 'Test Country'},
        pingTime: 10,
      );

      final toString = result.toString();
      expect(toString, contains('Hop 1'));
      expect(toString, contains('192.168.1.1'));
      expect(toString, contains('10.5 ms'));
      expect(toString, contains('Test City, Test Country'));
    });

    test('TracerouteResult toString formats correctly for failure', () {
      final result = TracerouteResult(
        hopNumber: 2,
        address: '*',
        responseTime: -1.0,
        isSuccess: false,
        geolocation: {},
        pingTime: -1,
      );

      final toString = result.toString();
      expect(toString, contains('Hop 2'));
      expect(toString, contains('**** (No response)'));
    });

    test('TracerouteResult copyWith works correctly', () {
      final original = TracerouteResult(
        hopNumber: 1,
        address: '192.168.1.1',
        responseTime: 10.5,
        isSuccess: true,
        geolocation: {'city': 'Test City', 'country': 'Test Country'},
        pingTime: 10,
      );

      final copied = original.copyWith(
        hopNumber: 2,
        responseTime: 20.0,
      );

      expect(copied.hopNumber, 2);
      expect(copied.responseTime, 20.0);
      expect(copied.address, '192.168.1.1'); // unchanged
      expect(copied.isSuccess, true); // unchanged
    });

    test('Constructor creates TraceRouteService with default client', () {
      final service = TraceRouteService();
      expect(service, isNotNull);
      expect(service.httpClient, isNotNull);
    });

    test('Constructor creates TraceRouteService with provided client', () {
      final customClient = MockClient();
      final service = TraceRouteService(httpClient: customClient);
      expect(service, isNotNull);
      expect(service.httpClient, equals(customClient));
    });
    group('pingIpAddress tests', () {
      test('pingIpAddress handles network failures gracefully', () async {
        // Test what happens when ping completely fails - use mock instead of real ping
        // This tests the error handling path without actually performing network calls
        expect(
            await traceRouteService.pingIpAddress('invalid-host-999.test'), -1);
      });
    });

    group('trace method comprehensive tests', () {
      test('trace handles API success with multiple hops', () async {
        const simpleResponse = {
          'data': [
            {
              'hop': 1,
              'host': '192.168.1.1',
              'avg': 5.2,
            },
            {
              'hop': 2,
              'host': '8.8.8.8',
              'avg': 15.7,
            },
          ]
        };

        when(mockClient.get(Uri.parse('https://api.ipify.org?format=json')))
            .thenAnswer(
                (_) async => http.Response('{"ip": "192.168.1.1"}', 200));

        when(mockClient.post(
          Uri.parse('https://api.siterelic.com/mtr'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer(
            (_) async => http.Response(json.encode(simpleResponse), 200));

        when(mockClient.get(Uri.parse('http://ip-api.com/json/192.168.1.1')))
            .thenAnswer((_) async => http.Response(
                '{"status": "success", "city": "Local", "country": "LAN", "lat": 0.0, "lon": 0.0}',
                200));

        when(mockClient.get(Uri.parse('http://ip-api.com/json/8.8.8.8')))
            .thenAnswer((_) async => http.Response(
                '{"status": "success", "city": "Mountain View", "country": "United States", "lat": 37.4056, "lon": -122.0775}',
                200));

        final results = await traceRouteService.trace();
        expect(results.length, 2);
        expect(results[0].hopNumber, 1);
        expect(results[0].address, '192.168.1.1');
        expect(results[1].hopNumber, 2);
        expect(results[1].address, '8.8.8.8');
      });

      test('trace handles API 4xx/5xx errors', () async {
        when(mockClient.get(Uri.parse('https://api.ipify.org?format=json')))
            .thenAnswer(
                (_) async => http.Response('{"ip": "192.168.1.1"}', 200));

        when(mockClient.post(
          Uri.parse('https://api.siterelic.com/mtr'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer(
            (_) async => http.Response('{"error": "API limit exceeded"}', 429));

        expect(() => traceRouteService.trace(), throwsException);
      });

      test('trace handles network connectivity issues', () async {
        when(mockClient.get(Uri.parse('https://api.ipify.org?format=json')))
            .thenAnswer(
                (_) async => http.Response('{"ip": "192.168.1.1"}', 200));

        when(mockClient.post(
          Uri.parse('https://api.siterelic.com/mtr'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(Exception('Network connection failed'));

        expect(() => traceRouteService.trace(), throwsException);
      });

      test('trace handles invalid JSON responses', () async {
        when(mockClient.get(Uri.parse('https://api.ipify.org?format=json')))
            .thenAnswer(
                (_) async => http.Response('{"ip": "192.168.1.1"}', 200));

        when(mockClient.post(
          Uri.parse('https://api.siterelic.com/mtr'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Invalid JSON response', 200));

        expect(() => traceRouteService.trace(), throwsException);
      });

      test('trace handles empty/malformed API responses', () async {
        when(mockClient.get(Uri.parse('https://api.ipify.org?format=json')))
            .thenAnswer(
                (_) async => http.Response('{"ip": "192.168.1.1"}', 200));

        when(mockClient.post(
          Uri.parse('https://api.siterelic.com/mtr'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('{"data": null}', 200));

        expect(() => traceRouteService.trace(), throwsException);
      });
    });

    group('getGeolocation edge cases', () {
      test('getGeolocation handles malformed JSON', () async {
        when(mockClient.get(Uri.parse('http://ip-api.com/json/192.168.1.1')))
            .thenAnswer((_) async =>
                http.Response('{"status": "success", "city":}', 200));

        final location = await traceRouteService.getGeolocation('192.168.1.1');
        expect(location['city'], 'Unknown');
        expect(location['country'], 'Unknown');
      });

      test('getGeolocation handles empty response', () async {
        when(mockClient.get(Uri.parse('http://ip-api.com/json/192.168.1.1')))
            .thenAnswer((_) async => http.Response('', 200));

        final location = await traceRouteService.getGeolocation('192.168.1.1');
        expect(location['city'], 'Unknown');
        expect(location['country'], 'Unknown');
      });

      test('getGeolocation handles timeout', () async {
        when(mockClient.get(Uri.parse('http://ip-api.com/json/192.168.1.1')))
            .thenThrow(Exception('Request timeout'));

        final location = await traceRouteService.getGeolocation('192.168.1.1');
        expect(location['city'], 'Unknown');
        expect(location['country'], 'Unknown');
      });
    });
    group('extractIpAddress comprehensive tests', () {
      test('extractIpAddress handles complex hostname formats', () {
        expect(
            traceRouteService.extractIpAddress(
                'complex-hostname-123.example.com (203.0.113.42)'),
            '203.0.113.42');
        expect(
            traceRouteService
                .extractIpAddress('multiple (brackets) (192.168.1.1)'),
            'brackets'); // Gets first match
        expect(traceRouteService.extractIpAddress('no-parentheses.com'),
            'no-parentheses.com');
        expect(traceRouteService.extractIpAddress(''), '');
        expect(traceRouteService.extractIpAddress('(empty-parens)'),
            'empty-parens');
        expect(
            traceRouteService.extractIpAddress('single (ip-here)'), 'ip-here');
      });
    });
  });
}
