import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:netscope/screens/auth/auth_state_wrapper.dart';
import 'package:netscope/providers/auth_provider.dart';

/// Fake provider that mimics only what's needed for testing `AuthStateWrapper`.
class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  final dynamic mockUser;
  FakeAuthProvider(this.mockUser);

  @override
  get user => mockUser;

  @override
  get auth => throw UnimplementedError();

  @override
  get firestore => throw UnimplementedError();

  @override
  List<String> get favorites => [];

  @override
  Future<void> addFavorite(String appId) async {}

  @override
  Future<void> removeFavorite(String appId) async {}

  @override
  Future<void> fetchFavorites() async {}

  @override
  Future<void> refreshUser() async {}

  @override
  Future<void> updateProfilePhoto(String photoUrl) async {}
}

/// A simple fake screen for login.
class FakeLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text('FakeLogin');
  }
}

/// A simple fake screen for the root/home.
class FakeRootScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text('FakeRoot');
  }
}

void main() {
  group('AuthStateWrapper Widget', () {
    testWidgets('shows LoginScreen when user is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: FakeAuthProvider(null),
          child: MaterialApp(
            home: AuthStateWrapper(
              loginScreenOverride: FakeLoginScreen(),
              rootScreenOverride: FakeRootScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('FakeLogin'), findsOneWidget);
      expect(find.text('FakeRoot'), findsNothing);
    });

    testWidgets('shows RootScreen when user is not null', (WidgetTester tester) async {
      final dummyUser = 'mock-user';

      await tester.pumpWidget(
        ChangeNotifierProvider<AuthProvider>.value(
          value: FakeAuthProvider(dummyUser),
          child: MaterialApp(
            home: AuthStateWrapper(
              loginScreenOverride: FakeLoginScreen(),
              rootScreenOverride: FakeRootScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('FakeRoot'), findsOneWidget);
      expect(find.text('FakeLogin'), findsNothing);
    });
  });
}
