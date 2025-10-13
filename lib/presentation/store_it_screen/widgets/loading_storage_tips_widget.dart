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
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value * 2 * 3.14159,
                      child: Container(
                        width: 25.w,
                        height: 25.w,
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
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: 'inventory',
                            color: Colors.white,
                            size: 10.w,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          SizedBox(height: 6.h),

          // Loading text with typewriter effect
          Text(
            'Generating Storage Tips',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 2.h),

          Text(
            'Our AI is analyzing your ingredients to provide\npersonalized storage recommendations...',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),

          // Progress indicator
          Container(
            width: 60.w,
            height: 1.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(0.5.h),
            ),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return FractionallySizedBox(
                  widthFactor: (_pulseController.value + 1) / 2,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.lightTheme.colorScheme.primary,
                          AppTheme.lightTheme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(0.5.h),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 6.h),

          // Loading skeleton cards
          _buildSkeletonCards(),
        ],
      ),
    );
  }

  Widget _buildSkeletonCards() {
    return Column(
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(bottom: 3.h),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withOpacity(
                    0.1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header skeleton
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surfaceVariant
                              .withOpacity(_pulseController.value),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Container(
                        width: 40.w,
                        height: 2.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surfaceVariant
                              .withOpacity(_pulseController.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Content skeleton
                  ...List.generate(2, (lineIndex) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 1.h),
                      width: lineIndex == 1 ? 70.w : 80.w,
                      height: 1.5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.surfaceVariant
                            .withOpacity(_pulseController.value * 0.7),
                        borderRadius: BorderRadius.circular(4),
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
}
