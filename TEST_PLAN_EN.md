NetScope Test Plan – Enhanced Team Assignment

## 📅 Test Completion Target

**90% overall test coverage**

---

## 👥 Team Member Responsibilities

| 📦 Module                                  | 👤 Assignee         | 🎯 Target Coverage |
| ------------------------------------------ | ------------------- | ------------------ |
| **Authentication & User Management** | Mustafa Morsy       | 90%                |
| **Speed Test & Results**             | Barış Can Ataklı | 95%                |
| **Traceroute & Map Features**        | Bayram Gürbüz     | 85%                |
| **Core Features & Network Scanner**  | Alaa Hosny Saber    | 90%                |

    

---

## 🧾 Module Details & Test Plans

### 🔐 Mustafa Morsy – *Authentication & User Management*

**Target Files:**

- `login_screen.dart`
- `signup_screen.dart`
- `forgot_password_screen.dart`
- `auth_provider.dart`
- `auth_state_wrapper.dart`

**Critical Test Scenarios:**

- ✅ Successful login with valid credentials
- ✅ Failed login with invalid credentials
- ✅ User registration with email verification
- ✅ Password recovery flow
- ✅ Authentication persistence after app restarts
- ✅ Secured route protection via auth state

**Mock Strategy:**

- Utilize `MockFirebaseAuth` from `firebase_mocks.dart`
- Define test users with consistent, known credentials

---

### 🚀 Barış Can Ataklı – *Speed Test & Results*

**Target Files:**

- `speedtest_screen.dart`
- `speed_test_results_screen.dart`
- `speedtest_service.dart`
- `lib/screens/apps/pingtest/` (all files)

**Critical Test Scenarios:**

- ✅ Accurate measurement of download/upload speeds
- ✅ Reliable ping responsiveness & timeout detection
- ✅ Result storage with correct Firestore metadata
- ✅ Retrieval & display of historical test data
- ✅ Handling of different network states (WiFi, Cellular, Offline)
- ✅ Test cancellation functionality

**Mock Strategy:**

- Use `MockSpeedTestService` for stable test data
- Use `MockNetworkInfo` to simulate various connection types

---

### 🗺️ Bayram Gürbüz – *Traceroute & Map Features*

**Target Files:**

- `map_screen.dart`
- `map_tab.dart`
- `hops_tab.dart`
- `details_tab.dart`
- `hop_details_screen.dart`

**Critical Test Scenarios:**

- ✅ Execution and analysis of traceroute
- ✅ Google Map initialization with proper API keys
- ✅ Marker display for each network hop
- ✅ Path visualization from source to destination
- ✅ Accurate rendering of hop details
- ✅ Persistent storage of traceroute history

**Mock Strategy:**

- Implement `MockTracerouteService` for static hop data
- Utilize fake `GoogleMap` widget for map-related tests

---

### 🧩 Alaa Hosny Saber – *Core Features & Network Scanner*

**Target Files:**

- `home_page.dart`
- `favorites_page.dart`
- `profile_page.dart`
- `root_screen.dart`
- `network_info_service.dart`
- `lib/screens/apps/networkscanner/` (all files)

**Critical Test Scenarios:**

- ✅ Full app navigation flow & state transitions
- ✅ Light/Dark mode switching
- ✅ Persistent favorites management
- ✅ Display & update of user profile info
- ✅ Accurate network device scanning
- ✅ Cross-platform UI and behavior consistency

**Mock Strategy:**

- Create `MockNetworkScanner` for expected results
- Use `MockSharedPreferences` for theme & favorites persistence

---

## 🔝 Priority Testing Areas

1. **🔐 Authentication Flow** – Ensures secure user access
2. **📶 Speed Test Accuracy** – Core functional metric
3. **🗺️ Map Integration** – External API dependency & UI complexity
4. **🧭 App Navigation** – Impacts all user journeys

---

## ⚙️ Test Implementation Guidelines

- **File Organization:**

  - `test/unit/` – Unit tests
  - `test/widget/` – Widget/component tests
  - `test/integration/` – End-to-end/integration tests
- **Naming Convention:**Use `feature_name_test.dart` for clarity
- **Test Header Template:**

  ```dart
  /*
    Test File: auth_provider_test.dart
    Description: Tests for authentication logic and Firebase integration
    Author: Mustafa Morsy
    Dependencies: MockFirebaseAuth, flutter_test
  */
  ```
- **Coverage Reporting:**
  Run all tests with coverage:

  ```bash
  flutter test --coverage
  ```

---

## 🧰 Test Environment Setup

```bash
# Install dependencies
flutter pub get

# Navigate to root
cd d:\netscope

# Run all tests with coverage report
flutter test --coverage

# Run a specific test file
flutter test test/unit/auth_provider_test.dart
```

---

---

---

> **Note:** Maintain consistent coding style, add detailed comments, and avoid skipping error edge cases. Every test must assert meaningful outcomes.

---
