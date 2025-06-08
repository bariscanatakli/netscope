import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:netscope/screens/home/favorites_page.dart';
import 'package:netscope/providers/auth_provider.dart' as my_auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

// Fake User implementation
class FakeUser extends Fake implements User {
  @override
  String get uid => 'test-uid';
}

// Mock AuthProvider with no favorites
class MockAuthProvider extends ChangeNotifier implements my_auth.AuthProvider {
  @override
  User? get user => FakeUser();

  @override
  List<String> get favorites => [];

  @override
  Future<void> addFavorite(String appId) async {}

  @override
  Future<void> fetchFavorites() async {}

  @override
  Future<void> refreshUser() async {}

  @override
  Future<void> removeFavorite(String appId) async {}

  @override
  Future<void> updateProfilePhoto(String photoUrl) async {}
}

void main() {
  testWidgets('FavoritesPage renders correctly with empty favorites',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<my_auth.AuthProvider>(
        create: (_) => MockAuthProvider(),
        child: const MaterialApp(
          home: FavoritesPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // There should be no favorite cards
    expect(find.byType(Card), findsNothing);
  });
}
