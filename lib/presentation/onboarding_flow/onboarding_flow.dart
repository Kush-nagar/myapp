import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/app_export.dart';
import './widgets/location_permission_dialog.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/zip_code_entry_dialog.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Discover Local Organizations",
      "description":
          "Find food banks, shelters, and donation centers near you. Connect with organizations that need your support most.",
      "image":
          "https://images.pexels.com/photos/6646918/pexels-photo-6646918.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    },
    {
      "title": "View Donation Guidelines",
      "description":
          "Learn what each organization needs and their specific requirements. Make informed donations that truly help.",
      "image":
          "https://images.pexels.com/photos/6995247/pexels-photo-6995247.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    },
    {
      "title": "Track Your Contributions",
      "description":
          "Keep track of your donations and see the impact you're making in your community. Every contribution counts.",
      "image":
          "https://images.pexels.com/photos/6646917/pexels-photo-6646917.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showLocationPermissionDialog();
    }
  }

  void _skipOnboarding() {
    _showLocationPermissionDialog();
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        onAllowLocation: _requestLocationPermission,
        onManualEntry: _showZipCodeDialog,
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    Navigator.of(context).pop(); // Close permission dialog

    final status = await Permission.location.request();

    if (status.isGranted) {
      _navigateToHome();
    } else if (status.isDenied) {
      _showZipCodeDialog();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    }
  }

  void _showZipCodeDialog() {
    Navigator.of(context).pop(); // Close permission dialog if open

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ZipCodeEntryDialog(
        onZipCodeEntered: (zipCode) {
          Navigator.of(context).pop(); // Close ZIP code dialog
          _navigateToHome();
        },
        onCancel: () {
          Navigator.of(context).pop(); // Close ZIP code dialog
          _showLocationPermissionDialog(); // Show permission dialog again
        },
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Location Permission Required',
          style: DonationAppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Location access has been permanently denied. Please enable it in Settings or enter your ZIP code manually.',
          style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showZipCodeDialog();
            },
            child: Text('Enter ZIP Code'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacementNamed(context, '/home-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DonationAppTheme.lightTheme.scaffoldBackgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Skip button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentPage < _onboardingData.length - 1)
                      TextButton(
                        onPressed: _skipOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor:
                              DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 1.h),
                        ),
                        child: Text(
                          'Skip',
                          style: DonationAppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            color: DonationAppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return OnboardingPageWidget(
                    title: data["title"] as String,
                    description: data["description"] as String,
                    imageUrl: data["image"] as String,
                    isLastPage: index == _onboardingData.length - 1,
                    onGetStarted: _nextPage,
                  );
                },
              ),
            ),

            // Page indicator and navigation
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                child: Column(
                  children: [
                    // Page indicator
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: _onboardingData.length,
                      effect: WormEffect(
                        dotWidth: 3.w,
                        dotHeight: 1.h,
                        activeDotColor: DonationAppTheme.lightTheme.colorScheme.primary,
                        dotColor: DonationAppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                        spacing: 2.w,
                        radius: 4,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Next button (only show if not last page)
                    if (_currentPage < _onboardingData.length - 1)
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                DonationAppTheme.lightTheme.colorScheme.primary,
                            foregroundColor:
                                DonationAppTheme.lightTheme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: DonationAppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color:
                                      DonationAppTheme.lightTheme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName: 'arrow_forward',
                                color:
                                    DonationAppTheme.lightTheme.colorScheme.onPrimary,
                                size: 5.w,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
