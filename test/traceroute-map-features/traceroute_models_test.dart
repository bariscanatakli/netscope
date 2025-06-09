import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/models/traceroute_models.dart';

void main() {
  group('TracerouteHop', () {
    test('serialization and deserialization', () {
      final hop = TracerouteHop(
        hopNumber: 1,
        address: '1.1.1.1',
        responseTime: 10.0,
        geolocation: {'city': 'Paris', 'country': 'France'},
      );
      final map = hop.toMap();
      final fromMap = TracerouteHop.fromMap(map);
      expect(fromMap.hopNumber, 1);
      expect(fromMap.address, '1.1.1.1');
      expect(fromMap.responseTime, 10.0);
      expect(fromMap.geolocation['city'], 'Paris');
      expect(fromMap.isSuccess, true);
    });

    test('copyWith returns updated instance', () {
      final hop = TracerouteHop(
        hopNumber: 1,
        address: '1.1.1.1',
        responseTime: 10.0,
        geolocation: {'city': 'Paris', 'country': 'France'},
      );
      final updated = hop.copyWith(address: '2.2.2.2', isSuccess: false);
      expect(updated.address, '2.2.2.2');
      expect(updated.isSuccess, false);
      expect(updated.hopNumber, 1);
    });
  });

  group('TracerouteResult', () {
    test('serialization and deserialization', () {
      final hop = TracerouteHop(
        hopNumber: 1,
        address: '1.1.1.1',
        responseTime: 10.0,
        geolocation: {'city': 'Paris', 'country': 'France'},
      );
      final result = TracerouteResult(
        hops: [hop],
        timestamp: DateTime(2024, 1, 1),
        destination: '1.1.1.1',
        sourceIp: '192.168.1.2',
      );
      final map = result.toMap();
      final fromMap = TracerouteResult.fromMap(map);
      expect(fromMap.hops.length, 1);
      expect(fromMap.destination, '1.1.1.1');
      expect(fromMap.sourceIp, '192.168.1.2');
    });
  });
} 