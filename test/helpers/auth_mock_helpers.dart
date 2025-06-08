import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:netscope/providers/auth_provider.dart' as app;

// Create a test implementation of User that only implements what we need
class TestUser implements User {
  @override
  final String uid;

  TestUser({this.uid = 'test-uid'});

  // Implement the minimum required methods
  @override
  String? get displayName => 'Test User';

  @override
  String? get email => 'test@example.com';

  // Stub implementation for all other required methods
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Create a testable implementation of AuthProvider
class TestAuthProvider extends ChangeNotifier implements app.AuthProvider {
  User? _user;
  List<String> _favorites = [];

  TestAuthProvider({User? user, List<String>? favorites}) {
    _user = user;
    _favorites = favorites ?? [];
  }

  @override
  User? get user => _user;

  @override
  List<String> get favorites => _favorites;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _user = TestUser();
    notifyListeners();
  }

  @override
  Future<void> signUpWithEmailAndPassword(
      String email, String password, String username) async {
    _user = TestUser();
    notifyListeners();
  }

  @override
  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updateProfilePhoto(String photoUrl) async {
    notifyListeners();
  }

  @override
  Future<void> updateUsername(String newUsername) async {
    notifyListeners();
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    notifyListeners();
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    notifyListeners();
  }

  @override
  Future<void> deleteAccount() async {
    _user = null;
    notifyListeners();
  }

  @override
  Future<void> refreshUser() async {
    notifyListeners();
  }

  @override
  Future<void> addFavorite(String appId) async {
    if (!_favorites.contains(appId)) {
      _favorites.add(appId);
      notifyListeners();
    }
  }

  @override
  Future<void> removeFavorite(String appId) async {
    if (_favorites.contains(appId)) {
      _favorites.remove(appId);
      notifyListeners();
    }
  }

  @override
  Future<void> fetchFavorites() async {
    // In a real app, this would fetch from Firestore
    notifyListeners();
  }
}
