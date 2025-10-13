import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DonationGuidelinesWidget extends StatefulWidget {
  final Map<String, dynamic> organization;

  const DonationGuidelinesWidget({Key? key, required this.organization})
    : super(key: key);

  @override
  State<DonationGuidelinesWidget> createState() =>
      _DonationGuidelinesWidgetState();
}

class _DonationGuidelinesWidgetState extends State<DonationGuidelinesWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final guidelines =
        widget.organization['donationGuidelines'] as Map<String, dynamic>;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'rule',
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Donation Guidelines',
                        style: DonationAppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              SizedBox(height: 2.h),
              // Accepted Items
              _buildGuidelineSection(
                'Accepted Items',
                'check_circle',
                Colors.green,
                guidelines['acceptedItems'] as List,
              ),
              SizedBox(height: 2.h),
              // Restrictions
              _buildGuidelineSection(
                'Restrictions',
                'cancel',
                Colors.red,
                guidelines['restrictions'] as List,
              ),
              SizedBox(height: 2.h),
              // Drop-off Procedures
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: DonationAppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'local_shipping',
                          color:
                              DonationAppTheme.lightTheme.colorScheme.primary,
                          size: 5.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Drop-off Procedures',
                          style: DonationAppTheme.lightTheme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    ...(guidelines['procedures'] as List).asMap().entries.map((
                      entry,
                    ) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 0.5.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key + 1}. ',
                              style: DonationAppTheme
                                  .lightTheme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Expanded(
                              child: Text(
                                entry.value as String,
                                style: DonationAppTheme
                                    .lightTheme
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineSection(
    String title,
    String iconName,
    Color color,
    List items,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(iconName: iconName, color: color, size: 5.w),
              SizedBox(width: 2.w),
              Text(
                title,
                style: DonationAppTheme.lightTheme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: items.map((item) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item as String,
                  style: DonationAppTheme.lightTheme.textTheme.bodySmall
                      ?.copyWith(color: color, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
