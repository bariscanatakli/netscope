# NetScope SpeedTest Tests

This folder contains tests for the SpeedTest module of the NetScope application that can work **without** requiring Firebase credentials.

## Quick Start

### Windows
```powershell
# Run all tests
.\run_tests.ps1 -all

# Run only unit tests
.\run_tests.ps1 -unit

# Generate coverage report
.\run_tests.ps1 -all -coverage
```

### Linux/Mac
```bash
# Make the script executable
chmod +x run_tests.sh

# Run all tests
./run_tests.sh --all

# Run only unit tests
./run_tests.sh --unit

# Generate coverage report
./run_tests.sh --all --coverage
```

## Test Structure

- **Unit Tests**: `test/unit/` - Tests for models and service logic
- **Widget Tests**: `test/widget/` - Tests for UI components
- **Integration Tests**: `test/integration/` - Tests for integrated functionality
- **Examples**: `test/examples/` - Example test implementations
- **Mocks**: `test/mocks/` - Mock implementations of Firebase and other services
- **Documentation**: `test/docs/` - Guides for implementing tests

## Key Test Files

### Unit Tests
- `speedtest_service_test.dart` - Basic tests for SpeedTest service
- `speedtest_models_test.dart` - Comprehensive tests for SpeedTest models
- `enhanced_speedtest_service_test.dart` - Advanced service tests with mocks

### Widget Tests
- `enhanced_speedtest_screen_test.dart` - Tests for SpeedTest screen using mocks
- `enhanced_speed_test_results_screen_test.dart` - Tests for results screen

### Example Tests
- `speedtest_mock_example_test.dart` - How to use Firebase mocks
- `mockable_widget_example.dart` - How to make widgets that accept mocks
- `network_mocking_example_test.dart` - How to mock network operations
- `firebase_safe_integration_example.dart` - How to design for testability

## Documentation

- **Implementation Guide**: `test/docs/implementation_guide.md`
- **Making NetScope Testable**: `test/docs/making_netscope_testable.md`
- **Test Plan**: `TEST_PLAN.md` and `TEST_PLAN_EN.md` in project root

## Firebase Testing

Our mock implementation allows testing without Firebase credentials:

1. We've created custom `MockFirebaseAuth` and `MockFirestore` classes
2. Helper functions like `getMockAuth()` and `getMockFirestore()` simplify setup
3. Mockable widgets show how to inject dependencies for testing

For complete Firebase testing in the future, consider adding:
```yaml
dev_dependencies:
  firebase_auth_mocks: ^0.13.0
  fake_cloud_firestore: ^2.4.1
```

## Testing Guidelines

1. **Use Mocks**: Always use mocks instead of real Firebase services
2. **Dependency Injection**: Modify widgets to accept injected services
3. **Test One Thing**: Each test should focus on one specific functionality
4. **Descriptive Names**: Use clear test names that describe what's being tested
5. **Arrange, Act, Assert**: Follow this pattern in your tests

## For Team Members

Consult `test/docs/implementation_guide.md` for detailed steps on implementing tests for your assigned modules.
