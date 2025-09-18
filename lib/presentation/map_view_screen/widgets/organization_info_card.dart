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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: DonationAppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        organization['name'] as String? ??
                            'Unknown Organization',
                        style:
                            DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'star',
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${organization['rating'] ?? 0.0}',
                            style: DonationAppTheme.lightTheme.textTheme.bodySmall,
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: 'location_on',
                            color: DonationAppTheme.lightTheme.colorScheme.primary,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Flexible(
                            child: Text(
                              '${organization['distance'] ?? 0.0} km',
                              style: DonationAppTheme.lightTheme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                            organization['type'] as String? ?? 'food_bank')
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getTypeLabel(
                        organization['type'] as String? ?? 'food_bank'),
                    style: DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getTypeColor(
                          organization['type'] as String? ?? 'food_bank'),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            if (organization['currentNeeds'] != null &&
                (organization['currentNeeds'] as String).isNotEmpty)
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: DonationAppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: DonationAppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Needs',
                      style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      organization['currentNeeds'] as String,
                      style: DonationAppTheme.lightTheme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: CustomIconWidget(
                      iconName: 'phone',
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
                      size: 18,
                    ),
                    label: Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDirections,
                    icon: CustomIconWidget(
                      iconName: 'directions',
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
                      size: 18,
                    ),
                    label: Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    child: Text('Details'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'food_bank':
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
    switch (type) {
      case 'food_bank':
        return 'Food Bank';
      case 'shelter':
        return 'Shelter';
      case 'restaurant':
        return 'Restaurant';
      default:
        return 'Organization';
    }
  }
}
