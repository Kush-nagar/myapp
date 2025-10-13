import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptySearchWidget extends StatelessWidget {
  final String searchQuery;
  final Function(String) onSuggestionTap;

  const EmptySearchWidget({
    Key? key,
    required this.searchQuery,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> suggestions = [
      'food bank',
      'shelter',
      'canned goods',
      'fresh produce',
      'prepared meals',
      'community center',
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'search_off',
            color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant
                .withValues(alpha: 0.5),
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            searchQuery.isEmpty
                ? 'Start typing to search organizations'
                : 'No results found for "$searchQuery"',
            style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          if (searchQuery.isNotEmpty) ...[
            Text(
              'Try adjusting your search or filters',
              style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            Text(
              'Popular searches:',
              style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map(
                    (suggestion) => GestureDetector(
                      onTap: () => onSuggestionTap(suggestion),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: DonationAppTheme.lightTheme.primaryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: DonationAppTheme.lightTheme.primaryColor
                                .withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          suggestion,
                          style: DonationAppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                color: DonationAppTheme.lightTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ] else ...[
            SizedBox(height: 2.h),
            Text(
              'Search for organizations by name, type, or donation categories',
              style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
