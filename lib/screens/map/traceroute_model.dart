import 'package:flutter/material.dart';

class TracerouteModel with ChangeNotifier {
  List<Map<String, dynamic>> _routes = [
    {
      'flag': '🇹🇷',
      'hop': 'Hop 1',
      'ip': '192.168.1.254',
      'host': 'local-router.local',
      'location': 'Local Network',
      'time': '2ms'
    },
    {
      'flag': '🇹🇷',
      'hop': 'Hop 2',
      'ip': '10.1.0.1',
      'host': 'isp-gateway',
      'location': 'Istanbul, Turkey',
      'time': '10ms'
    },
    {
      'flag': '🇹🇷',
      'hop': 'Hop 3',
      'ip': '203.0.113.1',
      'host': 'isp-backbone',
      'location': 'Ankara, Turkey',
      'time': '15ms'
    },
    {
      'flag': '🇩🇪',
      'hop': 'Hop 4',
      'ip': '192.0.2.1',
      'host': 'intl-gateway',
      'location': 'Frankfurt, Germany',
      'time': '30ms'
    },
  ];

  List<Map<String, dynamic>> get routes => _routes;

  void updateRoutes(List<Map<String, dynamic>> newRoutes) {
    _routes = newRoutes;
    notifyListeners();
  }
}
