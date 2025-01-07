import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    // Forces a new account pick prompt
    await _googleSignIn.signOut();
    final GoogleSignInAccount? gUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? gAuth = await gUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth?.accessToken,
      idToken: gAuth?.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Create Firestore doc with Google display name if not existing
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid);
    final userDoc = await docRef.get();
    if (!userDoc.exists) {
      await docRef.set({
        'email': userCredential.user!.email,
        'username': userCredential.user!.displayName ?? '',
        'createdAt': Timestamp.now(),
      });
    }

    return userCredential;
  }
}
