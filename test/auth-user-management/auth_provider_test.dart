import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:netscope/providers/auth_provider.dart' as my_auth;

import 'auth_mocks.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockUser mockUser;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDoc;
  late my_auth.AuthProvider provider;

  setUp(() {
    // Mocks
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockUser();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockDoc = MockDocumentSnapshot<Map<String, dynamic>>();

    // Stub FirebaseAuth
    when(mockUser.uid).thenReturn('test_uid');
    when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.value(mockUser));
    when(mockAuth.currentUser).thenReturn(mockUser);

    // Stub Firestore
    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc('test_uid')).thenReturn(mockDocRef);
    when(mockDocRef.snapshots()).thenAnswer((_) => const Stream.empty());

    // Now create the provider after stubs
    provider = my_auth.AuthProvider(auth: mockAuth, firestore: mockFirestore);
  });

  test('fetchFavorites gets data and sets favorites', () async {
    when(mockDocRef.get()).thenAnswer((_) async => mockDoc);
    when(mockDoc.exists).thenReturn(true);
    when(mockDoc.data()).thenReturn({'favorites': ['a', 'b']});

    await provider.fetchFavorites();
    expect(provider.favorites, ['a', 'b']);
  });

  test('addFavorite adds and updates firestore', () async {
    when(mockDocRef.update(any)).thenAnswer((_) async => {});
    await provider.addFavorite('xyz');
    expect(provider.favorites, contains('xyz'));
  });

  test('removeFavorite removes and updates firestore', () async {
    provider.favorites.addAll(['abc', 'xyz']);
    when(mockDocRef.update(any)).thenAnswer((_) async => {});
    await provider.removeFavorite('abc');
    expect(provider.favorites, isNot(contains('abc')));
  });

  test('refreshUser updates the user', () async {
    when(mockAuth.currentUser).thenReturn(mockUser);
    await provider.refreshUser();
    expect(provider.user, equals(mockUser));
  });

  test('updateProfilePhoto succeeds', () async {
    when(mockUser.updatePhotoURL(any)).thenAnswer((_) async {});
    when(mockAuth.currentUser).thenReturn(mockUser);
    await provider.updateProfilePhoto('http://photo.url');
    verify(mockUser.updatePhotoURL('http://photo.url')).called(1);
  });

  test('updateProfilePhoto throws on failure', () async {
    when(mockUser.updatePhotoURL(any)).thenThrow(Exception('fail'));
    when(mockAuth.currentUser).thenReturn(mockUser);
    expect(() => provider.updateProfilePhoto('url'), throwsException);
  });
}
