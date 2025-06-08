import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:netscope/models/speedtest_models.dart';

// Mock User
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';
}

// Mock Auth
class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final MockUser _currentUser = MockUser();

  @override
  User? get currentUser => _currentUser;
}

// Mock Document Snapshot
class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;

  MockDocumentSnapshot(this._data);

  @override
  dynamic get(Object field) => _data[field as String];

  @override
  dynamic operator [](Object field) => _data[field as String];

  @override
  Map<String, dynamic>? data() =>
      _data; // Changed to nullable to match interface

  @override
  String get id => 'mock_doc_id'; // Added mock id

  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      MockDocumentReference(
          MockSpeedTestResultsStream([])); // Added mock reference

  @override
  bool get exists => true; // Added mock exists
}

// Mock QueryDocumentSnapshot extends DocumentSnapshot
class MockQueryDocumentSnapshot extends MockDocumentSnapshot
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  MockQueryDocumentSnapshot(Map<String, dynamic> data) : super(data);

  // Convert Datetime to Timestamp for Firestore compatibility
  @override
  dynamic operator [](Object field) {
    // Changed to Object
    if (field as String == 'timestamp' && super[field] is DateTime) {
      // Keep cast for super access if super uses String
      return Timestamp.fromDate(
          super[field] as DateTime); // Keep cast for super access
    }
    return super[field]; // Keep cast for super access
  }

  @override
  Map<String, dynamic> data() =>
      _data; // Override to be non-nullable as per QueryDocumentSnapshot
}

// Mock QuerySnapshot
class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs; // Typed list

  MockQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;

  @override
  List<DocumentChange<Map<String, dynamic>>> get docChanges =>
      []; // Added mock docChanges

  @override
  SnapshotMetadata get metadata =>
      MockSnapshotMetadata(); // Added mock metadata
}

class MockSnapshotMetadata extends Mock implements SnapshotMetadata {}

// Mock Stream of QuerySnapshot
class MockSpeedTestResultsStream extends Mock {
  final List<MockSpeedTestResultData> results;

  MockSpeedTestResultsStream(this.results);

  Stream<QuerySnapshot<Map<String, dynamic>>> get stream {
    // Typed Stream
    final mockDocs = results
        .map((result) => MockQueryDocumentSnapshot(result.toMap()))
        .toList();

    return Stream.value(MockQuerySnapshot(mockDocs));
  }
}

// Mock Firestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  final MockSpeedTestResultsStream _resultsStream;

  MockFirebaseFirestore(this._resultsStream);

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return MockCollectionReference(_resultsStream)
        as CollectionReference<Map<String, dynamic>>;
  }
}

// Mock CollectionReference
class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {
  final MockSpeedTestResultsStream _resultsStream;

  MockCollectionReference(this._resultsStream);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return MockDocumentReference(_resultsStream);
  }

  // Add other necessary overrides if CollectionReference<Map<String, dynamic>> requires them
  // For example, add, id, parent, path, etc. if they cause issues.
  // For now, keeping it minimal based on current usage.

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    return _resultsStream
        .stream; // No cast needed if stream is already correctly typed
  }

  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) {
    return MockQuery(_resultsStream);
  }
  // Add other methods like where, limit, etc., if needed by your tests
}

// Mock DocumentReference
class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {
  final MockSpeedTestResultsStream _resultsStream;

  MockDocumentReference(this._resultsStream);

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return MockResultsCollectionReference(_resultsStream);
  }

  // Add other necessary overrides if DocumentReference<Map<String, dynamic>> requires them
  @override
  String get id => 'mock_doc_ref_id';

  @override
  String get path => 'mock/path';

  @override
  FirebaseFirestore get firestore => MockFirebaseFirestore(_resultsStream);

  @override
  CollectionReference<Map<String, dynamic>> get parent =>
      MockCollectionReference(
          _resultsStream); // Corrected return type and provided a mock instance

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get(
      [GetOptions? options]) async {
    return MockDocumentSnapshot({});
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource, // Added source parameter
  }) {
    return Stream.value(MockDocumentSnapshot({}));
  }

  @override
  Future<void> delete() async {}

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {}

  @override
  Future<void> update(Map<Object, Object?> data) async {}
}

// Mock Results CollectionReference specifically for the results collection
class MockResultsCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {
  final MockSpeedTestResultsStream _resultsStream;

  MockResultsCollectionReference(this._resultsStream);

  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) {
    // Changed field to Object
    return MockQuery(_resultsStream);
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    return _resultsStream.stream; // No cast needed
  }

  // Add other necessary overrides if CollectionReference<Map<String, dynamic>> requires them
  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return MockDocumentReference(_resultsStream);
  }
}

// Mock Query
class MockQuery extends Mock implements Query<Map<String, dynamic>> {
  final MockSpeedTestResultsStream _resultsStream;

  MockQuery(this._resultsStream);

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    return _resultsStream.stream; // No cast needed
  }
  // Add other necessary overrides if Query<Map<String, dynamic>> requires them
}
