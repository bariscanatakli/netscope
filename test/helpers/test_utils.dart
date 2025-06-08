import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds the widget for testing and pumps a single frame
Future<void> pumpTestWidget(
  WidgetTester tester, 
  Widget child, 
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: child,
    ),
  );
  await tester.pump();
}

/// Skips test if it requires Firebase auth
void skipTestIfFirebaseNeeded(String reason) {
  // Add this to tests that need Firebase to avoid failures
  markTestSkipped(reason);
}
