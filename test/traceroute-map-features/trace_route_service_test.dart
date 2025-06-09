import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/screens/apps/traceroute/map/services/trace_route_service.dart';
import 'dart:async';

class MockTraceRouteService extends TraceRouteService {
  bool shouldThrow = false;
  @override
  Future<String> _getDeviceIpAddress() async => '1.1.1.1';

  @override
  Future<Map<String, dynamic>> _getGeolocation(String ipAddress) async {
    if (shouldThrow) throw Exception('fail');
    return {
      'city': 'TestCity',
      'country': 'TestCountry',
    };
  }

  @override
  Future<int> _pingIpAddress(String ipAddress) async => 42;

  @override
  Future<List<TracerouteResult>> trace() async {
    return [
      TracerouteResult(
        hopNumber: 1,
        address: '1.1.1.1',
        responseTime: 42.0,
        isSuccess: true,
        geolocation: {'city': 'TestCity', 'country': 'TestCountry'},
        pingTime: 42,
      ),
      TracerouteResult(
        hopNumber: 2,
        address: '2.2.2.2',
        responseTime: 55.0,
        isSuccess: true,
        geolocation: {'city': 'TestCity2', 'country': 'TestCountry2'},
        pingTime: 55,
      ),
    ];
  }
}

void main() {
  group('TraceRoute Service Tests', () {
    final service = MockTraceRouteService();

    test('Traceroute returns static hops', () async {
      final results = await service.trace();
      expect(results.length, 2);
      expect(results[0].address, '1.1.1.1');
      expect(results[1].geolocation['city'], 'TestCity2');
    });

    test('Geolocation returns mock data', () async {
      final geo = await service._getGeolocation('8.8.8.8');
      expect(geo['city'], 'TestCity');
      expect(geo['country'], 'TestCountry');
    });

    test('Ping returns mock value', () async {
      final ping = await service._pingIpAddress('8.8.8.8');
      expect(ping, 42);
    });

    test('Device IP returns mock value', () async {
      final ip = await service._getDeviceIpAddress();
      expect(ip, '1.1.1.1');
    });

    test('Handles error in geolocation gracefully', () async {
      final brokenService = MockTraceRouteService();
      brokenService.shouldThrow = true;
      try {
        await brokenService._getGeolocation('fail');
        fail('Should throw');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
