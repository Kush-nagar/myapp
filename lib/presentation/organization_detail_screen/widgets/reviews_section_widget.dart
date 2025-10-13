import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReviewsSectionWidget extends StatefulWidget {
  final Map<String, dynamic> organization;

  const ReviewsSectionWidget({Key? key, required this.organization})
    : super(key: key);

  @override
  State<ReviewsSectionWidget> createState() => _ReviewsSectionWidgetState();
}

class _ReviewsSectionWidgetState extends State<ReviewsSectionWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final reviews = widget.organization['reviews'] as List;

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
                        iconName: 'rate_review',
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Reviews (${reviews.length})',
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
            SizedBox(height: 1.h),
            // Rating Summary
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'star',
                  color: Colors.amber,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  '${widget.organization['rating']}',
                  style: DonationAppTheme.lightTheme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 2.w),
                Text(
                  'out of 5',
                  style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
            if (isExpanded) ...[
              SizedBox(height: 2.h),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: reviews.length > 5 ? 5 : reviews.length,
                separatorBuilder: (context, index) => Divider(height: 2.h),
                itemBuilder: (context, index) {
                  final review = reviews[index] as Map<String, dynamic>;
                  return _buildReviewItem(review);
                },
              ),
              if (reviews.length > 5) ...[
                SizedBox(height: 1.h),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Show all reviews in a modal or navigate to reviews page
                    },
                    child: Text(
                      'View All Reviews',
                      style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                          ?.copyWith(
                            color:
                                DonationAppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 4.w,
              backgroundColor: DonationAppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              child: Text(
                (review['userName'] as String).substring(0, 1).toUpperCase(),
                style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                    ?.copyWith(
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review['userName'] as String,
                    style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (starIndex) {
                          return CustomIconWidget(
                            iconName: starIndex < (review['rating'] as int)
                                ? 'star'
                                : 'star_border',
                            color: Colors.amber,
                            size: 4.w,
                          );
                        }),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        review['date'] as String,
                        style: DonationAppTheme.lightTheme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Text(
          review['comment'] as String,
          style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
