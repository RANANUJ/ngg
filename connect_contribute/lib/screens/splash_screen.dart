import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        GoRouter.of(context).go('/onboarding');
      }
    });
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
                    errorBuilder:
                        (context, error, stackTrace) => Icon(
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
                ],
              ),
            ),
            // Lottie loading animation at the bottom center
            Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Center(
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Image.asset(
                    'assets/gif/ClickUp Loading Splash.gif',
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
