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
    return Column(
      children: [
        // Search Bar
        Container(
          height: 7.5.h,
          decoration: BoxDecoration(
            color: DonationAppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: Offset(0, 1),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: DonationAppTheme.lightTheme.colorScheme.outline
                  .withOpacity(0.08),
              width: 1,
            ),
          ),
          child: TextField(
            readOnly: true,
            onTap: onSearchTap,
            style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: "Search food banks, shelters...",
              hintStyle: DonationAppTheme.lightTheme.textTheme.bodyMedium
                  ?.copyWith(
                    color: DonationAppTheme.lightTheme.colorScheme.onSurface
                        .withOpacity(0.6),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
              prefixIcon: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: 4.w, right: 3.w),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: DonationAppTheme.lightTheme.colorScheme.onSurface
                      .withOpacity(0.6),
                  size: 22,
                ),
              ),
              suffixIcon: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 4.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onSearchTap,
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: CustomIconWidget(
                        iconName: 'tune',
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: DonationAppTheme.lightTheme.colorScheme.primary
                      .withOpacity(0.3),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: DonationAppTheme.lightTheme.colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            ),
          ),
        ),

        // Location Button
        SizedBox(height: 1.5.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onLocationTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
              decoration: BoxDecoration(
                color: DonationAppTheme.lightTheme.colorScheme.primary
                    .withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: DonationAppTheme.lightTheme.colorScheme.primary
                      .withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'location_on',
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Flexible(
                    child: Text(
                      currentLocation,
                      style: DonationAppTheme.lightTheme.textTheme.bodySmall
                          ?.copyWith(
                            color:
                                DonationAppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 1.5.w),
                  Container(
                    padding: EdgeInsets.all(1),
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
