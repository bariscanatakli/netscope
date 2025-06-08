import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';

// Mock User for testing
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';
  
  @override
  String? get email => 'test@example.com';
  
  @override
  String? get displayName => 'Test User';
}

// Mock Auth interface for testing
class MockAuth extends Mock implements FirebaseAuth {
  final MockUser _currentUser = MockUser();
  
  @override
  User? get currentUser => _currentUser;
  
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return MockUserCredential() as UserCredential;
  }
  
  @override
  Future<void> signOut() async {}
}

// Mock Firestore for testing
class MockFirestore extends Mock implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return MockCollectionReference();
  }
}

// Mock Collection Reference
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return MockDocumentReference();
  }
}

// Mock Document Reference
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {
  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {}
  
  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return MockDocumentSnapshot();
  }
}

// Mock Document Snapshot
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {
  @override
  bool get exists => true;
  
  @override
  Map<String, dynamic>? data() => {
    'username': 'testuser',
    'email': 'test@example.com',
    'favorites': ['speedtest', 'traceroute'],
  };
}

// Mock User Credential
class MockUserCredential extends Mock implements UserCredential {
  @override
  User? get user => MockUser();
}

// Example of how to use these mocks in a test:
void exampleTest() {
  final mockAuth = MockAuth();
  final mockFirestore = MockFirestore();
  
  // Then inject these mocks into your widget or provider
  // For example:
  // await tester.pumpWidget(
  //   MaterialApp(
  //     home: Provider<FirebaseAuth>.value(
  //       value: mockAuth,
  //       child: YourWidget(),
  //     ),
  //   ),
  // );
}
