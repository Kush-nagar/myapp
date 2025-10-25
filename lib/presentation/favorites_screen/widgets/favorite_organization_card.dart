import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FavoriteOrganizationCard extends StatelessWidget {
  final Map<String, dynamic> organization;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onShare;
  final VoidCallback onCall;
  final VoidCallback onDirections;
  final VoidCallback onWebsite;
  final bool isSelected;
  final VoidCallback? onLongPress;

  const FavoriteOrganizationCard({
    Key? key,
    required this.organization,
    required this.onTap,
    required this.onRemove,
    required this.onShare,
    required this.onCall,
    required this.onDirections,
    required this.onWebsite,
    this.isSelected = false,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(organization['id']),
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onRemove(),
              backgroundColor: DonationAppTheme.lightTheme.colorScheme.error,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Remove',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onShare(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: 'Share',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? DonationAppTheme.lightTheme.primaryColor.withValues(
                      alpha: 0.1,
                    )
                  : (isDark
                        ? DonationAppTheme.cardDark
                        : DonationAppTheme.cardLight),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: DonationAppTheme.lightTheme.primaryColor,
                      width: 2,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: (isDark
                      ? DonationAppTheme.shadowDark
                      : DonationAppTheme.shadowLight),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
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
                          color:
                              DonationAppTheme.lightTheme.colorScheme.surface,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CustomImageWidget(
                            imageUrl:
                                organization['image'] ??
                                organization['logo'] ??
                                '',
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
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    organization['name'] ??
                                        'Unknown Organization',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: organization['isOpen'] == true
                                        ? DonationAppTheme.getSuccessColor(
                                            true,
                                          ).withValues(alpha: 0.1)
                                        : DonationAppTheme.getWarningColor(
                                            true,
                                          ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    organization['isOpen'] == true
                                        ? 'Open'
                                        : 'Closed',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: organization['isOpen'] == true
                                              ? DonationAppTheme.getSuccessColor(
                                                  true,
                                                )
                                              : DonationAppTheme.getWarningColor(
                                                  true,
                                                ),
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'location_on',
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${organization['distance']} away',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                SizedBox(width: 3.w),
                                CustomIconWidget(
                                  iconName: 'access_time',
                                  size: 14,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                                SizedBox(width: 1.w),
                                Expanded(
                                  child: Text(
                                    'Last visit: ${organization['lastVisit'] ?? 'Never'}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          icon: 'phone',
                          label: 'Call',
                          onTap: onCall,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          icon: 'directions',
                          label: 'Directions',
                          onTap: onDirections,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: _buildActionButton(
                          context: context,
                          icon: 'language',
                          label: 'Website',
                          onTap: onWebsite,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: DonationAppTheme.lightTheme.primaryColor.withValues(
            alpha: 0.1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 20,
              color: DonationAppTheme.lightTheme.primaryColor,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: DonationAppTheme.lightTheme.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
