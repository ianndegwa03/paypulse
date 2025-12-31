import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Professional Finance',
      description:
          'Experience a streamlined, high-security global wallet designed for the modern professional.',
      icon: Icons.account_balance_wallet_rounded,
      color: const Color(0xFF6366F1),
    ),
    OnboardingItem(
      title: 'Privacy Controlled',
      description:
          'You are in total control of your data. No AI, no bloat—just pure financial functionality.',
      icon: Icons.security_rounded,
      color: const Color(0xFF8B5CF6),
    ),
    OnboardingItem(
      title: 'Seamless Access',
      description:
          'Swift onboarding with biometric security. Access your global assets in seconds.',
      icon: Icons.fingerprint_rounded,
      color: const Color(0xFFEC4899),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background Aesthetic
          _buildBackground(),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.icon,
                                size: 80,
                                color: item.color,
                              ),
                            )
                                .animate()
                                .scale(
                                    duration: 600.ms, curve: Curves.easeOutBack)
                                .fadeIn(),
                            const SizedBox(height: 48),
                            Text(
                              item.title,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .moveY(begin: 20, end: 0),
                            const SizedBox(height: 16),
                            Text(
                              item.description,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .moveY(begin: 20, end: 0),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Section
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _items.length,
                          (index) => AnimatedContainer(
                            duration: 300.ms,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      PrimaryButton(
                        label: _currentPage == _items.length - 1
                            ? 'Get Started'
                            : 'Next',
                        onPressed: () {
                          if (_currentPage < _items.length - 1) {
                            _pageController.nextPage(
                              duration: 400.ms,
                              curve: Curves.easeInOut,
                            );
                          } else {
                            ref
                                .read(authNotifierProvider.notifier)
                                .completeOnboarding();
                            context.go('/register');
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(authNotifierProvider.notifier)
                              .completeOnboarding();
                          context.go('/login');
                        },
                        child: Text(
                          'Already have an account? Login',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF6366F1).withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEC4899).withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
