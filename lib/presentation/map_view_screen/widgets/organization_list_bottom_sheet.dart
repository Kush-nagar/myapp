import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrganizationListBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> organizations;
  final Function(Map<String, dynamic>) onOrganizationTap;
  final VoidCallback? onClose;

  const OrganizationListBottomSheet({
    Key? key,
    required this.organizations,
    required this.onOrganizationTap,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: DonationAppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Column(
              children: [
                Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: DonationAppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Organizations in Area',
                      style:
                          DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: DonationAppTheme.lightTheme.colorScheme.onSurface,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: organizations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'location_off',
                          color: DonationAppTheme.lightTheme.colorScheme.outline,
                          size: 48,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'No organizations found in this area',
                          style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: DonationAppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    itemCount: organizations.length,
                    separatorBuilder: (context, index) => SizedBox(height: 1.h),
                    itemBuilder: (context, index) {
                      final organization = organizations[index];
                      return GestureDetector(
                        onTap: () => onOrganizationTap(organization),
                        child: Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: DonationAppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: DonationAppTheme.lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12.w,
                                height: 12.w,
                                decoration: BoxDecoration(
                                  color: _getTypeColor(
                                          organization['type'] as String? ??
                                              'food_bank')
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: _getTypeIcon(
                                        organization['type'] as String? ??
                                            'food_bank'),
                                    color: _getTypeColor(
                                        organization['type'] as String? ??
                                            'food_bank'),
                                    size: 24,
                                  ),
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      organization['name'] as String? ??
                                          'Unknown Organization',
                                      style: DonationAppTheme
                                          .lightTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Row(
                                      children: [
                                        CustomIconWidget(
                                          iconName: 'star',
                                          color: Colors.amber,
                                          size: 14,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          '${organization['rating'] ?? 0.0}',
                                          style: DonationAppTheme
                                              .lightTheme.textTheme.bodySmall,
                                        ),
                                        SizedBox(width: 3.w),
                                        CustomIconWidget(
                                          iconName: 'location_on',
                                          color: DonationAppTheme
                                              .lightTheme.colorScheme.primary,
                                          size: 14,
                                        ),
                                        SizedBox(width: 1.w),
                                        Flexible(
                                          child: Text(
                                            '${organization['distance'] ?? 0.0} km',
                                            style: DonationAppTheme
                                                .lightTheme.textTheme.bodySmall,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              CustomIconWidget(
                                iconName: 'chevron_right',
                                color: DonationAppTheme.lightTheme.colorScheme.outline,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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

  String _getTypeIcon(String type) {
    switch (type) {
      case 'food_bank':
        return 'store';
      case 'shelter':
        return 'home';
      case 'restaurant':
        return 'restaurant';
      default:
        return 'location_on';
    }
  }
}
