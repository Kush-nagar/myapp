import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrganizationCardWidget extends StatelessWidget {
  final Map<String, dynamic> organization;
  final Function() onTap;
  final Function() onFavorite;

  const OrganizationCardWidget({
    Key? key,
    required this.organization,
    required this.onTap,
    required this.onFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isFavorite = organization['isFavorite'] ?? false;
    final double rating = (organization['rating'] ?? 0.0).toDouble();
    final List<String> donationTypes =
        (organization['donationTypes'] as List?)?.cast<String>() ?? [];
    final bool isOpenNow = organization['isOpenNow'] ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: DonationAppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DonationAppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: CustomImageWidget(
                    imageUrl: organization['image'] ?? '',
                    width: double.infinity,
                    height: 20.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2.h,
                  right: 3.w,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CustomIconWidget(
                        iconName: isFavorite ? 'favorite' : 'favorite_border',
                        color: isFavorite
                            ? Colors.red
                            : DonationAppTheme
                                  .lightTheme
                                  .colorScheme
                                  .onSurfaceVariant,
                        size: 5.w,
                      ),
                    ),
                  ),
                ),
                if (isOpenNow)
                  Positioned(
                    top: 2.h,
                    left: 3.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: DonationAppTheme.getSuccessColor(true),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Open Now',
                        style: DonationAppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and type
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              organization['name'] ?? '',
                              style: DonationAppTheme
                                  .lightTheme
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              organization['type'] ?? '',
                              style: DonationAppTheme
                                  .lightTheme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: DonationAppTheme
                                        .lightTheme
                                        .primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 2.w),
                      // Rating
                      if (rating > 0)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: DonationAppTheme.getAccentColor(
                              true,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'star',
                                color: DonationAppTheme.getAccentColor(true),
                                size: 3.5.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                rating.toStringAsFixed(1),
                                style: DonationAppTheme
                                    .lightTheme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: DonationAppTheme.getAccentColor(
                                        true,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Address and distance
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: DonationAppTheme
                            .lightTheme
                            .colorScheme
                            .onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          organization['address'] ?? '',
                          style: DonationAppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                color: DonationAppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (organization['distance'] != null) ...[
                        SizedBox(width: 2.w),
                        Text(
                          '${organization['distance']} mi',
                          style: DonationAppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                color: DonationAppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 1.h),

                  // Operating hours
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: DonationAppTheme
                            .lightTheme
                            .colorScheme
                            .onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        organization['hours'] ?? 'Hours not available',
                        style: DonationAppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: DonationAppTheme
                                  .lightTheme
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),

                  if (donationTypes.isNotEmpty) ...[
                    SizedBox(height: 1.5.h),
                    Wrap(
                      spacing: 1.w,
                      runSpacing: 0.5.h,
                      children: donationTypes
                          .take(3)
                          .map(
                            (type) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.5.h,
                              ),
                              decoration: BoxDecoration(
                                color: DonationAppTheme
                                    .lightTheme
                                    .colorScheme
                                    .surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                type,
                                style: DonationAppTheme
                                    .lightTheme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: DonationAppTheme
                                          .lightTheme
                                          .colorScheme
                                          .onSurfaceVariant,
                                      fontSize: 10.sp,
                                    ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],

                  if (organization['urgentNeed'] == true) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.8.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.red.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'priority_high',
                            color: Colors.red,
                            size: 4.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Urgent Need',
                            style: DonationAppTheme
                                .lightTheme
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
