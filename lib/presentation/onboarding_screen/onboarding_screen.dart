import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/feature_highlight_widget.dart';
import './widgets/hero_illustration_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleGetStarted() async {
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    // Set first launch flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);

    // Navigate to camera screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/camera-screen');
    }
  }

  Future<void> _handleSkip() async {
    // Set first launch flag
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);

    // Navigate to camera screen
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/camera-screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skip button
            _buildSkipButton(),
            SizedBox(height: 2.h),

            // Hero illustration
            const HeroIllustrationWidget(),
            SizedBox(height: 4.h),

            // Main heading
            _buildMainHeading(),
            SizedBox(height: 2.h),

            // Supporting text
            _buildSupportingText(),
            SizedBox(height: 4.h),

            // Feature highlights
            _buildFeatureHighlights(),
            SizedBox(height: 4.h),

            // Privacy note
            _buildPrivacyNote(),
            SizedBox(height: 4.h),

            // Get started button
            _buildGetStartedButton(),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Align(
      alignment: Alignment.topRight,
      child: TextButton(
        onPressed: _handleSkip,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          'Skip',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMainHeading() {
    return Text(
      'Discover Recipes from Your Ingredients',
      style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppTheme.lightTheme.colorScheme.onSurface,
        height: 1.2,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildSupportingText() {
    return Text(
      'Simply snap a photo of your ingredients and let our smart recognition technology find the perfect recipes for you. No more wondering what to cook!',
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildFeatureHighlights() {
    final features = [
      {
        'icon': 'camera_alt',
        'title': 'Snap Ingredients',
        'description': 'Take a photo of your available ingredients',
      },
      {
        'icon': 'psychology',
        'title': 'Get Instant Recognition',
        'description': 'AI identifies ingredients with confidence scores',
      },
      {
        'icon': 'restaurant_menu',
        'title': 'Find Perfect Recipes',
        'description': 'Discover recipes matched to your ingredients',
      },
    ];

    return Column(
      children: features.map((feature) {
        return FeatureHighlightWidget(
          iconName: feature['icon'] as String,
          title: feature['title'] as String,
          description: feature['description'] as String,
        );
      }).toList(),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'security',
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy First',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'All processing happens locally on your device. No data is shared or stored externally.',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 7.h,
      child: ElevatedButton(
        onPressed: _handleGetStarted,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppTheme.lightTheme.colorScheme.primary.withValues(
            alpha: 0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Get Started',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'arrow_forward',
              color: Colors.white,
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }
}
