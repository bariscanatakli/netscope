abstract class AuthServiceInterface {
  Future<bool> signIn(String email, String password);
  Future<bool> signUp(String email, String password, String username);
  Future<void> signOut();
  // ...other auth methods...
}
