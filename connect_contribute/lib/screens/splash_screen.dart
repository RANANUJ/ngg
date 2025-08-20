import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize auth state
    await context.read<AuthProvider>().initializeAuth();
    
    // Wait for splash duration
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        // User is logged in, navigate to appropriate dashboard
        if (authProvider.user?.userType == 'NGO') {
          context.go('/ngo-dashboard');
        } else {
          context.go('/volunteer-dashboard');
        }
      } else {
        // User is not logged in, show onboarding
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5F7FA), Color(0xFFE3E6EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Main content (logo and text) centered
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo image
                  Image.asset(
                    'assets/images/logo.png',
                    width: 110,
                    height: 110,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.volunteer_activism,
                      size: 90,
                      color: Colors.blueGrey.shade200,
                    ),
                  ),
                  const SizedBox(height: 28),
                  // App title
                  Text(
                    'Connect & Contribute',
                    style: TextStyle(
                      color: Colors.blueGrey.shade800,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Loading indicator
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blueGrey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}