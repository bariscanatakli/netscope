import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<String> _favorites = [];

  User? get user => _user;
  List<String> get favorites => _favorites;

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _listenToFavorites();
      }
      notifyListeners();
    });
  }

  void _listenToFavorites() {
    if (_user == null) return;
    _firestore.collection('users').doc(_user!.uid).snapshots().listen((doc) {
      if (doc.exists) {
        _favorites = List<String>.from(doc.data()?['favorites'] ?? []);
        notifyListeners();
      }
    });
  }

  Future<void> fetchFavorites() async {
    if (_user == null) return;
    final doc = await _firestore.collection('users').doc(_user!.uid).get();
    if (doc.exists) {
      _favorites = List<String>.from(doc.data()?['favorites'] ?? []);
      notifyListeners();
    }
  }

  Future<void> addFavorite(String appId) async {
    if (_user == null) return;
    _favorites.add(appId);
    notifyListeners();
    await _firestore.collection('users').doc(_user!.uid).update({
      'favorites': _favorites,
    });
  }

  Future<void> removeFavorite(String appId) async {
    if (_user == null) return;
    _favorites.remove(appId);
    notifyListeners();
    await _firestore.collection('users').doc(_user!.uid).update({
      'favorites': _favorites,
    });
  }

  Future<void> refreshUser() async {
    _user = _auth.currentUser;
    notifyListeners();
  }

  Future<void> updateProfilePhoto(String photoUrl) async {
    try {
      await _auth.currentUser?.updatePhotoURL(photoUrl);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile photo: $e');
    }
  }
}
