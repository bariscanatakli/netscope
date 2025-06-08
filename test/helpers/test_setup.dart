import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseAuthMocks();
  setupFirestoreMocks();
}

void setupFirebaseAuthMocks() {
  const MethodChannel('plugins.flutter.io/firebase_auth')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Auth#registerIdTokenListener':
      case 'Auth#registerAuthStateListener':
      case 'Auth#signOut':
        return null;
      default:
        return null;
    }
  });
}

void setupFirestoreMocks() {
  const MethodChannel('plugins.flutter.io/cloud_firestore')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'Firestore#enableNetwork':
      case 'DocumentReference#set':
      case 'DocumentReference#update':
        return null;
      case 'DocumentReference#get':
        return {
          'data': {'username': 'TestUser'},
          'exists': true,
        };
      default:
        return null;
    }
  });
}

void setupImagePickerMocks() {
  const MethodChannel('plugins.flutter.io/image_picker')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'pickImage') {
      return null;
    }
    return null;
  });
}

void setupCachedNetworkImageMocks() {
  const MethodChannel('flutter/platform_views')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return null;
  });
}

void setupAllMocks() {
  setupFirebaseMocks();
  setupImagePickerMocks();
  setupCachedNetworkImageMocks();
}

class TestData {
  static const String testUserId = 'test-user-id';
  static const String testEmail = 'test@example.com';
  static const String testUsername = 'TestUser';
  static const String testImageUrl = 'https://example.com/profile.jpg';
  
  static Map<String, dynamic> networkInfo = {
    'ip': '192.168.1.1',
    'connectionType': 'WiFi',
  };
  
  static Map<String, dynamic> userDocument = {
    'username': testUsername,
    'email': testEmail,
    'profileImageUrl': testImageUrl,
  };
}

class ProfilePageMatchers {
  static Matcher hasProfileImage() => findsOneWidget;
  static Finder hasCameraButton() => find.byIcon(Icons.camera_alt);
  static Finder hasAccountSection() => find.text('Account Information');
  static Finder hasNetworkSection() => find.text('Network Information');
  static Finder hasChangePasswordButton() => find.text('Change Password');
}