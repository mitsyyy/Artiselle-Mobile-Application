import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/router.dart';
import '../../utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  UserRole _selectedRole = UserRole.buyer;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _errorMessage = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final error = await context.read<AuthProvider>().register(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _displayNameController.text,
          role: _selectedRole,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    _navigateToHome();
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final error = await context.read<AuthProvider>().signInWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }

    _navigateToHome();
  }

  void _navigateToHome() {
    final role = context.read<AuthProvider>().currentUser?.role;
    final route =
        role == UserRole.seller ? AppRoutes.sellerHome : AppRoutes.buyerHome;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.center,
                      heightFactor: 0.6,
                      child: Image.asset(
                        'lib/assets/images/artiselle-icon.png',
                        height: 240,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Create Account',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join Artiselle as a buyer or seller.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Error banner
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                          color: theme.colorScheme.onErrorContainer),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Display name
                TextFormField(
                  controller: _displayNameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      validateRequired(v, fieldName: 'Full name'),
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: validatePassword,
                ),
                const SizedBox(height: 24),

                // Role selector
                Row(
                  children: UserRole.values.map((role) {
                    final selected = _selectedRole == role;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: role == UserRole.buyer ? 8 : 0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: selected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            foregroundColor: selected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.primary,
                            side: BorderSide(
                                color: theme.colorScheme.primary, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () =>
                              setState(() => _selectedRole = role),
                          child: Text(
                            role == UserRole.buyer ? 'Buyer' : 'Seller',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Register button
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Account',
                          style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                // Divider
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or',
                        style: TextStyle(color: Colors.grey[500])),
                  ),
                  const Expanded(child: Divider()),
                ]),
                const SizedBox(height: 16),

                // Google Sign-In
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  icon: SvgPicture.asset(
                    'lib/assets/images/google_logo.svg',
                    width: 20,
                    height: 20,
                  ),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 24),

                // Navigate to login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: TextStyle(color: Colors.grey[600])),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, '/login'),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
