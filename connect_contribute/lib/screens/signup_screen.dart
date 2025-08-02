import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedUserType = 'Individual';
  bool _isLoading = false;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<AuthProvider>().signup(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _selectedUserType,
      );

      if (mounted) {
        if (success) {
          // Navigate to home screen after successful signup
          context.push('/home');
        } else {
          // Show error message from AuthProvider
          final error = context.read<AuthProvider>().error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Signup failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
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
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE3E6EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Back button and title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          context.push('/login');
                        },
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.blueGrey.shade700,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                  const SizedBox(height: 32),
                  // User type selection
                  Text(
                    'I am a:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedUserType = 'Individual';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color:
                                  _selectedUserType == 'Individual'
                                      ? Colors.blue.shade50
                                      : Colors.white,
                              border: Border.all(
                                color:
                                    _selectedUserType == 'Individual'
                                        ? Colors.blue.shade400
                                        : Colors.blueGrey.shade200,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person,
                                  color:
                                      _selectedUserType == 'Individual'
                                          ? Colors.blue.shade600
                                          : Colors.blueGrey.shade400,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Individual',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _selectedUserType == 'Individual'
                                            ? Colors.blue.shade600
                                            : Colors.blueGrey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedUserType = 'NGO';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color:
                                  _selectedUserType == 'NGO'
                                      ? Colors.blue.shade50
                                      : Colors.white,
                              border: Border.all(
                                color:
                                    _selectedUserType == 'NGO'
                                        ? Colors.blue.shade400
                                        : Colors.blueGrey.shade200,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.business,
                                  color:
                                      _selectedUserType == 'NGO'
                                          ? Colors.blue.shade600
                                          : Colors.blueGrey.shade400,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'NGO',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        _selectedUserType == 'NGO'
                                            ? Colors.blue.shade600
                                            : Colors.blueGrey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Name field
                  CustomTextField(
                    label:
                        _selectedUserType == 'Individual'
                            ? 'Full Name'
                            : 'Organization Name',
                    hint:
                        _selectedUserType == 'Individual'
                            ? 'Enter your full name'
                            : 'Enter organization name',
                    controller: _nameController,
                    validator: _validateName,
                    prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 24),
                  // Email field
                  CustomTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                  ),
                  const SizedBox(height: 24),
                  // Password field
                  CustomTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    isPassword: true,
                    validator: _validatePassword,
                    prefixIcon: Icons.lock,
                  ),
                  const SizedBox(height: 24),
                  // Confirm password field
                  CustomTextField(
                    label: 'Confirm Password',
                    hint: 'Confirm your password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    validator: _validateConfirmPassword,
                    prefixIcon: Icons.lock,
                  ),
                  const SizedBox(height: 32),
                  // Signup button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return ElevatedButton(
                        onPressed: _isLoading ? null : _onSignup,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: Colors.blueGrey.shade600),
                      ),
                      TextButton(
                        onPressed: () {
                          GoRouter.of(context).go('/login');
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
