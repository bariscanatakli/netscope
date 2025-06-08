# NetScope Test Checklist

This document provides a comprehensive list of files to be tested by each team member, organized by module responsibility.

## 🔐 Mustafa Morsy – Authentication & User Management

| File                                             | Description                     | Status      | Coverage |
| ------------------------------------------------ | ------------------------------- | ----------- | -------- |
| `lib/main.dart`                                | App initialization and routing  | Not Started | 0%       |
| `lib/screens/auth/login_screen.dart`           | Login UI and validation         | Not Started | 0%       |
| `lib/screens/auth/signup_screen.dart`          | Registration UI and validation  | Not Started | 0%       |
| `lib/screens/auth/forgot_password_screen.dart` | Password recovery functionality | Not Started | 0%       |
| `lib/providers/auth_provider.dart`             | Authentication state management | Not Started | 0%       |
| `lib/screens/auth/auth_state_wrapper.dart`     | Auth state routing              | Not Started | 0%       |
| `lib/services/auth_service.dart`               | Firebase authentication methods | Not Started | 0%       |

## 🚀 Barış Can Ataklı – Speed Test & Results

| File                                                           | Description                    | Status      | Coverage |
| -------------------------------------------------------------- | ------------------------------ | ----------- | -------- |
| `lib/screens/apps/speedtest/speedtest_screen.dart`           | Speed test UI and control      | In Progress | 82.93%   |
| `lib/screens/apps/speedtest/speed_test_results_screen.dart`  | Results display                | In Progress | 94.74%   |
| `lib/screens/apps/speedtest/services/speedtest_service.dart` | Speed test implementation      | Not Started | 0%       |
| `lib/models/speedtest_models.dart`                           | Data models for speed test     | Complete    | 100%     |
| `test/widget/speedtest_screen_test.dart`                     | UI tests for speed test screen | In Progress | N/A      |
| `test/widget/speed_test_results_screen_test.dart`            | UI tests for results screen    | In Progress | N/A      |
| `integration_test/speedtest_results_integration_test.dart`   | Integration tests              | Not Started | N/A      |

## 🗺️ Bayram Gürbüz – Traceroute & Map Features

| File                                                                  | Description                       | Status      | Coverage |
| --------------------------------------------------------------------- | --------------------------------- | ----------- | -------- |
| `lib/screens/apps/traceroute/map/map_screen.dart`                   | Map visualization screen          | Not Started | 0.49%    |
| `lib/screens/apps/traceroute/map/map_tab.dart`                      | Map tab implementation            | Not Started | 0%       |
| `lib/screens/apps/traceroute/map/hops_tab.dart`                     | Network hops listing              | Not Started | 0%       |
| `lib/screens/apps/traceroute/map/details_tab.dart`                  | Detailed hop information          | Not Started | 0%       |
| `lib/screens/apps/traceroute/map/hop_details_screen.dart`           | Hop details page                  | Not Started | 0%       |
| `lib/screens/apps/traceroute/map/services/trace_route_service.dart` | Traceroute functionality          | Not Started | 0%       |
| `lib/models/traceroute_models.dart`                                 | Data models for traceroute        | Not Started | 0%       |
| `test/widget/traceroute_map_screen_test.dart`                       | UI tests for map screen           | Not Started | N/A      |
| `test/widget/hop_details_screen_test.dart`                          | UI tests for hop details          | Not Started | N/A      |
| `test/unit/trace_route_service_test.dart`                           | Unit tests for traceroute service | Not Started | N/A      |

## 🧩 Alaa Hosny Saber – Core Features & UI

| File                                       | Description                   | Status      | Coverage |
| ------------------------------------------ | ----------------------------- | ----------- | -------- |
| `lib/screens/home/home_page.dart`        | Main home screen              | In Progress | 84.62%   |
| `lib/screens/home/favorites_page.dart`   | Favorites management          | Not Started | 11.48%   |
| `lib/screens/home/profile_page.dart`     | User profile screen           | Not Started | 0%       |
| `lib/screens/home/root_screen.dart`      | Main navigation structure     | Not Started | 0%       |
| `lib/services/network_info_service.dart` | Network information retrieval | Not Started | 0%       |
| `lib/theme/theme_notifier.dart`          | Theme management              | Not Started | 0%       |
| `test/widget/home_page_test.dart`        | UI tests for home page        | In Progress | N/A      |
| `test/widget/favorites_page_test.dart`   | UI tests for favorites        | Not Started | N/A      |
| `test/widget/profile_page_test.dart`     | UI tests for profile          | Not Started | N/A      |

## Common Test Files

| File                               | Description                | Status      | Maintainer |
| ---------------------------------- | -------------------------- | ----------- | ---------- |
| `test/mocks/firebase_mocks.dart` | Firebase mocking utilities | In Progress | All Team   |

## Testing Guidance

1. **Unit Tests**: Focus on testing individual functions and methods in isolation

   - Create files in `test/unit/` directory
   - Example: `test/unit/auth_provider_test.dart`
2. **Widget Tests**: Test UI components and their interactions

   - Create files in `test/widget/` directory
   - Example: `test/widget/login_screen_test.dart`
3. **Integration Tests**: Test full user flows through the app

   - Create files in `integration_test/` directory
   - Example: `integration_test/login_flow_test.dart`
4. **Coverage Goals**

   - Authentication & User Management: 90%
   - Speed Test & Results: 95%
   - Traceroute & Map Features: 85%
   - Core Features & UI: 90%
5. **Important Commands**

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
./create_coverage_report.ps1
```
