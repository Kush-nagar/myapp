import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipsWidget extends StatelessWidget {
  final Map<String, dynamic> activeFilters;
  final Function(String, String) onRemoveFilter;
  final Function() onClearAll;

  const FilterChipsWidget({
    Key? key,
    required this.activeFilters,
    required this.onRemoveFilter,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (activeFilters.isEmpty) return SizedBox.shrink();

    List<Widget> chips = [];
    int totalFilters = 0;

    // Count total active filters
    activeFilters.forEach((category, value) {
      if (value is List && (value).isNotEmpty) {
        totalFilters += (value).length;
      } else if (value is String && value.isNotEmpty) {
        totalFilters += 1;
      } else if (value is bool && value == true) {
        totalFilters += 1;
      } else if (value is double && value > 0) {
        totalFilters += 1;
      }
    });

    // Build filter chips
    activeFilters.forEach((category, value) {
      if (value is List && (value).isNotEmpty) {
        for (String item in value) {
          chips.add(_buildFilterChip(category, item));
        }
      } else if (value is String && value.isNotEmpty) {
        chips.add(_buildFilterChip(category, value));
      } else if (value is bool && value == true) {
        chips
            .add(_buildFilterChip(category, _getCategoryDisplayName(category)));
      } else if (value is double && value > 0) {
        chips.add(_buildFilterChip(category, '${value.toInt()} miles'));
      }
    });

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$totalFilters filter${totalFilters > 1 ? 's' : ''} applied',
                style: DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (totalFilters > 0)
                GestureDetector(
                  onTap: onClearAll,
                  child: Text(
                    'Clear All',
                    style: DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: DonationAppTheme.lightTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: chips,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String category, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: DonationAppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DonationAppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: DonationAppTheme.lightTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 1.w),
          GestureDetector(
            onTap: () => onRemoveFilter(category, value),
            child: CustomIconWidget(
              iconName: 'close',
              color: DonationAppTheme.lightTheme.primaryColor,
              size: 3.5.w,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'openNow':
        return 'Open Now';
      case 'weekendHours':
        return 'Weekend Hours';
      case 'highRating':
        return '4+ Stars';
      default:
        return category;
    }
  }
}
