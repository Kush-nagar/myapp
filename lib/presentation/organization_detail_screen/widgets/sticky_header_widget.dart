import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StickyHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> organization;
  final bool isVisible;

  const StickyHeaderWidget({
    Key? key,
    required this.organization,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: isVisible ? 12.h : 0,
      child: isVisible
          ? Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: DonationAppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              organization['name'] as String,
                              style: DonationAppTheme
                                  .lightTheme
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'star',
                                  color: Colors.amber,
                                  size: 4.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${organization['rating']}',
                                  style: DonationAppTheme
                                      .lightTheme
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(width: 3.w),
                                CustomIconWidget(
                                  iconName: 'location_on',
                                  color: DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .primary,
                                  size: 4.w,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${organization['distance']} away',
                                  style: DonationAppTheme
                                      .lightTheme
                                      .textTheme
                                      .bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
