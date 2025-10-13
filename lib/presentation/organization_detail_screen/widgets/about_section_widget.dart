import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AboutSectionWidget extends StatefulWidget {
  final Map<String, dynamic> organization;

  const AboutSectionWidget({Key? key, required this.organization})
    : super(key: key);

  @override
  State<AboutSectionWidget> createState() => _AboutSectionWidgetState();
}

class _AboutSectionWidgetState extends State<AboutSectionWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.organization['description'] as String;
    final shouldShowExpansion = description.length > 150;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'info_outline',
                  color: DonationAppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'About',
                  style: DonationAppTheme.lightTheme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              shouldShowExpansion && !isExpanded
                  ? '${description.substring(0, 150)}...'
                  : description,
              style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
            if (shouldShowExpansion) ...[
              SizedBox(height: 1.h),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? 'Show Less' : 'Read More',
                  style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                      ?.copyWith(
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
            SizedBox(height: 2.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: (widget.organization['services'] as List).map((
                service,
              ) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: DonationAppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service as String,
                    style: DonationAppTheme.lightTheme.textTheme.bodySmall
                        ?.copyWith(
                          color:
                              DonationAppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
