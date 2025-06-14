import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🏗 App imports
import 'package:netscope/screens/home/root_screen.dart';
import 'package:netscope/screens/home/home_page.dart';
import 'package:netscope/screens/home/favorites_page.dart';
import 'package:netscope/providers/auth_provider.dart' as app_auth;
import 'package:netscope/theme/theme_notifier.dart';

// ===== Mock AuthProvider =====
class MockAuthProvider extends Fake
    with ChangeNotifier
    implements app_auth.AuthProvider {
  
  @override
  User? get user => null; // No user logged in for tests
  
  @override
  List<String> get favorites => [];
  
  @override
  Future<void> fetchFavorites() async {
    // Mock implementation - do nothing
  }
  
  @override
  Future<void> addFavorite(String appId) async {
    // Mock implementation - do nothing
  }
  
  @override
  Future<void> removeFavorite(String appId) async {
    // Mock implementation - do nothing
  }
  
  @override
  Future<void> refreshUser() async {
    // Mock implementation - do nothing
  }
  
  @override
  Future<void> updateProfilePhoto(String photoUrl) async {
    // Mock implementation - do nothing
  }
}

// Simple mock login screen that doesn't use Firebase
class MockLoginScreen extends StatelessWidget {
  const MockLoginScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Mock Login Screen"),
      ),
    );
  }
}

// NavigatorObserver to track navigation events
class TestNavigatorObserver extends NavigatorObserver {
  List<Route<dynamic>> pushedRoutes = [];
  List<Route<dynamic>> poppedRoutes = [];
  List<Route<dynamic>> removedRoutes = [];
  List<Route<dynamic>> replacedRoutes = [];
  List<Route<dynamic>> replacementRoutes = [];
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
  }
  
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    removedRoutes.add(route);
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) replacementRoutes.add(newRoute);
    if (oldRoute != null) replacedRoutes.add(oldRoute);
  }
}
// ================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeNotifier themeNotifier;
  late app_auth.AuthProvider mockAuthProvider;
  late TestNavigatorObserver navigatorObserver;

  setUp(() {
    themeNotifier = ThemeNotifier();
    mockAuthProvider = MockAuthProvider();
    navigatorObserver = TestNavigatorObserver();
  });

  Widget wrapWithProviders({Widget? child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<app_auth.AuthProvider>.value(value: mockAuthProvider),
        ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),
      ],
      child: MaterialApp(
        navigatorObservers: [navigatorObserver],
        home: child ?? RootScreen(
          // Always provide the mock login screen builder for testing
          loginScreenBuilder: (context) => const MockLoginScreen(),
        ),
      ),
    );
  }

  group('RootScreen widget tests', () {
    testWidgets('starts on HomePage with correct nav labels', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      // Check navigation labels are present
      expect(find.text('Homepage'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Check that HomePage is displayed initially
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(FavoritesPage), findsNothing);
    });

    testWidgets('navigates to FavoritesPage when the heart icon is tapped', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      // Tap the favorites icon
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      // Verify FavoritesPage is displayed
      expect(find.byType(FavoritesPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
    });

    testWidgets('BottomNavigationBar is configured as expected', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.type, BottomNavigationBarType.fixed);
      expect(navBar.items.length, 3);
      
      // Check the icons are correct
      expect(navBar.items[0].icon, isA<Icon>());
      expect(navBar.items[1].icon, isA<Icon>());
      expect(navBar.items[2].icon, isA<Icon>());
      
      // Check the labels are correct
      expect(navBar.items[0].label, 'Homepage');
      expect(navBar.items[1].label, 'Favorites');
      expect(navBar.items[2].label, 'Profile');
    });

    testWidgets('can navigate back to HomePage from FavoritesPage', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      // Navigate to favorites
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(find.byType(FavoritesPage), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(FavoritesPage), findsNothing);
    });

    testWidgets('app bar contains correct title and action buttons', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      // Check app bar title
      expect(find.text('NetScope'), findsOneWidget);
      
      // Check action buttons exist
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.byIcon(Icons.brightness_6), findsOneWidget);
    });

    testWidgets('navigates to ProfilePage when the person icon is tapped', (tester) async {
      // Replace the ProfilePage with a mock widget for testing
      await tester.pumpWidget(
        wrapWithProviders(
          child: RootScreen(
            profilePageOverride: Container(
              key: const Key('mock_profile_page'),
              child: const Text('Mock Profile Page'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the profile icon
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Verify we navigated to the profile page
      expect(find.byKey(const Key('mock_profile_page')), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
      expect(find.byType(FavoritesPage), findsNothing);
    });

    testWidgets('theme toggle button changes theme', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      // Get initial theme mode
      final initialThemeMode = themeNotifier.currentTheme;

      // Tap the theme toggle button
      await tester.tap(find.byIcon(Icons.brightness_6));
      await tester.pumpAndSettle();

      // Verify theme mode changed
      expect(themeNotifier.currentTheme, isNot(initialThemeMode));
    });

    testWidgets('logout button triggers navigation and shows mock login screen', (tester) async {
      await tester.pumpWidget(wrapWithProviders());
      await tester.pumpAndSettle();

      // Tap the logout button
      await tester.tap(find.byIcon(Icons.logout));
      
      // Wait for animations
      await tester.pumpAndSettle();

      // Verify that our mock login screen is now visible
      expect(find.text("Mock Login Screen"), findsOneWidget);
      expect(find.byType(RootScreen), findsNothing);
    });
  });
}