// This file contains the Firebase mock setup for testing
// It's ready to use for mock testing Firebase functionality

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:netscope/models/speedtest_models.dart';

// Mocking Firebase Auth
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;

  MockUser({
    required this.uid,
    this.email,
    this.displayName,
  });
}

class MockFirebaseAuth {
  final bool signedIn;
  final MockUser? mockUser;

  MockFirebaseAuth({
    this.signedIn = false,
    this.mockUser,
  });

  MockUser? get currentUser => signedIn ? mockUser : null;

  MockUser? getCurrentUser() => currentUser;

  Future<void> signOut() async {
    // Mock implementation
    return;
  }

  Stream<MockUser?> authStateChanges() {
    return Stream.value(currentUser);
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Mock implementation
    return;
  }
}

// Mocking Firestore
class MockDocumentSnapshot {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._data);

  Map<String, dynamic> data() => _data;
  String get id => _data['id'] ?? 'mock-doc-id';
}

class MockQueryDocumentSnapshot extends MockDocumentSnapshot {
  MockQueryDocumentSnapshot(Map<String, dynamic> data) : super(data);
}

class MockQuerySnapshot {
  final List<MockQueryDocumentSnapshot> _docs;

  MockQuerySnapshot(this._docs);

  List<MockQueryDocumentSnapshot> get docs => _docs;
  bool get empty => _docs.isEmpty;
}

class MockDocumentReference {
  final Map<String, dynamic> _data;
  final String path;

  MockDocumentReference(this.path, [Map<String, dynamic>? data])
      : _data = data ?? {};

  Future<void> set(Map<String, dynamic> data) async {
    _data.addAll(data);
  }

  Future<MockDocumentSnapshot> get() async {
    return MockDocumentSnapshot(_data);
  }

  MockCollectionReference collection(String path) {
    return MockCollectionReference('$this.path/$path');
  }
}

class MockCollectionReference {
  final String path;
  final List<Map<String, dynamic>> _docs = [];

  MockCollectionReference(this.path);

  MockDocumentReference doc(String id) {
    // Check if document exists
    final existing = _docs.where((doc) => doc['id'] == id).toList();
    if (existing.isNotEmpty) {
      return MockDocumentReference('$path/$id', existing.first);
    }
    // Create new document
    final newDoc = {'id': id};
    _docs.add(newDoc);
    return MockDocumentReference('$path/$id', newDoc);
  }

  Future<void> add(Map<String, dynamic> data) async {
    final id = 'auto-id-${_docs.length}';
    data['id'] = id;
    _docs.add(data);
  }

  Future<MockQuerySnapshot> get() async {
    final snapshots =
        _docs.map((doc) => MockQueryDocumentSnapshot(doc)).toList();
    return MockQuerySnapshot(snapshots);
  }
}

class MockFirestore {
  final Map<String, MockCollectionReference> _collections = {};

  MockCollectionReference collection(String path) {
    if (!_collections.containsKey(path)) {
      _collections[path] = MockCollectionReference(path);
    }
    return _collections[path]!;
  }
}

// Helper functions to quickly setup mocks

// Creates a mock Firebase Auth with optional signed-in user
MockFirebaseAuth getMockAuth(
    {bool signedIn = true, String? uid, String? email}) {
  final user = MockUser(
    uid: uid ?? 'test-user-id',
    email: email ?? 'test@example.com',
    displayName: 'Test User',
  );

  return MockFirebaseAuth(
    signedIn: signedIn,
    mockUser: user,
  );
}

// Creates a mock Firestore with sample speed test data
MockFirestore getMockFirestore({bool withSampleData = false}) {
  final firestore = MockFirestore();

  if (withSampleData) {
    final collection = firestore.collection('speed_tests');
    final userDoc = collection.doc('test-user-id');
    final resultsCollection = userDoc.collection('results');

    // Add sample results
    resultsCollection.add({
      'downloadSpeed': 75.2,
      'uploadSpeed': 22.5,
      'ping': 12,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    resultsCollection.add({
      'downloadSpeed': 65.8,
      'uploadSpeed': 20.3,
      'ping': 15,
      'timestamp': DateTime.now()
          .subtract(const Duration(days: 1))
          .millisecondsSinceEpoch,
    });
  }

  return firestore;
}

// Note: SpeedTest mocking functionality has been moved to setup.dart
