import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Setup method to be called before tests that use Firebase
Future<void> setupFirebaseCoreMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup mock method channel handler for Firebase Core
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_core');

  // Register mock handler
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    channel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firebase#initializeCore':
          return [
            {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'mock-api-key',
                'appId': 'mock-app-id',
                'messagingSenderId': 'mock-sender-id',
                'projectId': 'mock-project',
                'storageBucket': 'mock-project.appspot.com',
              },
              'pluginConstants': {},
            }
          ];
        case 'Firebase#initializeApp':
          return {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': 'mock-api-key',
              'appId': 'mock-app-id',
              'messagingSenderId': 'mock-sender-id',
              'projectId': 'mock-project',
              'storageBucket': 'mock-project.appspot.com',
            },
            'pluginConstants': {},
          };
        default:
          return null;
      }
    },
  );

  // Setup mock method channel handler for Firebase Auth
  const MethodChannel authChannel =
      MethodChannel('plugins.flutter.io/firebase_auth');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    authChannel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Auth#authStateChanges':
          return null;
        case 'Auth#idTokenChanges':
          return null;
        case 'Auth#userChanges':
          return null;
        default:
          return null;
      }
    },
  );

  // Setup mock method channel handler for Firestore
  const MethodChannel firestoreChannel =
      MethodChannel('plugins.flutter.io/firebase_firestore');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    firestoreChannel,
    (MethodCall methodCall) async {
      return null;
    },
  );

  // Initialize Firebase with mock implementation
  await Firebase.initializeApp(
    name: '[DEFAULT]',
    options: const FirebaseOptions(
      apiKey: 'mock-api-key',
      appId: 'mock-app-id',
      messagingSenderId: 'mock-sender-id',
      projectId: 'mock-project',
      storageBucket: 'mock-project.appspot.com',
    ),
  );
}
