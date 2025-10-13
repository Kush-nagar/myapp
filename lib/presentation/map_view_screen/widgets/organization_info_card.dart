import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrganizationInfoCard extends StatelessWidget {
  final Map<String, dynamic> organization;
  final VoidCallback? onCall;
  final VoidCallback? onDirections;
  final VoidCallback? onViewDetails;

  const OrganizationInfoCard({
    Key? key,
    required this.organization,
    this.onCall,
    this.onDirections,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = DonationAppTheme.lightTheme;
    final String name =
        organization['name'] as String? ?? 'Unknown Organization';
    final double rating = (organization['rating'] as num?)?.toDouble() ?? 0.0;
    final dynamic distanceRaw = organization['distance'];
    final String distanceLabel = distanceRaw == null
        ? ''
        : (distanceRaw is String
              ? distanceRaw
              : '${distanceRaw.toString()} mi');
    final String typeKey = (organization['type'] as String?) ?? 'organization';
    final String currentNeeds =
        (organization['currentNeeds'] as String?)?.trim() ?? '';
    final String imageUrl = (organization['image'] as String?) ?? '';

    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 2.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top row: thumbnail + title + type chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                _buildThumbnail(imageUrl),

                SizedBox(width: 3.w),

                // Title + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 0.8.h),

                      // Meta row: rating, dot, distance
                      Row(
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'star',
                                color: Colors.amber,
                                size: 14,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                rating.toStringAsFixed(1),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(width: 3.w),

                          if (distanceLabel.isNotEmpty) ...[
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: theme.colorScheme.primary,
                              size: 14,
                            ),
                            SizedBox(width: 1.w),
                            Flexible(
                              child: Text(
                                distanceLabel,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],

                          const Spacer(),

                          // Type chip
                          _TypeChip(typeKey: typeKey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            // Needs / short description
            if (currentNeeds.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.1.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomIconWidget(
                      iconName: 'inventory_2',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        currentNeeds,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )
            else
              // subtle placeholder line if no needs provided
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  organization['operatingHours'] as String? ?? '',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ),

            SizedBox(height: 2.h),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: CustomIconWidget(
                      iconName: 'phone',
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    label: Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.4.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDirections,
                    icon: CustomIconWidget(
                      iconName: 'directions',
                      color: theme.colorScheme.primary,
                      size: 16,
                    ),
                    label: Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.4.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                SizedBox(
                  width: 28.w,
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'chevron_right',
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text('Details'),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.3.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(String imageUrl) {
    final double size = 16.w;
    if (imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: DonationAppTheme.lightTheme.colorScheme.primary.withValues(
            alpha: 0.08,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'store',
            color: DonationAppTheme.lightTheme.colorScheme.primary,
            size: 28,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomImageWidget(imageUrl: imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String typeKey;
  const _TypeChip({Key? key, required this.typeKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = DonationAppTheme.lightTheme;
    final label = _getTypeLabel(typeKey);
    final color = _getTypeColor(typeKey).withValues(alpha: 1.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 9.sp,
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'food_bank':
      case 'food pantry':
      case 'food_pantry':
        return Colors.blue;
      case 'shelter':
        return Colors.green;
      case 'restaurant':
        return Colors.orange;
      default:
        return DonationAppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'food_bank':
      case 'food pantry':
      case 'food_pantry':
        return 'Food Bank';
      case 'shelter':
        return 'Shelter';
      case 'restaurant':
        return 'Restaurant';
      default:
        final cleaned = type.replaceAll('_', ' ');
        return cleaned[0].toUpperCase() +
            (cleaned.length > 1 ? cleaned.substring(1) : '');
    }
  }
}
