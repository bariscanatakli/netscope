import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;
  final FirebaseFirestore firestore;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : auth = auth ?? FirebaseAuth.instance,
        googleSignIn = googleSignIn ?? GoogleSignIn(),
        firestore = firestore ?? FirebaseFirestore.instance;

  Future<UserCredential> signInWithGoogle() async {
    // Sign out just in case
    await googleSignIn.signOut();

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in aborted');
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      throw Exception('Google sign-in failed');
    }

    final userDoc = firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    if (!docSnapshot.exists) {
      await userDoc.set({
        'email': user.email,
        'username': user.displayName,
        'createdAt': Timestamp.now(),
      });
    }

    return userCredential;
  }
}
