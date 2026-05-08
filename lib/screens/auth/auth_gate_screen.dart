import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/router.dart';

/// Checks for an existing Firebase session on app start.
/// If the user is already signed in, navigates to the correct home screen.
/// Otherwise, navigates to the login screen.
class AuthGateScreen extends StatefulWidget {
  const AuthGateScreen({super.key});

  @override
  State<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends State<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.tryAutoLogin();

    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      final role = authProvider.currentUser?.role;
      final route = role == UserRole.seller
          ? AppRoutes.sellerHome
          : AppRoutes.buyerHome;
      Navigator.pushReplacementNamed(context, route);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple loading indicator while checking auth
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
