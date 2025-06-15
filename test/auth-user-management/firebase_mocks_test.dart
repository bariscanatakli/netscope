import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../mocks/firebase_mocks.dart';
import 'package:netscope/models/speedtest_models.dart';

void main() {
  group('Firebase Mocks', () {
    test('MockUser returns uid', () {
      final user = MockUser();
      expect(user.uid, 'test-user-id');
    });

    test('MockFirebaseAuth returns currentUser', () {
      final auth = MockFirebaseAuth();
      expect(auth.currentUser, isA<User>());
      expect(auth.currentUser!.uid, 'test-user-id');
    });

    test('MockDocumentSnapshot returns correct fields', () {
      final snapshot = MockDocumentSnapshot({
        'field1': 'value1',
        'field2': 42,
      });

      expect(snapshot['field1'], 'value1');
      expect(snapshot['field2'], 42);
      expect(snapshot.get('field1'), 'value1');
      expect(snapshot.exists, isTrue);
      expect(snapshot.id, 'mock_doc_id');
      expect(snapshot.reference, isA<DocumentReference>());
    });

    test('MockQuerySnapshot returns docs', () async {
      final result = MockSpeedTestResultData(
        downloadSpeed: 50,
        uploadSpeed: 20,
        ping: 12,
        timestamp: DateTime.now(),
      );

      final stream = MockSpeedTestResultsStream([result]);
      final snapshot = await stream.stream.first;

      expect(snapshot.docs, isNotEmpty);
      expect(snapshot.docs.first.data()['downloadSpeed'], 50);
    });

    test('MockDocumentReference supports get and set', () async {
      final stream = MockSpeedTestResultsStream([]);
      final docRef = MockDocumentReference(stream);

      await docRef.set({'key': 'value'});
      final snap = await docRef.get();

      expect(snap, isA<DocumentSnapshot>());
    });

    test('MockResultsCollectionReference returns a stream with data', () async {
      final result = MockSpeedTestResultData(
        downloadSpeed: 99,
        uploadSpeed: 88,
        ping: 12,
        timestamp: DateTime.now(),
      );

      final stream = MockSpeedTestResultsStream([result]);
      final collection = MockResultsCollectionReference(stream);

      final snapshot = await collection.snapshots().first;
      expect(snapshot.docs.length, 1);
      expect(snapshot.docs.first.data()['downloadSpeed'], 99);
    });

    test('MockQuery returns snapshots stream', () async {
      final result = MockSpeedTestResultData(
        downloadSpeed: 10,
        uploadSpeed: 5,
        ping: 12,
        timestamp: DateTime.now(),
      );

      final stream = MockSpeedTestResultsStream([result]);
      final query = MockQuery(stream);
      final snap = await query.snapshots().first;

      expect(snap.docs.first.data()['uploadSpeed'], 5);
    });
  });
}
