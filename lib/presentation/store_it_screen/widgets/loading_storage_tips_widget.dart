import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import 'dart:math' as math;

class LoadingStorageTipsWidget extends StatefulWidget {
  const LoadingStorageTipsWidget({Key? key}) : super(key: key);

  @override
  State<LoadingStorageTipsWidget> createState() =>
      _LoadingStorageTipsWidgetState();
}

class _LoadingStorageTipsWidgetState extends State<LoadingStorageTipsWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.colorScheme.surface,
              AppTheme.lightTheme.colorScheme.primary.withOpacity(0.03),
              AppTheme.lightTheme.colorScheme.surface,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 5.w,
              vertical: isSmallScreen ? 2.h : 4.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: isSmallScreen ? 2.h : 4.h),

                // Enhanced animated loading icon with glow effect
                _buildAnimatedLoadingIcon(),

                SizedBox(height: isSmallScreen ? 4.h : 6.h),

                // Loading text with shimmer effect
                _buildLoadingText(),

                SizedBox(height: isSmallScreen ? 3.h : 4.h),

                // Enhanced progress indicator with animated background
                _buildProgressIndicator(),

                SizedBox(height: isSmallScreen ? 4.h : 6.h),

                // Beautiful loading tips section
                _buildLoadingTips(),

                SizedBox(height: isSmallScreen ? 4.h : 6.h),

                // Enhanced skeleton cards with better animations
                _buildEnhancedSkeletonCards(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLoadingIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer glow ring
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 35.w,
                height: 35.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                      AppTheme.lightTheme.colorScheme.primary.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Middle rotating ring
        AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotateAnimation.value * 2 * math.pi,
              child: Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: AppTheme.lightTheme.colorScheme.primary.withOpacity(
                      0.2,
                    ),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.all(1.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.lightTheme.colorScheme.primary.withOpacity(
                          0.3,
                        ),
                        AppTheme.lightTheme.colorScheme.secondary.withOpacity(
                          0.5,
                        ),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Main loading icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value * 0.9,
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary,
                      AppTheme.lightTheme.colorScheme.secondary,
                      AppTheme.lightTheme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 12,
                    ),
                  ],
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'inventory',
                    color: Colors.white,
                    size: 8.w,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingText() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Text(
                'Generating Storage Tips',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),

        SizedBox(height: 2.h),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Our AI is analyzing your ingredients to provide\npersonalized storage recommendations',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              height: 1.5,
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: [
          // Animated dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  final delay = index * 0.3;
                  final animationValue =
                      (_shimmerController.value + delay) % 1.0;
                  final opacity =
                      (math.sin(animationValue * 2 * math.pi) + 1) / 2;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    width: 3.w,
                    height: 3.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withOpacity(0.3 + (opacity * 0.7)),
                    ),
                  );
                },
              );
            }),
          ),

          SizedBox(height: 3.h),

          // Linear progress bar with shimmer effect
          Container(
            width: 70.w,
            height: 1.2.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(0.6.h),
            ),
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Background progress
                    Container(
                      width: 70.w * 0.7,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightTheme.colorScheme.primary.withOpacity(
                              0.3,
                            ),
                            AppTheme.lightTheme.colorScheme.secondary
                                .withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(0.6.h),
                      ),
                    ),

                    // Shimmer effect
                    Positioned(
                      left: _shimmerAnimation.value * 70.w * 0.3,
                      child: Container(
                        width: 15.w,
                        height: 1.2.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.4),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(0.6.h),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingTips() {
    final tips = [
      "💡 Analyzing ingredient freshness patterns",
      "🌡️ Calculating optimal temperature zones",
      "📅 Determining best storage durations",
      "🔬 Processing nutritional data",
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          final currentTipIndex =
              (_fadeController.value * tips.length).floor() % tips.length;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey(currentTipIndex),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(
                    0.1,
                  ),
                  width: 1,
                ),
              ),
              child: Text(
                tips[currentTipIndex],
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEnhancedSkeletonCards() {
    return Column(
      children: List.generate(2, (index) {
        return AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(bottom: 3.h),
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withOpacity(
                    0.1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.primary.withOpacity(
                      0.05,
                    ),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header skeleton with enhanced shimmer
                  Row(
                    children: [
                      _buildShimmerContainer(
                        width: 14.w,
                        height: 14.w,
                        borderRadius: 7.w,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerContainer(
                              width: 50.w,
                              height: 2.h,
                              borderRadius: 4,
                            ),
                            SizedBox(height: 1.h),
                            _buildShimmerContainer(
                              width: 30.w,
                              height: 1.5.h,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Content skeleton lines
                  ...List.generate(3, (lineIndex) {
                    final widths = [85.w, 75.w, 60.w];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.5.h),
                      child: _buildShimmerContainer(
                        width: widths[lineIndex % widths.length],
                        height: 1.8.h,
                        borderRadius: 4,
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildShimmerContainer({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.lightTheme.colorScheme.surfaceVariant.withOpacity(0.3),
                AppTheme.lightTheme.colorScheme.surfaceVariant.withOpacity(0.6),
                AppTheme.lightTheme.colorScheme.surfaceVariant.withOpacity(0.3),
              ],
              stops: [
                math.max(0.0, _shimmerAnimation.value - 0.3),
                _shimmerAnimation.value,
                math.min(1.0, _shimmerAnimation.value + 0.3),
              ],
            ),
          ),
        );
      },
    );
  }
}
