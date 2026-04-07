import 'package:flutter/material.dart';
import '../models/user_model.dart';

// Static test accounts
const _staticAccounts = [
  {
    'uid': 'static-buyer-001',
    'email': 'buyer@artiselle.com',
    'password': 'buyer123',
    'displayName': 'Test Buyer',
    'role': 'buyer',
  },
  {
    'uid': 'static-seller-001',
    'email': 'seller@artiselle.com',
    'password': 'seller123',
    'displayName': 'Test Seller',
    'role': 'seller',
  },
];

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Returns null on success, or an error message string on failure.
  Future<String?> signInWithEmail(String email, String password) async {
    final match = _staticAccounts.where(
      (a) =>
          a['email'] == email.trim().toLowerCase() &&
          a['password'] == password,
    );

    if (match.isEmpty) return 'Invalid email or password.';

    final account = match.first;
    _currentUser = UserModel(
      uid: account['uid']!,
      email: account['email']!,
      displayName: account['displayName']!,
      role: UserRole.values.firstWhere((r) => r.name == account['role']),
      emailVerified: true,
      createdAt: DateTime(2024, 1, 1),
    );
    notifyListeners();
    return null;
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
