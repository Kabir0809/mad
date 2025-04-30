import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      debugPrint('Attempting to sign in with email: $email');
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Sign in successful for user: ${result.user?.uid}');
      return result;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      debugPrint('Attempting to register with email: $email');
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('Registration successful for user: ${result.user?.uid}');
      return result;
    } catch (e) {
      debugPrint('Error registering: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut(BuildContext context) async {
    try {
      debugPrint('Attempting to sign out');
      await _auth.signOut();
      debugPrint('Sign out successful');
      
      // Navigate to login screen and remove all previous routes
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }
} 