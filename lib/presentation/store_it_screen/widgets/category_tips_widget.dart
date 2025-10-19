import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class CategoryTipsWidget extends StatelessWidget {
  final String category;
  final List<String> tips;

  const CategoryTipsWidget({
    Key? key,
    required this.category,
    required this.tips,
  }) : super(key: key);

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return 'eco';
      case 'fruits':
        return 'apple';
      case 'proteins':
        return 'fitness_center';
      case 'grains':
        return 'grain';
      case 'herbs':
        return 'local_florist';
      case 'dairy':
        return 'water_drop';
      default:
        return 'category';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Colors.green;
      case 'fruits':
        return Colors.orange;
      case 'proteins':
        return Colors.red;
      case 'grains':
        return Colors.brown;
      case 'herbs':
        return Colors.teal;
      case 'dairy':
        return Colors.blue;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getCategoryTitle(String category) {
    if (category.isEmpty) return '';
    return category[0].toUpperCase() + category.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();

    final categoryColor = _getCategoryColor(category);
    final maxCardWidth = 900.0; // prevents extreme wide stretch on large screens

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxCardWidth),
        child: Container(
          margin: EdgeInsets.only(bottom: 3.h),
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    categoryColor.withOpacity(0.05),
                    categoryColor.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.08),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.5.w),
                          decoration: BoxDecoration(
                            color: categoryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Semantics(
                            label: '${_getCategoryTitle(category)} icon',
                            child: CustomIconWidget(
                              iconName: _getCategoryIcon(category),
                              color: Colors.white,
                              size: 6.w,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getCategoryTitle(category),
                                style: AppTheme.lightTheme.textTheme.titleLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: categoryColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'Storage Guidelines',
                                style: AppTheme
                                    .lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: categoryColor.withOpacity(0.8),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tips content
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      children: tips.asMap().entries.map((entry) {
                        final tip = entry.value;

                        return Container(
                          margin: EdgeInsets.only(bottom: 2.h),
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: categoryColor.withOpacity(0.12),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: categoryColor.withOpacity(0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 2.8.w,
                                height: 2.8.w,
                                margin: EdgeInsets.only(top: 0.6.h, right: 3.w),
                                decoration: BoxDecoration(
                                  color: categoryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(height: 1.45),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
