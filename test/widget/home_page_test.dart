// File: test/widget/home_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:netscope/screens/home/home_page.dart';
import 'package:netscope/providers/auth_provider.dart';

// A “fake” AuthProvider that lets us control favorites without hitting Firebase.
class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  List<String> _favorites = [];

  @override
  List<String> get favorites => _favorites;

  @override
  Future<void> refreshUser() async => null;

  @override
  Future<void> updateProfilePhoto(String photoUrl) async => null;

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
  void _listenToFavorites() => null;

  @override
  Future<void> fetchFavorites() async => null;

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async => null;
  @override
  Future<void> signUpWithEmailAndPassword(String email, String password, String username) async => null;
  @override
  Future<void> signOut() async => null;
  @override
  Future<void> sendPasswordResetEmail(String email) async => null;
  @override
  Future<void> updateUsername(String newUsername) async => null;
  @override
  Future<void> updateEmail(String newEmail) async => null;
  @override
  Future<void> updatePassword(String newPassword) async => null;
  @override
  Future<void> deleteAccount() async => null;
  @override
  Future<void> _listenToUserData() async => null;
  @override
  Future<void> createUserProfile(String username) async => null;
  @override
  Future<void> updateUserProfile(Map<String, dynamic> data) async => null;
  @override
  get user => null;
}

void main() {
  group('HomePage widget tests (Scanner tile + favorites)', () {
    late FakeAuthProvider fakeAuth;

    setUp(() {
      fakeAuth = FakeAuthProvider();
    });

    testWidgets('HomePage shows a “Scanner” tile with “In Progress” label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: fakeAuth,
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1) Find the "Scanner" title text
      final scannerTitleFinder = find.text('Scanner');
      expect(
        scannerTitleFinder,
        findsOneWidget,
        reason: 'There should be exactly one widget displaying “Scanner.”',
      );

      // 2) Locate the Column that holds both the title and the "In Progress" label
      final scannerColumnFinder = find.ancestor(
        of: scannerTitleFinder,
        matching: find.byType(Column),
      );
      expect(
        scannerColumnFinder,
        findsOneWidget,
        reason: 'The “Scanner” text should live inside a Column.',
      );

      // 3) Verify the "In Progress" text is a descendant of that same Column
      final inProgressFinder = find.descendant(
        of: scannerColumnFinder,
        matching: find.text('In Progress'),
      );
      expect(
        inProgressFinder,
        findsOneWidget,
        reason:
            'The “Scanner” tile should display an “In Progress” label underneath.',
      );

      // 4) Verify the icon rendered in that Column is Icons.scanner
      final scannerIconFinder = find.descendant(
        of: scannerColumnFinder,
        matching: find.byIcon(Icons.scanner),
      );
      expect(
        scannerIconFinder,
        findsOneWidget,
        reason: 'The “Scanner” tile should use Icons.scanner.',
      );
    });

    testWidgets(
        'Favorites icon for “Scanner” toggles between border and filled when tapped',
        (WidgetTester tester) async {
      // Initially, no favorites in fakeAuth.
      expect(fakeAuth.favorites.contains('networkscanner'), isFalse);

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: fakeAuth,
          child: const MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Locate the HomeTile (GestureDetector) that contains the 'Scanner' text.
      final scannerTile = find.ancestor(
        of: find.text('Scanner'),
        matching: find.byType(GestureDetector),
      );
      expect(
        scannerTile,
        findsOneWidget,
        reason:
            'There should be exactly one HomeTile (GestureDetector) whose title is “Scanner”.',
      );

      // Inside that HomeTile, find the icon button showing favorite_border first.
      final favoriteBorderIconFinder = find.descendant(
        of: scannerTile,
        matching: find.byIcon(Icons.favorite_border),
      );
      expect(
        favoriteBorderIconFinder,
        findsOneWidget,
        reason:
            'Initially, since “networkscanner” isn’t a favorite, the icon should be favorite_border.',
      );

      // Tap the border‐heart to add to favorites.
      await tester.tap(favoriteBorderIconFinder);
      await tester.pumpAndSettle();

      // Now fakeAuth.favorites should contain “networkscanner”.
      expect(
        fakeAuth.favorites.contains('networkscanner'),
        isTrue,
        reason: 'Tapping the border icon should call addFavorite.',
      );

      // The icon should rebuild to be Icons.favorite (filled).
      final favoriteFilledIconFinder = find.descendant(
        of: scannerTile,
        matching: find.byIcon(Icons.favorite),
      );
      expect(
        favoriteFilledIconFinder,
        findsOneWidget,
        reason: 'After adding to favorites, the icon should switch to filled.',
      );

      // Tap the filled heart to prompt for removal.
      await tester.tap(favoriteFilledIconFinder);
      await tester.pump(); // Show the AlertDialog

      // The AlertDialog’s title should be “Remove Favorite”.
      expect(
        find.text('Remove Favorite'),
        findsOneWidget,
        reason:
            'Tapping the filled heart should show a confirmation dialog titled “Remove Favorite”.',
      );

      // Press “Cancel” in the dialog.
      final cancelButton = find.widgetWithText(TextButton, 'Cancel');
      expect(cancelButton, findsOneWidget);
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      // Since we pressed cancel, “networkscanner” should remain in favorites.
      expect(
        fakeAuth.favorites.contains('networkscanner'),
        isTrue,
        reason:
            'After cancelling removal, “networkscanner” must still be in favorites.',
      );

      // Tap the filled heart again to remove, and now confirm “Remove”.
      await tester.tap(favoriteFilledIconFinder);
      await tester.pump(); // Show dialog again

      final removeButton = find.widgetWithText(TextButton, 'Remove');
      expect(removeButton, findsOneWidget);
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // Now the item should be removed from fakeAuth.favorites.
      expect(
        fakeAuth.favorites.contains('networkscanner'),
        isFalse,
        reason:
            'After confirming removal, “networkscanner” should no longer be in favorites.',
      );

      // The icon should have switched back to favorite_border.
      expect(
        find.descendant(
          of: scannerTile,
          matching: find.byIcon(Icons.favorite_border),
        ),
        findsOneWidget,
        reason:
            'After removal, the icon should revert to Icons.favorite_border.',
      );
    });
  });
}
