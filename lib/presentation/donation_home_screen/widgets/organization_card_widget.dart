import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrganizationCardWidget extends StatefulWidget {
  final Map<String, dynamic> organization;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onDirections;
  final VoidCallback? onFavorite;

  const OrganizationCardWidget({
    Key? key,
    required this.organization,
    this.onTap,
    this.onCall,
    this.onDirections,
    this.onFavorite,
  }) : super(key: key);

  @override
  State<OrganizationCardWidget> createState() => _OrganizationCardWidgetState();
}

class _OrganizationCardWidgetState extends State<OrganizationCardWidget> {
  bool isFavorited = false;

  @override
  void initState() {
    super.initState();
    isFavorited = widget.organization["isFavorited"] ?? false;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });
    widget.onFavorite?.call();
  }

  Widget _buildRatingStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return CustomIconWidget(
          iconName: index < rating.floor() ? 'star' : 'star_border',
          color: DonationAppTheme.lightTheme.colorScheme.tertiary,
          size: 16,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final organization = widget.organization;
    final rating = (organization["rating"] as num?)?.toDouble() ?? 0.0;
    final distance = organization["distance"] as String? ?? "0.0 mi";
    final currentNeeds =
        (organization["currentNeeds"] as List?)?.cast<String>() ?? [];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: DonationAppTheme.lightTheme.colorScheme.surface,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomImageWidget(
                        imageUrl: organization["logo"] as String? ?? "",
                        width: 15.w,
                        height: 15.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          organization["name"] as String? ??
                              "Unknown Organization",
                          style: DonationAppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            _buildRatingStars(rating),
                            SizedBox(width: 2.w),
                            Text(
                              rating.toStringAsFixed(1),
                              style: DonationAppTheme.lightTheme.textTheme.bodySmall,
                            ),
                            SizedBox(width: 3.w),
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: DonationAppTheme.lightTheme.colorScheme.primary,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              distance,
                              style: DonationAppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: DonationAppTheme.lightTheme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleFavorite,
                    icon: CustomIconWidget(
                      iconName: isFavorited ? 'favorite' : 'favorite_border',
                      color: isFavorited
                          ? DonationAppTheme.lightTheme.colorScheme.error
                          : DonationAppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                      size: 24,
                    ),
                  ),
                ],
              ),
              if (currentNeeds.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  "Current Needs:",
                  style: DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: currentNeeds.take(3).map((need) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: DonationAppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        need,
                        style:
                            DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: DonationAppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onCall,
                      icon: CustomIconWidget(
                        iconName: 'phone',
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        size: 18,
                      ),
                      label: Text("Call"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onDirections,
                      icon: CustomIconWidget(
                        iconName: 'directions',
                        color: DonationAppTheme.lightTheme.colorScheme.primary,
                        size: 18,
                      ),
                      label: Text("Directions"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
