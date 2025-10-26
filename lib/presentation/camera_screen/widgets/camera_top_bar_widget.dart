import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraTopBarWidget extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback onSettingsPressed;
  final bool showBackButton;

  const CameraTopBarWidget({
    Key? key,
    this.onBackPressed,
    required this.onSettingsPressed,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12.h,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 1.h,
        left: 4.w,
        right: 4.w,
        bottom: 1.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button or spacer
          showBackButton
              ? GestureDetector(
                  onTap: onBackPressed,
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),
                  ),
                )
              : SizedBox(width: 10.w),
          // App title
          Text(
            'SavR',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Settings button
          GestureDetector(
            onTap: onSettingsPressed,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'settings',
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
