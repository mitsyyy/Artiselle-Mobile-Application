import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in Firebase user (null if signed out).
  User? get currentFirebaseUser => _auth.currentUser;

  // ── Email / Password ─────────────────────────────────────────────────────────

  /// Sign in with email and password.
  /// Returns null on success, or an error message string on failure.
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('signInWithEmail FirebaseAuthException: ${e.code} - ${e.message}');
      return _friendlyAuthError(e.code);
    } catch (e) {
      debugPrint('signInWithEmail unexpected error: $e (${e.runtimeType})');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Register a new user with email/password, then create a Firestore user doc.
  /// Returns null on success, or an error message string on failure.
  Future<String?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) return 'Registration failed. Please try again.';

      // Update Firebase Auth display name
      await user.updateDisplayName(displayName.trim());

      // Create Firestore user document
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        role: role,
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('registerWithEmail FirebaseAuthException: ${e.code} - ${e.message}');
      return _friendlyAuthError(e.code);
    } catch (e) {
      debugPrint('registerWithEmail unexpected error: $e (${e.runtimeType})');
      return 'An unexpected error occurred: $e';
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────────

  /// Sign in with Google. Creates a Firestore user doc if this is a new user.
  /// Returns a map with 'error' key on failure, or 'isNewUser' key on success.
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Use Firebase Auth's built-in Google sign-in (works on web & mobile)
      final googleProvider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(googleProvider);
      final user = userCredential.user;
      if (user == null) {
        return {'error': 'Google sign-in failed. Please try again.'};
      }

      // Check if user document exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final isNewUser = !userDoc.exists;

      if (isNewUser) {
        // Create a new user document (default role: buyer)
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? 'User',
          role: UserRole.buyer,
          emailVerified: user.emailVerified,
          createdAt: DateTime.now(),
        );
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
      }

      return {'isNewUser': isNewUser};
    } on FirebaseAuthException catch (e) {
      debugPrint('signInWithGoogle FirebaseAuthException: ${e.code} - ${e.message}');
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
        return {'error': 'Google sign-in was cancelled.'};
      }
      return {'error': _friendlyAuthError(e.code)};
    } catch (e) {
      debugPrint('signInWithGoogle unexpected error: $e (${e.runtimeType})');
      return {'error': 'Google sign-in failed. Please try again.'};
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────────

  /// Send a password-reset email. Returns null on success, or error message.
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyAuthError(e.code);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // ── User Profile ──────────────────────────────────────────────────────────────

  /// Fetch the Firestore user profile for the given uid.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      debugPrint('getUserProfile: fetching user doc for uid=$uid');
      final doc = await _firestore.collection('users').doc(uid).get();
      debugPrint('getUserProfile: doc.exists=${doc.exists}, data=${doc.data()}');
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromMap(uid, doc.data()!);
    } catch (e) {
      debugPrint('getUserProfile error: $e');
      return null;
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  String _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'configuration-not-found':
        return 'Email/Password sign-in is not enabled. Please enable it in Firebase Console.';
      default:
        debugPrint('Unhandled auth error code: $code');
        return 'Authentication failed. Please try again.';
    }
  }
}
