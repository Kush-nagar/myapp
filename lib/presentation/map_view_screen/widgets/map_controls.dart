import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapControls extends StatelessWidget {
  final VoidCallback? onCurrentLocation;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onMapTypeToggle;
  final String currentMapType;

  const MapControls({
    Key? key,
    this.onCurrentLocation,
    this.onZoomIn,
    this.onZoomOut,
    this.onMapTypeToggle,
    this.currentMapType = 'normal',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 4.w,
      bottom: 20.h,
      child: Column(
        children: [
          // Map Type Toggle
          Container(
            decoration: BoxDecoration(
              color: DonationAppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onMapTypeToggle,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName:
                            currentMapType == 'satellite' ? 'map' : 'satellite',
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        currentMapType == 'satellite' ? 'Map' : 'Satellite',
                        style:
                            DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Zoom Controls
          Container(
            decoration: BoxDecoration(
              color: DonationAppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onZoomIn,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'add',
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 1,
                  color: DonationAppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onZoomOut,
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(8)),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'remove',
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Current Location Button
          Container(
            decoration: BoxDecoration(
              color: DonationAppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onCurrentLocation,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'my_location',
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
