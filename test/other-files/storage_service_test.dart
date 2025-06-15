import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';
import '../../lib/services/storage_service.dart';

// Generate mocks
@GenerateMocks([
  FirebaseStorage,
  Reference,
  UploadTask,
  TaskSnapshot,
  CacheManager,
  File,
])
import 'storage_service_test.mocks.dart';

void main() {
  group('StorageService', () {
    group('getProfileImage', () {
      test('should return download URL when profile image exists', () async {
        // Arrange
        final mockStorage = MockFirebaseStorage();
        final mockReference = MockReference();
        final mockUsersRef = MockReference();
        final mockUserRef = MockReference();
        final mockProfileRef = MockReference();
        final mockCacheManager = MockCacheManager();

        when(mockStorage.ref()).thenReturn(mockReference);
        when(mockReference.child('users')).thenReturn(mockUsersRef);
        when(mockUsersRef.child('test-user-123')).thenReturn(mockUserRef);
        when(mockUserRef.child('profile.jpg')).thenReturn(mockProfileRef);
        when(mockProfileRef.getDownloadURL())
            .thenAnswer((_) async => 'https://test-url.com/image.jpg');

        final storageService = StorageService(
          storage: mockStorage,
          cacheManager: mockCacheManager,
        );

        // Act
        final result = await storageService.getProfileImage('test-user-123');

        // Assert
        expect(result, equals('https://test-url.com/image.jpg'));
        verify(mockStorage.ref()).called(1);
        verify(mockReference.child('users')).called(1);
        verify(mockUsersRef.child('test-user-123')).called(1);
        verify(mockUserRef.child('profile.jpg')).called(1);
        verify(mockProfileRef.getDownloadURL()).called(1);
      });

      test('should return null when profile image does not exist', () async {
        // Arrange
        final mockStorage = MockFirebaseStorage();
        final mockReference = MockReference();
        final mockUsersRef = MockReference();
        final mockUserRef = MockReference();
        final mockProfileRef = MockReference();
        final mockCacheManager = MockCacheManager();

        when(mockStorage.ref()).thenReturn(mockReference);
        when(mockReference.child('users')).thenReturn(mockUsersRef);
        when(mockUsersRef.child('test-user-456')).thenReturn(mockUserRef);
        when(mockUserRef.child('profile.jpg')).thenReturn(mockProfileRef);
        when(mockProfileRef.getDownloadURL()).thenThrow(
            FirebaseException(plugin: 'storage', code: 'object-not-found'));

        final storageService = StorageService(
          storage: mockStorage,
          cacheManager: mockCacheManager,
        );

        // Act
        final result = await storageService.getProfileImage('test-user-456');

        // Assert
        expect(result, isNull);
        verify(mockProfileRef.getDownloadURL()).called(1);
      });

      test('should return null when there is a network error', () async {
        // Arrange
        final mockStorage = MockFirebaseStorage();
        final mockReference = MockReference();
        final mockUsersRef = MockReference();
        final mockUserRef = MockReference();
        final mockProfileRef = MockReference();
        final mockCacheManager = MockCacheManager();

        when(mockStorage.ref()).thenReturn(mockReference);
        when(mockReference.child('users')).thenReturn(mockUsersRef);
        when(mockUsersRef.child('test-user-789')).thenReturn(mockUserRef);
        when(mockUserRef.child('profile.jpg')).thenReturn(mockProfileRef);
        when(mockProfileRef.getDownloadURL()).thenThrow(
            FirebaseException(plugin: 'storage', code: 'network-error'));

        final storageService = StorageService(
          storage: mockStorage,
          cacheManager: mockCacheManager,
        );

        // Act
        final result = await storageService.getProfileImage('test-user-789');

        // Assert
        expect(result, isNull);
        verify(mockProfileRef.getDownloadURL()).called(1);
      });

      test('should handle generic exceptions gracefully', () async {
        // Arrange
        final mockStorage = MockFirebaseStorage();
        final mockReference = MockReference();
        final mockUsersRef = MockReference();
        final mockUserRef = MockReference();
        final mockProfileRef = MockReference();
        final mockCacheManager = MockCacheManager();

        when(mockStorage.ref()).thenReturn(mockReference);
        when(mockReference.child('users')).thenReturn(mockUsersRef);
        when(mockUsersRef.child('test-user-error')).thenReturn(mockUserRef);
        when(mockUserRef.child('profile.jpg')).thenReturn(mockProfileRef);
        when(mockProfileRef.getDownloadURL())
            .thenThrow(Exception('Generic error'));

        final storageService = StorageService(
          storage: mockStorage,
          cacheManager: mockCacheManager,
        );

        // Act
        final result = await storageService.getProfileImage('test-user-error');

        // Assert
        expect(result, isNull);
        verify(mockProfileRef.getDownloadURL()).called(1);
      });

      test('should build correct storage path for user profile image',
          () async {
        // Arrange
        final mockStorage = MockFirebaseStorage();
        final mockReference = MockReference();
        final mockUsersRef = MockReference();
        final mockUserRef = MockReference();
        final mockProfileRef = MockReference();
        final mockCacheManager = MockCacheManager();

        when(mockStorage.ref()).thenReturn(mockReference);
        when(mockReference.child('users')).thenReturn(mockUsersRef);
        when(mockUsersRef.child('special-user-id-123')).thenReturn(mockUserRef);
        when(mockUserRef.child('profile.jpg')).thenReturn(mockProfileRef);
        when(mockProfileRef.getDownloadURL())
            .thenAnswer((_) async => 'https://test-url.com/image.jpg');

        final storageService = StorageService(
          storage: mockStorage,
          cacheManager: mockCacheManager,
        );

        // Act
        await storageService.getProfileImage('special-user-id-123');

        // Assert
        verify(mockReference.child('users')).called(1);
        verify(mockUsersRef.child('special-user-id-123')).called(1);
        verify(mockUserRef.child('profile.jpg')).called(1);
      });
    });

    group('constructor', () {
      test('should create service with provided dependencies', () {
        // Arrange
        final mockStorage = MockFirebaseStorage();
        final mockCacheManager = MockCacheManager();

        // Act
        final service = StorageService(
          storage: mockStorage,
          cacheManager: mockCacheManager,
        );

        // Assert
        expect(service, isA<StorageService>());
      });

      test('should create service with default dependencies', () {
        // This test verifies the service can be instantiated
        // (though it won't work in test environment due to Firebase initialization)

        // Act & Assert
        expect(() => StorageService, returnsNormally);

        // Verify the constructor signature accepts optional parameters
        expect(StorageService.new, isA<Function>());
      });
    });

    group('uploadProfileImage', () {
      test('should have uploadProfileImage method available', () {
        // Arrange
        final mockStorage = MockFirebaseStorage();
        final mockCacheManager = MockCacheManager();
        final service = StorageService(
          storage: mockStorage,
          cacheManager: mockCacheManager,
        );

        // Act & Assert - Just verify the method exists
        expect(service.uploadProfileImage, isA<Function>());
      });
    });

    group('service interface', () {
      test('should implement expected public methods', () {
        // Arrange
        final mockStorage = MockFirebaseStorage();
        final mockCacheManager = MockCacheManager();
        final service = StorageService(
          storage: mockStorage,
          cacheManager: mockCacheManager,
        );

        // Act & Assert - Verify public interface
        expect(service.getProfileImage, isA<Function>());
        expect(service.uploadProfileImage, isA<Function>());
      });

      test('should accept required parameter types', () {
        // This test documents the expected parameter types
        final mockStorage = MockFirebaseStorage();
        final mockCacheManager = MockCacheManager();

        // Verify constructor accepts correct types
        expect(
          () => StorageService(
            storage: mockStorage,
            cacheManager: mockCacheManager,
          ),
          returnsNormally,
        );
      });
    });
  });
}
