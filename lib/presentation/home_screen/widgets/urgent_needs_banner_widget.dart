import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/donation_app_theme.dart';

class UrgentNeedsBannerWidget extends StatelessWidget {
  const UrgentNeedsBannerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> urgentNeeds = [
      {
        "id": 1,
        "organization": "Downtown Food Bank",
        "need": "Fresh produce needed urgently",
        "timeLeft": "2 hours",
        "priority": "high",
      },
      {
        "id": 2,
        "organization": "Community Kitchen",
        "need": "Canned goods for weekend meals",
        "timeLeft": "6 hours",
        "priority": "medium",
      },
      {
        "id": 3,
        "organization": "Shelter Hope",
        "need": "Baby formula and diapers",
        "timeLeft": "4 hours",
        "priority": "high",
      },
    ];

    return Container(
      height: 12.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: urgentNeeds.length,
        separatorBuilder: (context, index) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          final need = urgentNeeds[index];
          final isHighPriority = need["priority"] == "high";

          return Container(
            width: 75.w,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isHighPriority
                  ? DonationAppTheme.lightTheme.colorScheme.error.withValues(
                      alpha: 0.1,
                    )
                  : DonationAppTheme.lightTheme.colorScheme.tertiary.withValues(
                      alpha: 0.1,
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHighPriority
                    ? DonationAppTheme.lightTheme.colorScheme.error
                    : DonationAppTheme.lightTheme.colorScheme.tertiary,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 2.w,
                      height: 2.w,
                      decoration: BoxDecoration(
                        color: isHighPriority
                            ? DonationAppTheme.lightTheme.colorScheme.error
                            : DonationAppTheme.lightTheme.colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        need["organization"] as String,
                        style: DonationAppTheme.lightTheme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      need["timeLeft"] as String,
                      style: DonationAppTheme.lightTheme.textTheme.bodySmall
                          ?.copyWith(
                            color: isHighPriority
                                ? DonationAppTheme.lightTheme.colorScheme.error
                                : DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .tertiary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                Text(
                  need["need"] as String,
                  style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
