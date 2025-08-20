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
              final isAuthRoute = ['/login', '/signup', '/onboarding', '/'].contains(state.matchedLocation);
              
              // If not logged in and trying to access protected routes
              if (!isLoggedIn && !isAuthRoute) {
                return '/onboarding';
              }
              
              return null; // No redirect needed
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