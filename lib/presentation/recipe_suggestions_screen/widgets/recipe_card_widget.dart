import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecipeCardWidget extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const RecipeCardWidget({
    Key? key,
    required this.recipe,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matchPercentage = (recipe['matchPercentage'] as num).toInt();
    final availableIngredients =
        (recipe['availableIngredients'] as num).toInt();
    final totalIngredients = (recipe['totalIngredients'] as num).toInt();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CustomImageWidget(
                    imageUrl: recipe['image'] as String,
                    width: double.infinity,
                    height: 20.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2.h,
                  right: 3.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getMatchColor(matchPercentage),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$matchPercentage% Match',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'access_time',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${recipe['cookingTime']} min',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      SizedBox(width: 4.w),
                      CustomIconWidget(
                        iconName: 'bar_chart',
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 4.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        recipe['difficulty'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ingredients Available',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            SizedBox(height: 0.5.h),
                            LinearProgressIndicator(
                              value: availableIngredients / totalIngredients,
                              backgroundColor: AppTheme
                                  .lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getMatchColor(matchPercentage),
                              ),
                              minHeight: 1.h,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '$availableIngredients/$totalIngredients',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: _getMatchColor(matchPercentage),
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMatchColor(int percentage) {
    if (percentage >= 80) return AppTheme.successLight;
    if (percentage >= 60) return AppTheme.secondaryLight;
    return AppTheme.errorLight;
  }
}
