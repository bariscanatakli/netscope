import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Firebase Email/Password login
  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return; // Context'in geçerliliğini kontrol et
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RootScreen()),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> googleLogin() async {
    try {
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

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return; // Context'in geçerliliğini kontrol et
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RootScreen()),
      );
    } catch (e) {
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
                // Logo (Optional)
                CircleAvatar(
                  radius: 60,
                  backgroundColor: backgroundColor,
                  child: Image.asset(
                    'assets/logo2.png',
                    height: 100,
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
                const SizedBox(height: 20),
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
                const SizedBox(height: 20),
                // Login Button
                ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 50,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(height: 20),
                // Google Sign-In Button
                OutlinedButton.icon(
                  onPressed: googleLogin,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: textColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                  ),
                  icon: Icon(Icons.login, color: textColor),
                  label: Text(
                    "Sign in with Google",
                    style: TextStyle(color: textColor),
                  ),
                ),
                const SizedBox(height: 20),
                // Sign Up Link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignupScreen()),
                    );
                  },
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // Forgot Password Link
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
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
