import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:netscope/screens/home/profile_page.dart';
import 'package:netscope/providers/auth_provider.dart' as app_auth;
import 'package:netscope/services/network_info_service.dart';
import 'package:netscope/services/storage_service.dart';

// Mock classes - must come after imports but before main()
@GenerateMocks([
  app_auth.AuthProvider,
  NetworkInfoService,
  StorageService,
  ImagePicker,
  User,
  UserInfo,
  UserCredential,
])
import 'profile_page_test.mocks.dart';

void main() {
  group('ProfilePage Widget Tests', () {
    late MockAuthProvider mockAuthProvider;
    late MockNetworkInfoService mockNetworkService;
    late MockStorageService mockStorageService;
    late MockImagePicker mockImagePicker;
    late MockUser mockUser;
    late MockUserInfo mockUserInfo;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
      mockNetworkService = MockNetworkInfoService();
      mockStorageService = MockStorageService();
      mockImagePicker = MockImagePicker();
      mockUser = MockUser();
      mockUserInfo = MockUserInfo();
      mockUserCredential = MockUserCredential();

      // Setup mock user properties
      when(mockUser.uid).thenReturn('test-uid');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.providerData).thenReturn([mockUserInfo]);
      when(mockUserInfo.providerId).thenReturn('password');

      // Setup mock user methods
      when(mockUser.updateDisplayName(any)).thenAnswer((_) async {});
      when(mockUser.reload()).thenAnswer((_) async {});
      when(mockUser.updatePassword(any)).thenAnswer((_) async {});
      when(mockUser.reauthenticateWithCredential(any))
          .thenAnswer((_) async => mockUserCredential);

      // Setup default mock responses
      when(mockAuthProvider.user).thenReturn(mockUser);
      when(mockNetworkService.getNetworkInfo()).thenAnswer(
        (_) async => {'ip': '192.168.1.1', 'connectionType': 'WiFi'},
      );
      when(mockStorageService.getProfileImage('test-uid')).thenAnswer(
        (_) async => null,
      );
      when(mockAuthProvider.updateProfilePhoto(any)).thenAnswer((_) async {});
      when(mockAuthProvider.refreshUser()).thenAnswer((_) async {});
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<app_auth.AuthProvider>.value(
          value: mockAuthProvider,
          child: ProfilePage(
            networkInfoService: mockNetworkService,
            storageService: mockStorageService,
            imagePicker: mockImagePicker,
          ),
        ),
      );
    }

    testWidgets('ProfilePage initial loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Check initial loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Check that ProfilePage elements are visible
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('Account Information'), findsOneWidget);
      expect(find.text('Network Information'), findsOneWidget);
    });

    testWidgets('Profile image display', (WidgetTester tester) async {
      when(mockStorageService.getProfileImage('test-uid')).thenAnswer(
        (_) async => 'https://example.com/profile.jpg',
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check that profile image is visible
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('Email display', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('Username editing functionality', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start editing username
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Check that TextField and save button are visible
      expect(find.byType(TextField), findsWidgets);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('Change password dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open password change dialog
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      // Check that dialog is open
      expect(find.text('Change Password'),
          findsNWidgets(2)); // Button + Dialog title
      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm New Password'), findsOneWidget);
    });

    testWidgets('Network information display', (WidgetTester tester) async {
      when(mockNetworkService.getNetworkInfo()).thenAnswer(
        (_) async => {'ip': '192.168.1.100', 'connectionType': 'Cellular'},
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('192.168.1.100'), findsOneWidget);
      expect(find.text('Cellular'), findsOneWidget);
    });

    testWidgets('No user state', (WidgetTester tester) async {
      when(mockAuthProvider.user).thenReturn(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should still show the page but with default values
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('No email'), findsOneWidget);
    });

    testWidgets('Google user cannot change password',
        (WidgetTester tester) async {
      final googleUserInfo = MockUserInfo();
      when(googleUserInfo.providerId).thenReturn('google.com');

      final googleUser = MockUser();
      when(googleUser.uid).thenReturn('test-uid');
      when(googleUser.email).thenReturn('test@example.com');
      when(googleUser.displayName).thenReturn('Test User');
      when(googleUser.providerData).thenReturn([googleUserInfo]);

      when(mockAuthProvider.user).thenReturn(googleUser);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Change Password option should not be visible for Google users
      expect(find.text('Change Password'), findsNothing);
    });

    testWidgets('Network error handling', (WidgetTester tester) async {
      when(mockNetworkService.getNetworkInfo()).thenThrow(
        Exception('Network error'),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show Unknown for network info
      expect(find.text('Unknown'), findsNWidgets(2)); // IP and connection type
    });

    testWidgets('Profile image upload cancellation',
        (WidgetTester tester) async {
      when(mockImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      )).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap camera icon
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Should handle cancellation gracefully (no snackbar)
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('Username save functionality', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start editing username
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Enter new username
      await tester.enterText(find.byType(TextField).first, 'newusername');
      await tester.pumpAndSettle();

      // Save username
      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      // Should exit edit mode
      expect(find.byIcon(Icons.save), findsNothing);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('Password change dialog cancel', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open password change dialog
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      // Cancel dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('Current Password'), findsNothing);
    });

    testWidgets('Storage error handling', (WidgetTester tester) async {
      when(mockStorageService.getProfileImage('test-uid')).thenThrow(
        Exception('Storage error'),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should still render the page
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('Account Information'), findsOneWidget);
    });

    testWidgets('Profile image upload error', (WidgetTester tester) async {
      // Mock XFile
      final xFile = XFile('test_image.jpg');
      when(mockImagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
      )).thenAnswer((_) async => xFile);

      when(mockStorageService.uploadProfileImage(any, any)).thenThrow(
        Exception('Upload failed'),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap camera icon
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      // Should handle upload error gracefully
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('Password change with correct credentials',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open password change dialog
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      // Fill in password fields
      await tester.enterText(find.byType(TextField).at(0), 'currentPassword');
      await tester.enterText(find.byType(TextField).at(1), 'newPassword');
      await tester.enterText(find.byType(TextField).at(2), 'newPassword');

      // Tap change button
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      // Verify the mock methods were called
      verify(mockUser.reauthenticateWithCredential(any)).called(1);
      verify(mockUser.updatePassword('newPassword')).called(1);
    });

    testWidgets('Password change with mismatched passwords',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open password change dialog
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      // Fill in password fields with mismatched new passwords
      await tester.enterText(find.byType(TextField).at(0), 'currentPassword');
      await tester.enterText(find.byType(TextField).at(1), 'newPassword');
      await tester.enterText(find.byType(TextField).at(2), 'differentPassword');

      // Tap change button
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();

      // Should show error message and not call auth methods
      verifyNever(mockUser.reauthenticateWithCredential(any));
      verifyNever(mockUser.updatePassword(any));
    });
  });

  group('ProfilePage Unit Tests', () {
    test('Network info loading', () async {
      final service = MockNetworkInfoService();
      when(service.getNetworkInfo()).thenAnswer(
        (_) async => {'ip': '127.0.0.1', 'connectionType': 'WiFi'},
      );

      final result = await service.getNetworkInfo();
      expect(result['ip'], '127.0.0.1');
      expect(result['connectionType'], 'WiFi');
    });

    test('Storage service profile image retrieval', () async {
      final service = MockStorageService();
      when(service.getProfileImage('test-uid')).thenAnswer(
        (_) async => 'https://example.com/profile.jpg',
      );

      final result = await service.getProfileImage('test-uid');
      expect(result, 'https://example.com/profile.jpg');
    });

    test('Storage service error handling', () async {
      final service = MockStorageService();
      when(service.getProfileImage('test-uid')).thenThrow(
        Exception('Storage error'),
      );

      expect(
        () => service.getProfileImage('test-uid'),
        throwsException,
      );
    });
  });
}
