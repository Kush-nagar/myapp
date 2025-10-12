import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortOptionsBottomSheet extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;

  const SortOptionsBottomSheet({
    Key? key,
    required this.currentSort,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'key': 'recent', 'title': 'Recently Added', 'icon': 'schedule'},
      {'key': 'distance', 'title': 'Distance', 'icon': 'location_on'},
      {'key': 'alphabetical', 'title': 'Alphabetical', 'icon': 'sort_by_alpha'},
      {'key': 'last_visited', 'title': 'Last Visited', 'icon': 'history'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Text(
                  'Sort by',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      size: 20,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          ...sortOptions.map((option) => _buildSortOption(
                context: context,
                key: option['key'] as String,
                title: option['title'] as String,
                icon: option['icon'] as String,
                isSelected: currentSort == option['key'],
              )),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildSortOption({
    required BuildContext context,
    required String key,
    required String title,
    required String icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        onSortChanged(key);
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? DonationAppTheme.lightTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: DonationAppTheme.lightTheme.primaryColor, width: 1)
              : null,
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 24,
              color: isSelected
                  ? DonationAppTheme.lightTheme.primaryColor
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isSelected
                          ? DonationAppTheme.lightTheme.primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check',
                size: 20,
                color: DonationAppTheme.lightTheme.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
