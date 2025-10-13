import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OfflineBannerWidget extends StatelessWidget {
  final DateTime lastUpdated;

  const OfflineBannerWidget({Key? key, required this.lastUpdated})
    : super(key: key);

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: DonationAppTheme.lightTheme.colorScheme.tertiary.withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: DonationAppTheme.lightTheme.colorScheme.tertiary.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'wifi_off',
            color: DonationAppTheme.lightTheme.colorScheme.tertiary,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Offline Mode",
                  style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: DonationAppTheme.lightTheme.colorScheme.tertiary,
                      ),
                ),
                Text(
                  "Last updated ${_formatLastUpdated(lastUpdated)}",
                  style: DonationAppTheme.lightTheme.textTheme.bodySmall
                      ?.copyWith(
                        color: DonationAppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
          CustomIconWidget(
            iconName: 'refresh',
            color: DonationAppTheme.lightTheme.colorScheme.tertiary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
