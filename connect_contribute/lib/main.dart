import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'themes/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ngo_dashboard_screen.dart';
import 'screens/volunteer_dashboard_screen.dart';
import 'screens/create_fundraising_screen.dart';
import 'screens/create_donation_request_screen.dart';
import 'screens/campaign_details_screen.dart';
import 'screens/donation_request_details_screen.dart';

void main() {
  runApp(const ConnectContributeApp());
}

class ConnectContributeApp extends StatelessWidget {
  const ConnectContributeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final router = GoRouter(
            initialLocation: '/',
            redirect: (context, state) {
              final isLoggedIn = authProvider.isAuthenticated;
              final isInitialized = authProvider.isInitialized;
              final isAuthenticating = authProvider.isAuthenticating;
              final currentPath = state.matchedLocation;
              
              print('Router redirect check: isLoggedIn=$isLoggedIn, isInitialized=$isInitialized, isAuthenticating=$isAuthenticating, path=$currentPath');
              print('User data: ${authProvider.user?.name}, type: ${authProvider.user?.userType}');
              
              // Don't redirect if currently authenticating to prevent flashing
              if (isAuthenticating) {
                print('Authentication in progress, no redirects');
                return null;
              }
              
              // Don't redirect until auth is initialized
              if (!isInitialized) {
                print('Auth not initialized, staying on splash');
                if (currentPath != '/') {
                  return '/'; // Go to splash screen if not initialized
                }
                return null; // Stay on splash screen
              }
              
              // After initialization, handle navigation
              if (isLoggedIn && authProvider.user != null) {
                print('User is authenticated with user data available');
                // User is authenticated - redirect from auth screens and splash to dashboard
                if (['/login', '/signup', '/onboarding', '/'].contains(currentPath)) {
                  // Redirect to appropriate dashboard based on user type
                  final user = authProvider.user!;
                  print('Redirecting authenticated user from $currentPath to dashboard. User type: ${user.userType}');
                  if (user.userType == 'NGO') {
                    print('Redirecting to NGO dashboard');
                    return '/ngo-dashboard';
                  } else {
                    print('Redirecting to volunteer dashboard');
                    return '/volunteer-dashboard';
                  }
                }
                // Allow access to all other routes (protected routes)
                print('Allowing access to protected route: $currentPath');
                return null;
              } else {
                print('User is NOT authenticated or user data not available');
                // User is not authenticated - handle redirects carefully
                if (['/ngo-dashboard', '/volunteer-dashboard', '/create-fundraising', '/create-donation-request', '/campaign-details', '/donation-request-details'].contains(currentPath)) {
                  print('User trying to access protected route $currentPath, redirecting to login');
                  return '/login'; // Redirect to login for protected routes
                }
                // If on splash screen and not authenticated - ALWAYS go to login now
                if (currentPath == '/') {
                  print('User on splash screen and not authenticated, redirecting to login');
                  return '/login'; // Always redirect to login, let users choose to see onboarding
                }
                // Allow access to auth screens (login, signup, onboarding) - NO REDIRECTS
                if (['/login', '/signup', '/onboarding'].contains(currentPath)) {
                  print('User on auth screen $currentPath, allowing access');
                  return null;
                }
                // For any other route, redirect to login
                print('User on unknown route $currentPath, redirecting to login');
                return '/login';
              }
            },
            routes: [
              GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
              GoRoute(
                path: '/onboarding',
                builder: (context, state) => const OnboardingScreen(),
              ),
              GoRoute(
                path: '/login',
                builder: (context, state) => const LoginScreen(),
              ),
              GoRoute(
                path: '/signup',
                builder: (context, state) => const SignupScreen(),
              ),
              GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
              GoRoute(
                path: '/ngo-dashboard',
                builder: (context, state) => const NGODashboardScreen(),
              ),
              GoRoute(
                path: '/volunteer-dashboard',
                builder: (context, state) => const VolunteerDashboardScreen(),
              ),
              GoRoute(
                path: '/create-fundraising',
                builder: (context, state) => const CreateFundraisingScreen(),
              ),
              GoRoute(
                path: '/create-donation-request',
                builder: (context, state) => const CreateDonationRequestScreen(),
              ),
              GoRoute(
                path: '/campaign-details',
                builder: (context, state) {
                  final campaign = state.extra as Map<String, dynamic>;
                  return CampaignDetailsScreen(
                    campaignId: campaign['_id'] ?? '',
                    campaign: campaign,
                  );
                },
              ),
              GoRoute(
                path: '/donation-request-details',
                builder: (context, state) {
                  final donationRequest = state.extra as Map<String, dynamic>;
                  return DonationRequestDetailsScreen(
                    requestId: donationRequest['_id'] ?? '',
                    donationRequest: donationRequest,
                  );
                },
              ),
            ],
          );

          return MaterialApp.router(
            title: 'Connect & Contribute',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}