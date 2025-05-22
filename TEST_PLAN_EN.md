# NetScope Test Plan: Team Assignment

This document ensures that testing tasks are distributed equally among 4 team members, with clear responsibilities for each.

## Team Member 1: Authentication & User Management
**Files to test:**
- lib/screens/auth/login_screen.dart
- lib/screens/auth/signup_screen.dart
- lib/screens/auth/forgot_password_screen.dart
- lib/providers/auth_provider.dart
- lib/widgets/auth_state_wrapper.dart

**Scope:**
- User registration flow
- Login functionality
- Password recovery
- User profile data storage/retrieval
- Authentication state persistence
- Firebase authentication integration

## Team Member 2: Speed Test & Results
**Files to test:**
- lib/screens/apps/speedtest/speedtest_screen.dart
- lib/screens/apps/speedtest/speed_test_results_screen.dart
- lib/screens/apps/speedtest/services/speedtest_service.dart
- lib/screens/apps/pingtest/ (all files)

**Scope:**
- Download/upload speed measurement
- Ping test functionality
- Test results storage in Firestore
- Display of historical speed test results
- Network performance metrics accuracy
- Speed test cancellation and error handling

## Team Member 3: Traceroute & Map Features
**Files to test:**
- lib/screens/apps/traceroute/map/map_screen.dart
- lib/screens/apps/traceroute/map/map_tab.dart
- lib/screens/apps/traceroute/map/hops_tab.dart
- lib/screens/apps/traceroute/map/details_tab.dart
- lib/screens/apps/traceroute/map/hop_details_screen.dart

**Scope:**
- Traceroute execution and visualization
- Google Maps integration
- Hop navigation and display
- Geolocation data mapping
- Traceroute history storage/retrieval
- Network topology visualization

## Team Member 4: Core Features & Network Scanner
**Files to test:**
- lib/screens/home/home_page.dart
- lib/screens/home/favorites_page.dart
- lib/screens/home/profile_page.dart
- lib/screens/home/root_screen.dart
- lib/services/network_info_service.dart
- lib/screens/apps/networkscanner/ (all files)

**Scope:**
- Navigation and routing between screens
- Theme switching functionality
- Favorites system (add/remove favorites)
- User profile data display
- Network information gathering
- Network scanner tool functionality
- Cross-platform behavior testing

## Test Types for Each Area
- Unit Tests
- Widget Tests
- Integration Tests
- End-to-End Tests

## Test Environment Setup
- Common mock services are defined in test/setup.dart.
- Use the command `flutter test` to run tests.

---

Each team member should write tests for their assigned files using the provided test folder structure.
