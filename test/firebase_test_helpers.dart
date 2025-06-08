import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';

class MockFirebaseApp {
  static Future<void> setupMockFirebase() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Setup mock Firebase Core
    setupFirebaseCoreMocks();

    // Initialize a mock Firebase app
    await Firebase.initializeApp(
      name: 'test',
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project',
      ),
    );
  }
}

// Mock Firebase Core Platform Interface
void setupFirebaseCoreMocks() {
  // Register a mock FirebasePlatform instance
  TestWidgetsFlutterBinding.ensureInitialized();

  // Create mock MethodChannel to handle platform channel messages
  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );

  // Mock platform interactions for Firebase Core
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firebase#initializeCore':
          return [
            {
              'name': 'test',
              'options': {
                'apiKey': 'test-api-key',
                'appId': 'test-app-id',
                'messagingSenderId': 'test-sender-id',
                'projectId': 'test-project',
              },
              'pluginConstants': {},
            }
          ];
        case 'Firebase#initializeApp':
          return {
            'name': 'test',
            'options': {
              'apiKey': 'test-api-key',
              'appId': 'test-app-id',
              'messagingSenderId': 'test-sender-id',
              'projectId': 'test-project',
            },
            'pluginConstants': {},
          };
        default:
          return null;
      }
    },
  );
}
