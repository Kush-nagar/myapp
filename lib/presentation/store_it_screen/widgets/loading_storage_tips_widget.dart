import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class LoadingStorageTipsWidget extends StatefulWidget {
  const LoadingStorageTipsWidget({Key? key}) : super(key: key);

  @override
  State<LoadingStorageTipsWidget> createState() =>
      _LoadingStorageTipsWidgetState();
}

class _LoadingStorageTipsWidgetState extends State<LoadingStorageTipsWidget>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final AnimationController _fadeController;
  late final AnimationController _shimmerController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _fadeAnimation = Tween<double>(begin: 0.35, end: 1.0).animate(
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
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
              padding: EdgeInsets.symmetric(
                horizontal: 5.w,
                vertical: isSmallScreen ? 2.h : 4.h,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: isSmallScreen ? 2.h : 4.h),

                  // Animated icon
                  _buildAnimatedLoadingIcon(),

                  SizedBox(height: isSmallScreen ? 4.h : 6.h),

                  // Loading text
                  _buildLoadingText(),

                  SizedBox(height: isSmallScreen ? 3.h : 4.h),

                  // Progress indicator
                  _buildProgressIndicator(),

                  SizedBox(height: isSmallScreen ? 4.h : 6.h),

                  // Loading tips
                  _buildLoadingTips(),

                  SizedBox(height: isSmallScreen ? 4.h : 6.h),

                  // Skeletons
                  _buildEnhancedSkeletonCards(),
                ],
              ),
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
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary.withOpacity(0.10),
                      AppTheme.lightTheme.colorScheme.primary.withOpacity(0.03),
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
                      0.14,
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
                        AppTheme.lightTheme.colorScheme.primary.withOpacity(0.2),
                        AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.35, 0.75, 1.0],
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
              scale: _pulseAnimation.value * 0.92,
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
                          .withOpacity(0.28),
                      blurRadius: 22,
                      spreadRadius: 6,
                      offset: const Offset(0, 4),
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
                  letterSpacing: 0.3,
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
            'Our AI is analyzing your ingredients to provide personalized storage recommendations.',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              height: 1.45,
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
                  final delay = index * 0.25;
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
                          .withOpacity(0.25 + (opacity * 0.65)),
                    ),
                  );
                },
              );
            }),
          ),

          SizedBox(height: 3.h),

          // Linear progress bar with shimmer
          Container(
            width: 70.w,
            height: 1.2.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(0.8.h),
            ),
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Stack(children: [
                  // background progress fill
                  FractionallySizedBox(
                    widthFactor: 0.68,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightTheme.colorScheme.primary.withOpacity(0.28),
                            AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.20),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(0.8.h),
                      ),
                    ),
                  ),
                  // shimmer overlay
                  Positioned(
                    left: _shimmerAnimation.value * 70.w * 0.5,
                    child: Container(
                      width: 18.w,
                      height: 1.2.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.35),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(0.8.h),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingTips() {
    final tips = [
      "Analyzing ingredient freshness patterns",
      "Calculating optimal temperature zones",
      "Determining best storage durations",
      "Processing nutritional data",
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          final currentTipIndex =
              (_fadeAnimation.value * tips.length).floor() % tips.length;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            child: Container(
              key: ValueKey(currentTipIndex),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.08),
                ),
              ),
              child: Text(
                tips[currentTipIndex],
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
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
            final widths = [85.w, 70.w, 60.w];

            return Container(
              margin: EdgeInsets.only(bottom: 3.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // header skeleton
                  Row(
                    children: [
                      _buildShimmerContainer(width: 14.w, height: 14.w, radius: 12),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildShimmerContainer(width: 50.w, height: 2.h, radius: 6),
                            SizedBox(height: 1.h),
                            _buildShimmerContainer(width: 30.w, height: 1.4.h, radius: 6),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  // content skeleton lines
                  ...List.generate(3, (i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.6.h),
                      child: _buildShimmerContainer(
                        width: widths[i % widths.length],
                        height: 1.8.h,
                        radius: 6,
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
    required double radius,
  }) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final stop = _shimmerAnimation.value.clamp(0.0, 1.0);
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppTheme.lightTheme.colorScheme.surfaceVariant.withOpacity(0.28),
                AppTheme.lightTheme.colorScheme.surfaceVariant.withOpacity(0.55),
                AppTheme.lightTheme.colorScheme.surfaceVariant.withOpacity(0.28),
              ],
              stops: [
                (stop - 0.25).clamp(0.0, 1.0),
                stop,
                (stop + 0.25).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
