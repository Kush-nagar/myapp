import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class StartCookingBar extends StatelessWidget {
  final VoidCallback onStartCooking;
  final VoidCallback onShare;
  final int completedSteps;
  final int totalSteps;

  const StartCookingBar({
    Key? key,
    required this.onStartCooking,
    required this.onShare,
    required this.completedSteps,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps > 0 ? completedSteps / totalSteps : 0.0;
    final isCompleted = completedSteps == totalSteps && totalSteps > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Indicator
            if (completedSteps > 0) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor.withValues(
                    alpha: 0.05,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: isCompleted ? 'check_circle' : 'schedule',
                      color: isCompleted
                          ? Colors.green
                          : AppTheme.lightTheme.primaryColor,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCompleted
                                ? 'Recipe completed! 🎉'
                                : 'Cooking progress',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w500,
                              color: isCompleted
                                  ? Colors.green
                                  : AppTheme.lightTheme.primaryColor,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? Colors.green
                                  : AppTheme.lightTheme.primaryColor,
                            ),
                            minHeight: 0.5.h,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      '$completedSteps/$totalSteps',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? Colors.green
                            : AppTheme.lightTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
            ],

            // Action Buttons
            Row(
              children: [
                // Share Button
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: onShare,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'share',
                          color: AppTheme.lightTheme.primaryColor,
                          size: 18,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // Start Cooking Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onStartCooking,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      backgroundColor: isCompleted
                          ? Colors.green
                          : AppTheme.lightTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: isCompleted
                              ? 'restaurant'
                              : completedSteps > 0
                              ? 'play_arrow'
                              : 'play_circle_filled',
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          isCompleted
                              ? 'Cook Again'
                              : completedSteps > 0
                              ? 'Continue Cooking'
                              : 'Start Cooking',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
