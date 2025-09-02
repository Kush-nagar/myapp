import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SortBottomSheetWidget extends StatelessWidget {
  final String selectedSort;
  final Function(String) onSortSelected;

  const SortBottomSheetWidget({
    Key? key,
    required this.selectedSort,
    required this.onSortSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'key': 'match', 'label': 'Best Match', 'icon': 'star'},
      {'key': 'time', 'label': 'Cooking Time', 'icon': 'access_time'},
      {'key': 'difficulty', 'label': 'Difficulty', 'icon': 'bar_chart'},
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Sort By',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 2.h),
          ...sortOptions
              .map((option) => ListTile(
                    leading: CustomIconWidget(
                      iconName: option['icon'] as String,
                      color: selectedSort == option['key']
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 6.w,
                    ),
                    title: Text(
                      option['label'] as String,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: selectedSort == option['key']
                                ? AppTheme.lightTheme.colorScheme.primary
                                : AppTheme.lightTheme.colorScheme.onSurface,
                            fontWeight: selectedSort == option['key']
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                    ),
                    trailing: selectedSort == option['key']
                        ? CustomIconWidget(
                            iconName: 'check',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 5.w,
                          )
                        : null,
                    onTap: () {
                      onSortSelected(option['key'] as String);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
