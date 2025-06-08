import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: unused_import
// These imports are intentionally unused
// They ensure the files are included in the coverage report
import 'package:flutter/material.dart';
import 'package:netscope/main.dart';
import 'package:netscope/screens/auth/login_screen.dart';
import 'package:netscope/screens/auth/signup_screen.dart';
import 'package:netscope/screens/auth/forgot_password_screen.dart';
import 'package:netscope/providers/auth_provider.dart';
import 'package:netscope/screens/auth/auth_state_wrapper.dart';
import 'package:netscope/firebase_options.dart';

void main() {
  // This test imports all auth-related files to ensure they're included in lcov.info
  test('Auth imports for coverage', () {
    expect(true, isTrue);
  });
}
