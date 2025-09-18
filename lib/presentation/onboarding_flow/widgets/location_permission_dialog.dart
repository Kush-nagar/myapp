import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllowLocation;
  final VoidCallback onManualEntry;

  const LocationPermissionDialog({
    Key? key,
    required this.onAllowLocation,
    required this.onManualEntry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: DonationAppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'location_on',
                color: DonationAppTheme.lightTheme.colorScheme.primary,
                size: 8.w,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Enable Location Access',
              style: DonationAppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: DonationAppTheme.lightTheme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'We use your location to find nearby food donation organizations and provide personalized recommendations. Your privacy is protected.',
              style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: onAllowLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DonationAppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: DonationAppTheme.lightTheme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Allow Location Access',
                  style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: DonationAppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: OutlinedButton(
                onPressed: onManualEntry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: DonationAppTheme.lightTheme.colorScheme.primary,
                  side: BorderSide(
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Enter ZIP Code Manually',
                  style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
