import 'package:netscope/services/auth_service_interface.dart';

class MockAuthService implements AuthServiceInterface {
  bool signInCalled = false;
  
  @override
  Future<bool> signIn(String email, String password) async {
    signInCalled = true;
    return true;  // Always succeed in tests
  }
  
  @override
  Future<bool> signUp(String email, String password, String username) async {
    return true;  // Always succeed in tests
  }
  
  @override
  Future<void> signOut() async {
    // Mock implementation - no actual sign out needed in tests
  }
}
