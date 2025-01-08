import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider(
      (ref) => AuthService(
    auth: FirebaseAuth.instance,
    googleSignIn: GoogleSignIn(),
  ),
);

class AuthService {
  FirebaseAuth auth;
  GoogleSignIn googleSignIn;

  AuthService({
    required this.auth,
    required this.googleSignIn,
  });

  // Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      final user = await googleSignIn.signIn();
      final googleAuth = await user!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }

  // Email and Password Sign-In
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Error signing in with email and password: $e');
    }
  }

  // Email and Password Sign-Up
  Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Error signing up with email and password: $e');
    }
  }

  // Sign-Out
  Future<void> signOut() async {
    await auth.signOut();
    await googleSignIn.signOut();
  }
}
