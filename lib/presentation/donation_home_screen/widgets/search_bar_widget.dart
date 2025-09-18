import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatelessWidget {
  final String currentLocation;
  final VoidCallback? onSearchTap;
  final VoidCallback? onLocationTap;

  const SearchBarWidget({
    Key? key,
    required this.currentLocation,
    this.onSearchTap,
    this.onLocationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: DonationAppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: DonationAppTheme.lightTheme.colorScheme.shadow,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              readOnly: true,
              onTap: onSearchTap,
              decoration: InputDecoration(
                hintText: "Search food banks, shelters...",
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: DonationAppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                    size: 24,
                  ),
                ),
                suffixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'tune',
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: DonationAppTheme.lightTheme.colorScheme.surface,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'location_on',
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Flexible(
                    child: Text(
                      currentLocation,
                      style: DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 1.w),
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
