import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../extensions/context_extension.dart';
import '../../../../routing/app_routes.dart';
import '../../../../shared/app_assets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;
  int _currentIndex = 0;
  bool _precached = false;

  final List<Map<String, String>> _onboardingSlides = const [
    {
      'title': 'Your Complete Dental Supply Marketplace',
      'description':
          'Explore 10,000+ certified dental instruments, restorative materials, and equipment from globally trusted brands.',
      'image':
          'https://images.unsplash.com/photo-1588776814546-1ffcf47267a5?w=800&auto=format&fit=crop&q=80',
      'tag': 'EXTENSIVE CATALOG',
    },
    {
      'title': 'Wholesale B2B Pricing For Practices',
      'description':
          'Unlock tiered clinic wholesale rates, bulk order incentives, and official manufacturer warranty for your practice.',
      'image':
          'https://images.unsplash.com/photo-1629909613654-28e377c37b09?w=800&auto=format&fit=crop&q=80',
      'tag': 'B2B CLINIC TIER',
    },
    {
      'title': 'Express Dispatch & Clinical Support',
      'description':
          'Fast nationwide courier delivery with live shipment tracking, flexible payments, and dedicated dental support.',
      'image':
          'https://images.unsplash.com/photo-1606811841689-23dfddce3e95?w=800&auto=format&fit=crop&q=80',
      'tag': 'EXPRESS DELIVERY',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      for (final slide in _onboardingSlides) {
        precacheImage(CachedNetworkImageProvider(slide['image']!), context);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() {
    context.go(AppRoutes.welcome);
  }

  void _onNext() {
    if (_currentIndex < _onboardingSlides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.theme.colorScheme;
    final isDark = context.theme.brightness == Brightness.dark;

    final bgCardColor = isDark ? const Color(0xFF0B111A) : Colors.white;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: bgCardColor,
      body: Stack(
        children: [
          // Background Image PageView
          PageView.builder(
            controller: _pageController,
            itemCount: _onboardingSlides.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final slide = _onboardingSlides[index];

              return Stack(
                fit: StackFit.expand,
                children: [
                  // High-Res Dental Background Image
                  CachedNetworkImage(
                    imageUrl: slide['image']!,
                    fit: BoxFit.cover,
                    memCacheWidth: 800,
                    fadeInDuration: const Duration(milliseconds: 100),
                    placeholder: (_, __) => ColoredBox(
                      color: isDark
                          ? const Color(0xFF131D2A)
                          : const Color(0xFFF1F5F9),
                      child: Center(
                        child: Icon(
                          Icons.medical_services_outlined,
                          size: 64,
                          color: cs.primary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => ColoredBox(
                      color: isDark
                          ? const Color(0xFF131D2A)
                          : const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(
                          Icons.medical_services_outlined,
                          size: 64,
                          color: Colors.black12,
                        ),
                      ),
                    ),
                  ),

                  // Soft Top Gradient for header clarity
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            bgCardColor.withValues(alpha: 0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Smooth White/Light Gradient Transition into bottom content
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.35, 0.6, 1.0],
                          colors: [
                            Colors.transparent,
                            bgCardColor.withValues(alpha: 0.3),
                            bgCardColor.withValues(alpha: 0.9),
                            bgCardColor,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Slide Content (Tag, Title, Description)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 155,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tag Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 7),
                              Text(
                                slide['tag']!,
                                style: TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title in High Contrast
                        Text(
                          slide['title']!,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: primaryTextColor,
                            height: 1.25,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          slide['description']!,
                          style: TextStyle(
                            fontSize: 14.5,
                            color: secondaryTextColor,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Top Header (Logo & Skip button)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Official Logo in White Capsule
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: bgCardColor.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white12
                                  : Colors.black.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Image.asset(
                            AppAssets.logo,
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Skip Button
                    if (_currentIndex < _onboardingSlides.length - 1)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: InkWell(
                            onTap: _onFinish,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: bgCardColor.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls (Page Indicator & Action Button)
          Positioned(
            left: 24,
            right: 24,
            bottom: 34,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Page Indicator
                AnimatedSmoothIndicator(
                  activeIndex: _currentIndex,
                  count: _onboardingSlides.length,
                  effect: ExpandingDotsEffect(
                    dotHeight: 7,
                    dotWidth: 7,
                    expansionFactor: 4,
                    spacing: 6,
                    dotColor: isDark
                        ? Colors.white24
                        : const Color(0xFFCBD5E1),
                    activeDotColor: cs.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Action Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: cs.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentIndex == _onboardingSlides.length - 1
                              ? 'Get Started'
                              : 'Continue',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
