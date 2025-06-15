import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:netscope/firebase_options.dart';

// Mock Firebase options for testing
class MockFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'mock-web-api-key',
    appId: '1:123456789:web:mockwebappid',
    messagingSenderId: '123456789',
    projectId: 'mock-project-id',
    authDomain: 'mock-project.firebaseapp.com',
    storageBucket: 'mock-project.firebasestorage.app',
    measurementId: 'G-MOCKWEBID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'mock-android-api-key',
    appId: '1:123456789:android:mockandroidappid',
    messagingSenderId: '123456789',
    projectId: 'mock-project-id',
    storageBucket: 'mock-project.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'mock-ios-api-key',
    appId: '1:123456789:ios:mockiosappid',
    messagingSenderId: '123456789',
    projectId: 'mock-project-id',
    storageBucket: 'mock-project.firebasestorage.app',
    androidClientId: 'mock-android-client-id.apps.googleusercontent.com',
    iosClientId: 'mock-ios-client-id.apps.googleusercontent.com',
    iosBundleId: 'com.example.mockapp',
  );
}

void main() {
  group('DefaultFirebaseOptions', () {
    test('should have valid web configuration structure', () {
      const webOptions = DefaultFirebaseOptions.web;

      expect(webOptions.apiKey, isNotEmpty);
      expect(webOptions.appId, contains('web'));
      expect(webOptions.messagingSenderId, isNotEmpty);
      expect(webOptions.projectId, equals('netscope-ffd10'));
      expect(webOptions.authDomain, contains('firebaseapp.com'));
      expect(webOptions.storageBucket, contains('firebasestorage.app'));
      expect(webOptions.measurementId, startsWith('G-'));
    });

    test('should have valid android configuration structure', () {
      const androidOptions = DefaultFirebaseOptions.android;

      expect(androidOptions.apiKey, isNotEmpty);
      expect(androidOptions.appId, contains('android'));
      expect(androidOptions.messagingSenderId, isNotEmpty);
      expect(androidOptions.projectId, equals('netscope-ffd10'));
      expect(androidOptions.storageBucket, contains('firebasestorage.app'));
    });

    test('should have valid iOS configuration structure', () {
      const iosOptions = DefaultFirebaseOptions.ios;

      expect(iosOptions.apiKey, isNotEmpty);
      expect(iosOptions.appId, contains('ios'));
      expect(iosOptions.messagingSenderId, isNotEmpty);
      expect(iosOptions.projectId, equals('netscope-ffd10'));
      expect(iosOptions.storageBucket, contains('firebasestorage.app'));
      expect(iosOptions.iosClientId, contains('apps.googleusercontent.com'));
      expect(iosOptions.iosBundleId, equals('com.example.netscope'));
    });

    test('should have valid macOS configuration structure', () {
      const macosOptions = DefaultFirebaseOptions.macos;

      expect(macosOptions.apiKey, isNotEmpty);
      expect(macosOptions.appId, isNotEmpty);
      expect(macosOptions.messagingSenderId, isNotEmpty);
      expect(macosOptions.projectId, equals('netscope-ffd10'));
      expect(macosOptions.storageBucket, contains('firebasestorage.app'));
      expect(macosOptions.iosBundleId, equals('com.example.netscope'));
    });

    test('should have valid windows configuration structure', () {
      const windowsOptions = DefaultFirebaseOptions.windows;

      expect(windowsOptions.apiKey, isNotEmpty);
      expect(windowsOptions.appId, contains('web'));
      expect(windowsOptions.messagingSenderId, isNotEmpty);
      expect(windowsOptions.projectId, equals('netscope-ffd10'));
      expect(windowsOptions.authDomain, contains('firebaseapp.com'));
      expect(windowsOptions.storageBucket, contains('firebasestorage.app'));
      expect(windowsOptions.measurementId, startsWith('G-'));
    });

    test('should have consistent project configuration across platforms', () {
      const platforms = [
        DefaultFirebaseOptions.web,
        DefaultFirebaseOptions.android,
        DefaultFirebaseOptions.ios,
        DefaultFirebaseOptions.macos,
        DefaultFirebaseOptions.windows,
      ];

      // All platforms should have the same project ID and messaging sender ID
      for (final options in platforms) {
        expect(options.projectId, equals('netscope-ffd10'));
        expect(options.messagingSenderId, equals('331782302853'));
        expect(options.storageBucket,
            equals('netscope-ffd10.firebasestorage.app'));
      }
    });

    testWidgets('should throw UnsupportedError for Linux platform',
        (tester) async {
      // Mock the target platform to be Linux
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsA(isA<UnsupportedError>().having(
          (e) => e.message,
          'message',
          contains('DefaultFirebaseOptions have not been configured for linux'),
        )),
      );

      // Reset the override
      debugDefaultTargetPlatformOverride = null;
    });

    test('should return correct platform options for currentPlatform getter',
        () {
      // Test that currentPlatform returns a valid FirebaseOptions object
      final currentOptions = DefaultFirebaseOptions.currentPlatform;

      expect(currentOptions, isA<FirebaseOptions>());
      expect(currentOptions.projectId, equals('netscope-ffd10'));
      expect(currentOptions.messagingSenderId, isNotEmpty);
      expect(currentOptions.apiKey, isNotEmpty);
      expect(currentOptions.appId, isNotEmpty);
    });

    test('should validate all required fields are present and non-empty', () {
      const configurations = [
        DefaultFirebaseOptions.web,
        DefaultFirebaseOptions.android,
        DefaultFirebaseOptions.ios,
        DefaultFirebaseOptions.macos,
        DefaultFirebaseOptions.windows,
      ];

      for (final config in configurations) {
        expect(config.apiKey, isNotEmpty,
            reason: 'API key should not be empty');
        expect(config.appId, isNotEmpty, reason: 'App ID should not be empty');
        expect(config.messagingSenderId, isNotEmpty,
            reason: 'Messaging sender ID should not be empty');
        expect(config.projectId, isNotEmpty,
            reason: 'Project ID should not be empty');
        expect(config.storageBucket, isNotEmpty,
            reason: 'Storage bucket should not be empty');
      }
    });

    group('Mock Firebase Options for Testing', () {
      test('should provide mock web options for testing', () {
        const mockWeb = MockFirebaseOptions.web;

        expect(mockWeb.apiKey, equals('mock-web-api-key'));
        expect(mockWeb.projectId, equals('mock-project-id'));
        expect(mockWeb.appId, contains('web'));
        expect(mockWeb.measurementId, equals('G-MOCKWEBID'));
      });

      test('should provide mock android options for testing', () {
        const mockAndroid = MockFirebaseOptions.android;

        expect(mockAndroid.apiKey, equals('mock-android-api-key'));
        expect(mockAndroid.projectId, equals('mock-project-id'));
        expect(mockAndroid.appId, contains('android'));
      });

      test('should provide mock iOS options for testing', () {
        const mockIos = MockFirebaseOptions.ios;

        expect(mockIos.apiKey, equals('mock-ios-api-key'));
        expect(mockIos.projectId, equals('mock-project-id'));
        expect(mockIos.appId, contains('ios'));
        expect(mockIos.iosBundleId, equals('com.example.mockapp'));
      });
    });
  });
}
