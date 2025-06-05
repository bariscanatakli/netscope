// File: test/mocks/fake_auth_provider.dart

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../lib/providers/auth_provider.dart' as app_auth;

/// A "no-op" stand-in for the real AuthProvider.
/// By implementing AuthProvider directly, this class becomes a true subtype
/// of AuthProvider, so widget code (which does Provider.of<AuthProvider>) will accept it.
///
/// It never calls FirebaseAuth or Firestore; it just keeps an in-memory user and favorites list.
class FakeAuthProvider extends ChangeNotifier implements app_auth.AuthProvider {
  User? _user;
  List<String> _favorites = [];

  FakeAuthProvider({User? initialUser, List<String>? initialFavorites}) {
    _user = initialUser;
    _favorites = List<String>.from(initialFavorites ?? []);
  }

  /// Simulate login/logout in tests.
  void setUser(User? newUser) {
    _user = newUser;
    notifyListeners();
  }

  @override
  User? get user => _user;

  @override
  List<String> get favorites => List.unmodifiable(_favorites);

  @override
  Future<void> fetchFavorites() async {
    return;
  }

  @override
  Future<void> addFavorite(String appId) async {
    if (!_favorites.contains(appId)) {
      _favorites = List.from(_favorites)..add(appId);
      notifyListeners();
    }
  }

  @override
  Future<void> removeFavorite(String appId) async {
    if (_favorites.contains(appId)) {
      _favorites = List.from(_favorites)..remove(appId);
      notifyListeners();
    }
  }

  @override
  Future<void> refreshUser() async {
    return;
  }

  @override
  Future<void> updateProfilePhoto(String photoUrl) async {
    return;
  }
}