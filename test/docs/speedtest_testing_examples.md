# SpeedTest Testing Examples

This document provides practical examples for testing the SpeedTest module.

## Unit Testing Examples

### Testing the SpeedTestResult Model

```dart
test('SpeedTestResult should store values correctly', () {
  final result = SpeedTestResult(
    downloadSpeed: 75.0,
    uploadSpeed: 25.0,
    ping: 15,
  );
  
  expect(result.downloadSpeed, 75.0);
  expect(result.uploadSpeed, 25.0);
  expect(result.ping, 15);
});
```

### Testing the SpeedTest Service

```dart
test('SpeedTest service should process results correctly', () {
  final service = SpeedTestService();
  
  // This is a simple test that doesn't require network
  // For real tests you would mock the HTTP client
  
  final testData = [100, 200, 300, 400, 500]; // Sample data points
  final average = service.calculateAverage(testData);
  
  expect(average, 300);
});
```

## Widget Testing Examples

### Testing SpeedTest Screen UI Elements

```dart
testWidgets('SpeedTest screen should show correct UI elements', (tester) async {
  await tester.pumpWidget(MaterialApp(home: SpeedTestScreen()));
  
  // Find important widgets
  expect(find.text('Speed Test'), findsOneWidget);
  expect(find.text('Start Test'), findsOneWidget);
  expect(find.byType(SfRadialGauge), findsOneWidget);
  
  // Check if initial state is correct
  expect(find.text('0.0 Mbps'), findsOneWidget); // Initial speed display
});
```

### Testing the Start Test Button

```dart
testWidgets('Tapping Start Test should begin test', (tester) async {
  // This example requires mocking the SpeedTest service
  final mockService = MockSpeedTestService();
  
  await tester.pumpWidget(MaterialApp(
    home: SpeedTestScreen(speedTestService: mockService),
  ));
  
  // Find and tap button
  await tester.tap(find.text('Start Test'));
  await tester.pump();
  
  // Verify test started
  expect(find.text('Starting test...'), findsOneWidget);
});
```

## Firebase Mock Testing Examples

```dart
testWidgets('Should save results to Firestore when authenticated', (tester) async {
  // Setup Firebase mocks
  final mockAuth = MockFirebaseAuth(signedIn: true);
  final mockFirestore = FakeFirebaseFirestore();
  
  await tester.pumpWidget(MaterialApp(
    home: Provider.value(
      value: mockAuth,
      child: Provider.value(
        value: mockFirestore,
        child: SpeedTestScreen(),
      ),
    ),
  ));
  
  // Complete a test
  await tester.tap(find.text('Start Test'));
  
  // Fast forward time to complete the test
  await tester.pump(const Duration(seconds: 5));
  
  // Verify results were saved to Firestore
  final docs = await mockFirestore
      .collection('speed_tests')
      .doc(mockAuth.currentUser!.uid)
      .collection('results')
      .get();
      
  expect(docs.docs.isNotEmpty, true);
});
```

## Integration Testing Examples

```dart
testWidgets('Full SpeedTest workflow test', (tester) async {
  // Setup mocks
  final mockAuth = MockFirebaseAuth(signedIn: true);
  final mockFirestore = FakeFirebaseFirestore();
  final mockSpeedTest = MockSpeedTestService();
  
  // Configure mock to return specific results
  when(mockSpeedTest.runTest(any)).thenAnswer((_) async {
    return SpeedTestResult(downloadSpeed: 75.0, uploadSpeed: 25.0, ping: 15);
  });
  
  await tester.pumpWidget(MaterialApp(
    home: Provider.value(
      value: mockAuth,
      child: Provider.value(
        value: mockFirestore,
        child: SpeedTestScreen(speedTestService: mockSpeedTest),
      ),
    ),
  ));
  
  // Run through full test flow
  await tester.tap(find.text('Start Test'));
  await tester.pump();
  
  // Verify progress shows
  expect(find.byType(LinearProgressIndicator), findsOneWidget);
  
  // Complete test
  await tester.pump(const Duration(seconds: 3));
  
  // Verify results
  expect(find.text('Download: 75.0 Mbps'), findsOneWidget);
  expect(find.text('Upload: 25.0 Mbps'), findsOneWidget);
  expect(find.text('Ping: 15 ms'), findsOneWidget);
  
  // Verify View Results button present
  expect(find.text('View Results'), findsOneWidget);
  
  // Tap View Results
  await tester.tap(find.text('View Results'));
  await tester.pumpAndSettle();
  
  // Verify on results screen
  expect(find.text('Speed Test Results'), findsOneWidget);
});
```
