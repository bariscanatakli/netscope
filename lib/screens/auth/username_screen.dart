import 'package:cloud_firestore/cloud_firestore.dart'; // Only needed if you use Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class UsernameScreen extends StatefulWidget {
  const UsernameScreen({Key? key}) : super(key: key);

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _saveUsernameAndContinue() async {
    // 1. Get the current user
    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user signed in.")),
      );
      return;
    }

    // ------------ APPROACH A: Update Firebase User Profile --------------
    try {
      // Update the Firebase User displayName field
      await user.updateDisplayName(_usernameController.text.trim());
      // Reload the user to apply changes
      await user.reload();
      user = _auth.currentUser;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update displayName: $e")),
      );
      return;
    }

    // ------------ APPROACH B: Store username in Firestore (optional) -----------
    // (Uncomment below if you also want to keep a record in the Firestore DB)
    /*
    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.set({
        'email': user.email,
        'username': _usernameController.text.trim(),
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firestore save error: $e")),
      );
      return;
    }
    */

    // 2. Notify user & navigate to the next screen
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Username saved successfully!")),
      );
      // For example, go to HomeScreen or LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: textColor),
                    hintText: "Choose a username",
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
                ElevatedButton(
                  onPressed: _saveUsernameAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 40,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Save Username",
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
