import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// Create a mock implementation of the Firebase platform interface
class MockFirebasePlatform {
  // Setup method to be called before tests
  static Future<void> setupFirebaseForTesting() async {
    // Mock the MethodChannel used by Firebase
    TestWidgetsFlutterBinding.ensureInitialized();

    // Register mock MethodChannel handler for firebase_core platform channel
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/firebase_core',
    );

    // Setup mock handlers for the Firebase MethodChannel
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
                  'apiKey': 'test-api-key',
                  'appId': 'test-app-id',
                  'messagingSenderId': 'test-sender-id',
                  'projectId': 'test-project',
                  'databaseURL': 'https://test-database-url.firebaseio.com',
                  'storageBucket': 'test-project.appspot.com',
                },
                'pluginConstants': {},
              }
            ];
          case 'Firebase#initializeApp':
            return {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'test-api-key',
                'appId': 'test-app-id',
                'messagingSenderId': 'test-sender-id',
                'projectId': 'test-project',
                'databaseURL': 'https://test-database-url.firebaseio.com',
                'storageBucket': 'test-project.appspot.com',
              },
              'pluginConstants': {},
            };
          default:
            return null;
        }
      },
    );

    // Initialize Firebase with mock options
    await Firebase.initializeApp(
      name: '[DEFAULT]',
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project',
        databaseURL: 'https://test-database-url.firebaseio.com',
        storageBucket: 'test-project.appspot.com',
      ),
    );
  }
}

// Also add mock handlers for Firebase Auth
class MockFirebaseAuthPlatform {
  static Future<void> setupFirebaseAuthMocks() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_auth'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'currentUser':
            return null;
          case 'signInAnonymously':
            return {
              'user': {
                'uid': 'test-uid',
                'isAnonymous': true,
                'email': null,
                'displayName': null,
              }
            };
          default:
            return null;
        }
      },
    );
  }
}

// Add mock handlers for Firestore as well
class MockFirestorePlatform {
  static Future<void> setupFirestoreMocks() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/firebase_firestore'),
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case 'Query#get':
            return {
              'documents': [],
              'metadata': {'hasPendingWrites': false, 'isFromCache': false},
            };
          case 'DocumentReference#get':
            return {
              'data': {},
              'metadata': {'hasPendingWrites': false, 'isFromCache': false},
              'path': 'test/path',
            };
          default:
            return null;
        }
      },
    );
  }
}
