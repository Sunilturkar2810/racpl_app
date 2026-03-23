import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_dialog.dart';
import '../../utils/validators.dart';
import 'signup_screen.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: "san@gmail.com");
  final _passwordController = TextEditingController(text: "a1234");
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      developer.log('🔴 Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      developer.log('🟡 Starting login process...');
      developer.log('📧 Email: ${_emailController.text.trim()}');
      developer.log(
        '🔐 Password length: ${_passwordController.text.trim().length}',
      );

      final authProvider = context.read<AuthProvider>();
      developer.log('✅ AuthProvider obtained');

      final success = await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      developer.log('📡 Login response: $success');

      if (!mounted) return;

      if (success) {
        developer.log('🟢 Login SUCCESS! Navigating to HomeScreen...');
        // Navigate to home screen
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        developer.log('🔴 Login FAILED. Error: ${authProvider.error?.message}');
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(
            message: authProvider.error?.message ?? 'Login failed',
          ),
        );
      }
    } catch (e) {
      developer.log('🔴 LOGIN EXCEPTION: $e');
      developer.log('🔴 Exception type: ${e.runtimeType}');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(message: 'Login error: $e'),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // Title
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Login to your account',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 48),

                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter your work email',
                  controller: _emailController,
                  validator: AppValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                const SizedBox(height: 24),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null; // Backend will validate password strength
                  },
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outlined),
                ),
                const SizedBox(height: 32),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: 24),

                // Signup Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text('Sign up'),
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
