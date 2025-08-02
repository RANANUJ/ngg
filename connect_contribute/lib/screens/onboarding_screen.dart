import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/onboarding_page_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageModel> _pages = [
    OnboardingPageModel(
      imageAsset: 'assets/images/onboarding1.png',
      title: 'Welcome to Connect & Contribute',
      description:
          'Bridge the gap between donors, volunteers, and NGOs in your community.',
    ),
    OnboardingPageModel(
      imageAsset: 'assets/images/onboarding2.png',
      title: 'Donate & Volunteer',
      description:
          'Find opportunities to donate items or volunteer your time for local causes.',
    ),
    OnboardingPageModel(
      imageAsset: 'assets/images/onboarding3.png',
      title: 'Track Your Impact',
      description:
          'See your contribution history and celebrate your milestones!',
    ),
  ];

  void _onSkip() {
    GoRouter.of(context).go('/login');
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      GoRouter.of(context).go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (fixed at top)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _onSkip,
                  child: const Text('Skip'),
                ),
              ),
            ),
            // PageView for content (only this moves)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Image.asset(
                            page.imageAsset,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (context, error, stackTrace) => Icon(
                                  Icons.image,
                                  size: 120,
                                  color: Colors.blueGrey.shade100,
                                ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey.shade800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dots indicator (fixed at bottom)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? Colors.blueAccent
                              : Colors.blueGrey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            // Next/Get Started button (fixed at bottom)
            Padding(
              padding: const EdgeInsets.all(32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
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
