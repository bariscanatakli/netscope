# NetScope SpeedTest Testing Implementation Guide

This guide provides step-by-step instructions for implementing tests for the SpeedTest module using the mock infrastructure we've created.

## Prerequisites

1. Make sure you have all dependencies installed:
```bash
flutter pub get
```

2. Understand the testing infrastructure:
   - Firebase mocks: `test/mocks/firebase_mocks.dart`
   - Service mocks: `test/setup.dart`
   - Example tests: `test/examples/` directory

## Testing Without Firebase

We've set up a testing framework that allows us to test the NetScope app without requiring Firebase credentials. This is achieved through:

1. **Mock Services**: Replace all Firebase-dependent services with mocks
2. **Mockable Widgets**: Example implementations that accept injected dependencies
3. **Test Data**: Pre-defined sample data for consistent testing

## Implementation Steps for Team Members

### 1. Unit Testing SpeedTest Services

Follow the pattern in `test/unit/enhanced_speedtest_service_test.dart`:

```dart
test('Your test name', () {
  // Arrange
  final mockService = MockSpeedTestService();
  
  // Act
  final result = mockService.someMethod();
  
  // Assert
  expect(result, expectedValue);
});
```

### 2. Widget Testing SpeedTest Screens

Follow the pattern in `test/widget/enhanced_speedtest_screen_test.dart`:

```dart
testWidgets('Your widget test name', (tester) async {
  // Arrange
  final mockAuth = MockAuthService();
  final mockFirestore = getMockFirestore(withSampleData: true);
  
  // Act
  await tester.pumpWidget(
    MaterialApp(
      home: YourWidgetWithInjectedMocks(
        authService: mockAuth,
        firestore: mockFirestore,
      ),
    ),
  );
  
  // Assert
  expect(find.text('Expected Text'), findsOneWidget);
});
```

### 3. Using Firebase Mocks

Our Firebase mocks provide ways to:
- Create authenticated or unauthenticated users
- Create Firestore instances with sample data
- Simulate SpeedTest operations

Example:
```dart
// Create authenticated mock
final mockAuth = getMockAuth(signedIn: true);

// Create Firestore with data
final mockFirestore = getMockFirestore(withSampleData: true);

// Access test data
final collection = mockFirestore.collection('speed_tests');
final userDoc = collection.doc('test-user-id');
final resultsCollection = userDoc.collection('results');
```

### 4. Creating New Tests

When creating new tests:

1. **Unit Tests**: Add to `test/unit/` following existing patterns
2. **Widget Tests**: Add to `test/widget/` following existing patterns
3. **Use Mocks**: Always inject mocks instead of using real Firebase
4. **Be Specific**: Test one feature at a time
5. **Clear Descriptions**: Use descriptive test names

## Refactoring Suggestions

For long-term testability, consider:

1. **Dependency Injection**: Modify real code to accept injected dependencies
2. **Service Interfaces**: Create interfaces for services to make mocking easier
3. **Factory Patterns**: Use factory patterns for creating services

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/enhanced_speedtest_service_test.dart

# Run with coverage
flutter test --coverage
```

## Troubleshooting

If you encounter issues:

1. **Firebase Initialization Errors**: Make sure you're using mocks, not real Firebase
2. **Widget Test Failures**: Check that your widget accepts injected dependencies
3. **Mock Data Issues**: Verify that your mock data matches what the widget expects
