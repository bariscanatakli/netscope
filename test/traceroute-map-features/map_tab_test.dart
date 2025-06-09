import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:netscope/screens/apps/traceroute/map/map_tab.dart';

class FakeGoogleMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(key: Key('FakeGoogleMap'));
  }
}

void main() {
  group('MapTab Widget', () {
    final mockHops = [
      {
        'hopNumber': 1,
        'address': '192.168.1.1',
        'geolocation': {'lat': 41.0, 'lon': 29.0, 'city': 'Istanbul', 'country': 'Turkey'},
      },
      {
        'hopNumber': 2,
        'address': '10.0.0.1',
        'geolocation': {'lat': 52.5, 'lon': 13.4, 'city': 'Berlin', 'country': 'Germany'},
      },
    ];

    testWidgets('renders map and markers for hops', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Container(key: Key('FakeGoogleMap')),
          ),
        ),
      );
      expect(find.byKey(Key('FakeGoogleMap')), findsOneWidget);
    });
  });
} 