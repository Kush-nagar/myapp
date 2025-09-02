import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';

import '../../../core/app_export.dart';

class CapturedImageHeaderWidget extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onRetake;

  const CapturedImageHeaderWidget({
    Key? key,
    this.imagePath,
    required this.onRetake,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline,
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: imagePath != null
                  ? Image.file(
                      File(imagePath!),
                      width: 20.w,
                      height: 20.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme
                              .lightTheme
                              .colorScheme
                              .surfaceContainerHighest,
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'broken_image',
                              color: AppTheme.lightTheme.colorScheme.error,
                              size: 8.w,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppTheme
                          .lightTheme
                          .colorScheme
                          .surfaceContainerHighest,
                      child: Center(
                        child: CustomIconWidget(
                          iconName: 'image',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 8.w,
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Captured Image',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Analyzing ingredients...',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onRetake,
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: Colors.white,
              size: 4.w,
            ),
            label: Text(
              'Retake',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
