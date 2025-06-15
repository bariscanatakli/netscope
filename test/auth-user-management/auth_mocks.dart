import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:netscope/services/auth_service.dart';

@GenerateMocks([
  CollectionReference,
  DocumentReference,
  AuthService,
  FirebaseAuth,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  FirebaseFirestore,
  DocumentSnapshot<Map<String, dynamic>>,
  User
])
void main() {}
