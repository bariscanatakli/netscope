# SpeedTest Module - Testing Guide

This document provides guidelines for testing the SpeedTest module in NetScope.

## Overview

The SpeedTest module consists of:
- SpeedTest screen - for running network speed tests
- SpeedTest results screen - for viewing historical test results
- SpeedTest service - for conducting actual speed measurements
- SpeedTest models - for storing test data

## Test Files Structure

```
test/
├── mocks/
│   └── speedtest_mock_data.dart     # Helper for creating test data
├── unit/
│   └── speedtest_service_test.dart  # Unit tests for SpeedTestService
└── widget/
    ├── speedtest_screen_test.dart   # Widget tests for SpeedTestScreen
    └── speed_test_results_screen_test.dart  # Widget tests for results screen
```

## Testing Strategy

### 1. Unit Testing
Focus on testing the models and pure logic in the SpeedTest service:
- Test SpeedTestResult model stores values correctly
- Test TestProgress model stores values correctly
- Test calculation and processing methods in the service

### 2. Widget Testing
For widget tests, there are two approaches:
- **Basic Widget Tests**: Test UI rendering without Firebase
- **Advanced Widget Tests**: Use Firebase mocks for full testing (requires additional setup)

### 3. Integration Testing
- Test the SpeedTest workflow from start to finish
- Test saving results to Firestore
- Test viewing historical results

## Test Data

Use the `SpeedTestMockData` class to generate consistent test data:

```dart
import '../mocks/speedtest_mock_data.dart';

// Get a sample speed test result
final result = SpeedTestMockData.createSampleResult(
  downloadSpeed: 75.0,
  uploadSpeed: 25.0,
  ping: 10,
);
```

## Testing Firebase Dependencies

To properly test Firebase functionality:
1. Use the `firebase_auth_mocks` and `cloud_firestore_mocks` packages
2. Set up test providers that use these mocks instead of real Firebase
3. Use dependency injection to provide these mocks to your widgets

## Key Areas to Test

1. **UI Elements**:
   - Speed gauge displays correctly
   - Start Test button works
   - Progress indicators show during test
   - Results display after completion

2. **Speed Test Logic**:
   - Download speed measurement
   - Upload speed measurement
   - Ping measurement
   - Progress reporting
   - Error handling

3. **Results Storage and Retrieval**:
   - Results are saved to Firestore
   - Historical results are loaded correctly
   - Results are displayed in chronological order

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/speedtest_service_test.dart

# Run tests with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```
