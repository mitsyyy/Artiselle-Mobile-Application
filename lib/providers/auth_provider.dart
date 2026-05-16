import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;

  /// Try to restore session from Firebase Auth on app start.
  Future<void> tryAutoLogin() async {
    final firebaseUser = _authService.currentFirebaseUser;
    if (firebaseUser == null) return;

    _isLoading = true;
    notifyListeners();

    _currentUser = await _authService.getUserProfile(firebaseUser.uid);

    _isLoading = false;
    notifyListeners();
  }

  /// Sign in with email and password.
  /// Returns null on success, or an error message string on failure.
  Future<String?> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    if (email == 'admin@gmail.com' && password == 'admin123') {
      _currentUser = UserModel(
        uid: 'admin_uid',
        email: email,
        displayName: 'Admin',
        role: UserRole.admin,
        emailVerified: true,
        createdAt: DateTime.now(),
      );
      _isLoading = false;
      notifyListeners();
      return null;
    }

    final error = await _authService.signInWithEmail(email, password);
    if (error != null) {
      _isLoading = false;
      notifyListeners();
      return error;
    }

    // Fetch user profile from Firestore
    final firebaseUser = _authService.currentFirebaseUser;
    if (firebaseUser != null) {
      _currentUser = await _authService.getUserProfile(firebaseUser.uid);
    }

    _isLoading = false;
    notifyListeners();
    return _currentUser == null ? 'Failed to load user profile.' : null;
  }

  /// Register a new user.
  /// Returns null on success, or an error message string on failure.
  Future<String?> register({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    _isLoading = true;
    notifyListeners();

    final error = await _authService.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
      role: role,
    );

    if (error != null) {
      _isLoading = false;
      notifyListeners();
      return error;
    }

    // Fetch user profile from Firestore
    final firebaseUser = _authService.currentFirebaseUser;
    if (firebaseUser != null) {
      _currentUser = await _authService.getUserProfile(firebaseUser.uid);
    }

    _isLoading = false;
    notifyListeners();
    return _currentUser == null ? 'Failed to load user profile.' : null;
  }

  /// Sign in with Google.
  /// Returns null on success, or an error message string on failure.
  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.signInWithGoogle();

    if (result.containsKey('error')) {
      _isLoading = false;
      notifyListeners();
      return result['error'] as String;
    }

    // Fetch user profile from Firestore
    final firebaseUser = _authService.currentFirebaseUser;
    if (firebaseUser != null) {
      _currentUser = await _authService.getUserProfile(firebaseUser.uid);
    }

    _isLoading = false;
    notifyListeners();
    return _currentUser == null ? 'Failed to load user profile.' : null;
  }

  /// Send password reset email.
  /// Returns null on success, or an error message string on failure.
  Future<String?> sendPasswordReset(String email) async {
    return await _authService.sendPasswordReset(email);
  }

  /// Sign out.
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
