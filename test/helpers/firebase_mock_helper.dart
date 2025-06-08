import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseApp extends Mock {
  String get name => 'test-app';
  String get options => 'test-options';
}

// Mock implementation for Firebase initialization
Future<void> setupFirebaseMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up mocked MethodChannel responses
  const channel = MethodChannel('plugins.flutter.io/firebase_core');
  
  // Override default MethodChannel handling
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firebase#initializeCore':
          return [
            {
              'name': 'test-app',
              'options': {
                'apiKey': 'test-api-key',
                'appId': 'test-app-id',
                'messagingSenderId': 'test-sender-id',
                'projectId': 'test-project-id',
              },
              'pluginConstants': {},
            }
          ];
        case 'Firebase#initializeApp':
          return {
            'name': 'test-app',
            'options': {
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project-id',
            },
            'pluginConstants': {},
          };
        default:
          return null;
      }
    },
  );
}
