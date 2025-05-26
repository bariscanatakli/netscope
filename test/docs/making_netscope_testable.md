# Making NetScope More Testable

This guide provides recommendations for making the NetScope app more testable without requiring Firebase credentials during testing.

## Current Issues

1. **Direct Firebase dependencies**: Components directly access Firebase services
2. **Singleton usage**: Services are often accessed as singletons
3. **No dependency injection**: Hard to replace real services with mocks
4. **Complex widget tree**: Difficult to test individual components

## Recommended Changes

### 1. Create Service Interfaces

For each service, create an interface:

```dart
abstract class AuthServiceInterface {
  dynamic getCurrentUser();
  Future<void> signOut();
  // other methods...
}

// Implement the interface in your real service
class AuthService implements AuthServiceInterface {
  @override
  dynamic getCurrentUser() {
    // real implementation
  }
  
  @override
  Future<void> signOut() {
    // real implementation
  }
}
```

### 2. Implement Dependency Injection

Use constructors to inject dependencies:

```dart
// Before
class SpeedTestScreen extends StatefulWidget {
  @override
  _SpeedTestScreenState createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  final _authService = AuthService(); // Direct reference
}

// After
class SpeedTestScreen extends StatefulWidget {
  final AuthServiceInterface authService;
  
  const SpeedTestScreen({
    Key? key,
    required this.authService,
  }) : super(key: key);

  @override
  _SpeedTestScreenState createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  // Access via widget.authService
}
```

### 3. Create Service Providers

For app-wide services, use providers:

```dart
// Using Provider package
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthServiceInterface>(
          create: (_) => AuthService(), // Real implementation
        ),
        Provider<SpeedTestServiceInterface>(
          create: (_) => SpeedTestService(), 
        ),
      ],
      child: MaterialApp(...),
    );
  }
}
```

### 4. Use Factories for Testing

Create factory methods that return different implementations:

```dart
class ServiceFactory {
  static AuthServiceInterface createAuthService({bool isTest = false}) {
    if (isTest) {
      return MockAuthService();
    }
    return AuthService();
  }
}
```

### 5. Extract Firebase Logic from Widgets

Move all Firebase logic to service classes:

```dart
// Before - in widget
void _saveResults(SpeedTestResult result) {
  FirebaseFirestore.instance
      .collection('speed_tests')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .collection('results')
      .add(result.toJson());
}

// After - in service
Future<void> saveResults(SpeedTestResult result) async {
  final user = _authService.getCurrentUser();
  if (user != null) {
    await _firestoreService.collection('speed_tests')
        .doc(user.uid)
        .collection('results')
        .add(result.toJson());
  }
}
```

## Example Refactoring for SpeedTest Screen

### Step 1: Create Interfaces

```dart
// lib/services/interfaces/auth_service_interface.dart
abstract class AuthServiceInterface {
  dynamic getCurrentUser();
}

// lib/services/interfaces/speedtest_service_interface.dart
abstract class SpeedTestServiceInterface {
  Future<SpeedTestResult> runTest(void Function(TestProgress) onProgress);
}
```

### Step 2: Update Service Implementations

```dart
// lib/services/auth_service.dart
class AuthService implements AuthServiceInterface {
  @override
  dynamic getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}

// lib/services/speedtest_service.dart
class SpeedTestService implements SpeedTestServiceInterface {
  final AuthServiceInterface _authService;
  
  SpeedTestService({AuthServiceInterface? authService})
    : _authService = authService ?? AuthService();
    
  @override
  Future<SpeedTestResult> runTest(void Function(TestProgress) onProgress) async {
    // Implementation
  }
}
```

### Step 3: Update Widgets

```dart
// lib/screens/apps/speedtest/speedtest_screen.dart
class SpeedTestScreen extends StatefulWidget {
  final SpeedTestServiceInterface speedTestService;
  
  const SpeedTestScreen({
    Key? key,
    required this.speedTestService,
  }) : super(key: key);
  
  @override
  _SpeedTestScreenState createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen> {
  // Use widget.speedTestService instead of direct references
}
```

## Building a Mock-Ready App

By following these guidelines, you can gradually refactor the NetScope app to:

1. Be testable without Firebase credentials
2. Support proper unit testing of business logic
3. Allow for dependency injection of mock services
4. Make widgets more maintainable and decoupled

Remember to make these changes incrementally to avoid breaking existing functionality!
