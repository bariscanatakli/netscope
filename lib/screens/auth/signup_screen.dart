import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:netscope/screens/auth/username_screen.dart';
import 'package:netscope/screens/home/root_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase Email/Password signup
  Future<void> signup() async {
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
      }
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Registration successful
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration successful!")),
        );
        // Instead of going to LoginScreen directly, go to UsernameScreen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UsernameScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle errors
      String errorMessage = e.message ?? "An error occurred";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  // Google Sign-In
  Future<void> googleLogin() async {
    try {
      // Attempt to sign out from the existing Google account
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Google Sign-In cancelled")),
          );
        }
        return;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase authentication
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      await _auth.signInWithCredential(credential);

      // Redirect to the homepage after successful signup
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In successful!")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const RootScreen()), // Change to your homepage widget
        );
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Login Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final buttonColor = isDarkMode ? Colors.grey[800] : Colors.blue;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // Logo
                CircleAvatar(
                  radius: 50,
                  backgroundColor: backgroundColor,
                  child: Image.asset(
                    'assets/logo2.png',
                    height: 80,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text("Logo yüklenemedi!");
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Email Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: textColor),
                    hintText: "Enter your email",
                    filled: true,
                    fillColor: buttonColor!.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: TextStyle(color: textColor),
                  ),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 15),
                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: textColor),
                    hintText: "Enter your password",
                    filled: true,
                    fillColor: buttonColor.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: TextStyle(color: textColor),
                  ),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 15),
                // Confirm Password Field
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: textColor),
                    hintText: "Confirm your password",
                    filled: true,
                    fillColor: buttonColor.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: TextStyle(color: textColor),
                  ),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 20),
                // Register Button
                ElevatedButton(
                  onPressed: signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Register",
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(height: 15),
                // Login Link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Already have an account? Log in",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // Google Sign-In Button
                OutlinedButton.icon(
                  onPressed: googleLogin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: textColor),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 10),
                  ),
                  icon: Icon(Icons.login, color: textColor),
                  label: Text(
                    "Sign in with Google",
                    style: TextStyle(color: textColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
