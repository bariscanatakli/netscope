import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  Future<String?> getProfileImage(String userId) async {
    try {
      final ref =
          _storage.ref().child('users').child(userId).child('profile.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching profile image: $e');
      return null;
    }
  }

  Future<String> uploadProfileImage(String userId, File imageFile) async {
    try {
      final ref =
          _storage.ref().child('users').child(userId).child('profile.jpg');
      await ref.putFile(imageFile);

      // Clear old cache
      final url = await ref.getDownloadURL();
      await _cacheManager.removeFile(url);

      return url;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }
}
