import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:netscope/services/auth_service.dart';
import 'package:netscope/services/network_info_service.dart';
import 'package:netscope/services/speedtest_service.dart';
import 'package:netscope/services/storage_service.dart';

// Mock servisler örneği
// Buradaki örnek test silindi, her ekip üyesi kendi test dosyasında test case yazmalı.

// Her ekip üyesi için kullanılacak mock servisler:
class MockAuthService extends Mock implements AuthService {}

class MockNetworkInfoService extends Mock implements NetworkInfoService {}

class MockSpeedTestService extends Mock implements SpeedTestService {}

class MockStorageService extends Mock implements StorageService {}

// Kullanım örneği:
// final mockAuth = MockAuthService();
// test('Açıklama', () {
//   // mockAuth ile ilgili test case
// });
