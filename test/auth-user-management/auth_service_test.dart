import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:netscope/services/auth_service.dart';

import 'auth_mocks.mocks.dart'; // Make sure to generate this

// === Fake User and Credential ===

class FakeUserCredential implements UserCredential {
  @override
  User get user => FakeUser();

  @override
  AuthCredential? get credential => null;

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUser implements User {
  @override
  String get uid => 'fakeUid';

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockAccount;
  late MockGoogleSignInAuthentication mockAuthData;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockAccount = MockGoogleSignInAccount();
    mockAuthData = MockGoogleSignInAuthentication();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockDocSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();

    // Google Sign-In mocks
    when(mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
    when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockAccount);
    when(mockAccount.authentication).thenAnswer((_) async => mockAuthData);
    when(mockAuthData.accessToken).thenReturn('fake_access_token');
    when(mockAuthData.idToken).thenReturn('fake_id_token');

    // Match GoogleAuthProvider.credential by value
    when(mockAuth.signInWithCredential(argThat(
      isA<OAuthCredential>()
        .having((c) => c.accessToken, 'accessToken', 'fake_access_token')
        .having((c) => c.idToken, 'idToken', 'fake_id_token'),
    ))).thenAnswer((_) async => FakeUserCredential());

    // Firestore mocks
    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc('fakeUid')).thenReturn(mockDocRef);
    when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
    when(mockDocSnapshot.exists).thenReturn(false);

    // Match the set(Map<String, dynamic>) call by content
    when(mockDocRef.set(argThat(
      isA<Map<String, dynamic>>()
        .having((m) => m['email'], 'email', 'test@example.com')
        .having((m) => m['username'], 'username', 'Test User')
        .having((m) => m['createdAt'], 'createdAt', isA<Timestamp>()),
    ))).thenAnswer((_) async => null);
  });

  test('signInWithGoogle returns valid user credential and stores new user', () async {
    final authService = AuthService(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
      firestore: mockFirestore,
    );

    final result = await authService.signInWithGoogle();

    expect(result, isA<UserCredential>());
    expect(result.user?.uid, equals('fakeUid'));
    expect(result.user?.email, equals('test@example.com'));
    expect(result.user?.displayName, equals('Test User'));

    verify(mockDocRef.set(argThat(
      isA<Map<String, dynamic>>()
        .having((m) => m['email'], 'email', 'test@example.com')
        .having((m) => m['username'], 'username', 'Test User')
        .having((m) => m['createdAt'], 'createdAt', isA<Timestamp>()),
    ))).called(1);
  });
}