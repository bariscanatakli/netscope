import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:netscope/services/auth_service.dart';
import 'package:netscope/services/network_info_service.dart';
import 'package:netscope/services/storage_service.dart';
import 'package:netscope/models/speedtest_models.dart';
import 'package:netscope/screens/apps/speedtest/services/speedtest_service.dart';

// Mock servisler örneği
// Buradaki örnek test silindi, her ekip üyesi kendi test dosyasında test case yazmalı.

// Her ekip üyesi için kullanılacak mock servisler:
class MockAuthService extends Mock implements AuthService {
  dynamic getCurrentUser() => null;
}

class MockNetworkInfoService extends Mock implements NetworkInfoService {
  Future<String> getConnectionType() async => 'WiFi';
  Future<String> getWifiName() async => 'Test_Network';
}

// Mocking the ImprovedSpeedTest class from the project
class MockSpeedTestService extends Mock implements ImprovedSpeedTest {
  @override
  Future<SpeedTestResult> runTest(
      void Function(TestProgress) onProgress) async {
    // Call onProgress a few times to simulate test progress
    onProgress(TestProgress(
      status: 'Testing download speed',
      progress: 0.25,
      currentSpeed: 25.0,
    ));

    await Future.delayed(const Duration(milliseconds: 100));

    onProgress(TestProgress(
      status: 'Testing upload speed',
      progress: 0.75,
      currentSpeed: 10.0,
    ));

    await Future.delayed(const Duration(milliseconds: 100));
    // Return mock result
    return SpeedTestResult(
      downloadSpeed: 50.0,
      uploadSpeed: 25.0,
      ping: 15,
    );
  }
}

class MockStorageService extends Mock implements StorageService {}

// Kullanım örneği:
// final mockAuth = MockAuthService();
// test('Açıklama', () {
//   // mockAuth ile ilgili test case
// });
