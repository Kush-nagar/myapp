import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraControlsWidget extends StatelessWidget {
  final VoidCallback onCapturePhoto;
  final VoidCallback onGalleryTap;
  final VoidCallback onFlashToggle;
  final VoidCallback onCameraFlip;
  final VoidCallback onManualEntry;
  final FlashMode currentFlashMode;
  final XFile? recentPhoto;
  final bool isLoading;

  const CameraControlsWidget({
    Key? key,
    required this.onCapturePhoto,
    required this.onGalleryTap,
    required this.onFlashToggle,
    required this.onCameraFlip,
    required this.onManualEntry,
    required this.currentFlashMode,
    this.recentPhoto,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 23.6.h,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
        ),
      ),
      child: Column(
        children: [
          // Manual entry button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onManualEntry,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.primaryColor.withValues(
                  alpha: 0.2,
                ),
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              ),
              child: Text(
                'Manual Entry',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Main controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Flash toggle
              _buildControlButton(
                onTap: onFlashToggle,
                child: CustomIconWidget(
                  iconName: _getFlashIconName(),
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
              // Gallery thumbnail
              _buildGalleryButton(),
              // Capture button
              _buildCaptureButton(),
              // Camera flip
              _buildControlButton(
                onTap: onCameraFlip,
                child: CustomIconWidget(
                  iconName: 'flip_camera_ios',
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
              // Spacer for symmetry
              SizedBox(width: 12.w),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: onGalleryTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: recentPhoto != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(1.5.w),
                child: CustomImageWidget(
                  imageUrl: recentPhoto!.path,
                  width: 12.w,
                  height: 12.w,
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: CustomIconWidget(
                  iconName: 'photo_library',
                  color: Colors.white,
                  size: 6.w,
                ),
              ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onCapturePhoto();
      },
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.lightTheme.primaryColor, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: isLoading
            ? Center(
                child: SizedBox(
                  width: 6.w,
                  height: 6.w,
                  child: CircularProgressIndicator(
                    color: AppTheme.lightTheme.primaryColor,
                    strokeWidth: 2,
                  ),
                ),
              )
            : Center(
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
      ),
    );
  }

  String _getFlashIconName() {
    switch (currentFlashMode) {
      case FlashMode.off:
        return 'flash_off';
      case FlashMode.auto:
        return 'flash_auto';
      case FlashMode.always:
        return 'flash_on';
      case FlashMode.torch:
        return 'flashlight_on';
      }
  }
}
