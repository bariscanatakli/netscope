import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:netscope/screens/home/root_screen.dart';
import 'package:netscope/providers/auth_provider.dart' as app_auth;

// Fake Firebase User
class FakeUser extends Fake implements User {
  @override
  String get uid => 'test-uid';
}

// Fake AuthProvider
class FakeAuthProvider extends ChangeNotifier implements app_auth.AuthProvider {
  @override
  User? get user => FakeUser();

  @override
  List<String> get favorites => ['speedtest', 'traceroute'];

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
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('RootScreen displays BottomNavigationBar and pages', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<app_auth.AuthProvider>(
        create: (_) => FakeAuthProvider(),
        child: const MaterialApp(
          home: RootScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
