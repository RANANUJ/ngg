import 'package:flutter/material.dart';
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
    try {
      print('Splash: Starting app initialization...');
      
      // Show splash screen for minimum duration
      await Future.delayed(const Duration(seconds: 2));
      
      // Initialize auth state with timeout
      await Future.any([
        context.read<AuthProvider>().initializeAuth(),
        Future.delayed(const Duration(seconds: 8)) // 8 second timeout
      ]);
      
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        print('Splash: Auth check - isAuthenticated: ${authProvider.isAuthenticated}, user: ${authProvider.user?.name}');
        
        // Add small delay to ensure auth state is stable
        await Future.delayed(const Duration(milliseconds: 500));
        
        // The router will handle navigation automatically based on auth state
        print('Splash: Auth initialization complete, router will handle navigation');
      }
    } catch (e) {
      print('Splash: Error during initialization: $e');
      // Even if initialization fails, continue to navigation after brief delay
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 1000));
        print('Splash: Proceeding to navigation despite initialization error');
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