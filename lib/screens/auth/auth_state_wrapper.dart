import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import '../home/root_screen.dart';

/// A wrapper widget that handles authentication state changes
/// and redirects users to the appropriate screen
class AuthStateWrapper extends StatelessWidget {
  const AuthStateWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Get current authentication state
    final user = authProvider.user;

    // Redirect based on auth state
    if (user != null) {
      // User is logged in, go to the main app screens
      return const RootScreen();
    } else {
      // User is not logged in, go to login screen
      return const LoginScreen();
    }
  }
}
