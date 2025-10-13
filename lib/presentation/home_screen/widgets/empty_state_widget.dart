import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onExpandSearch;

  const EmptyStateWidget({Key? key, this.onExpandSearch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: DonationAppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'location_searching',
                  color: DonationAppTheme.lightTheme.colorScheme.primary,
                  size: 60,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "No Organizations Nearby",
              style: DonationAppTheme.lightTheme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              "We couldn't find any food donation organizations in your immediate area. Try expanding your search radius to discover more opportunities to help.",
              style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: DonationAppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: onExpandSearch,
              icon: CustomIconWidget(
                iconName: 'zoom_out_map',
                color: DonationAppTheme.lightTheme.colorScheme.onPrimary,
                size: 20,
              ),
              label: Text("Expand Search Radius"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              ),
            ),
            SizedBox(height: 2.h),
            TextButton(
              onPressed: () {
                // Navigate to search screen
                Navigator.pushNamed(context, '/search-filter-screen');
              },
              child: Text("Search Different Location"),
            ),
          ],
        ),
      ),
    );
  }
}
