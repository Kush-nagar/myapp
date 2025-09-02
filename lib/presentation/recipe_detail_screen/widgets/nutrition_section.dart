import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NutritionSection extends StatefulWidget {
  final Map<String, dynamic> nutrition;

  const NutritionSection({
    Key? key,
    required this.nutrition,
  }) : super(key: key);

  @override
  State<NutritionSection> createState() => _NutritionSectionState();
}

class _NutritionSectionState extends State<NutritionSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'restaurant',
                        color: AppTheme.lightTheme.primaryColor,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Nutrition Information',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),

          // Nutrition Content
          if (isExpanded) ...[
            Divider(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
              height: 1,
            ),
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Calories Summary
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'local_fire_department',
                          color: Colors.orange.shade600,
                          size: 24,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '${widget.nutrition['calories'] ?? 0}',
                          style: AppTheme.lightTheme.textTheme.headlineMedium
                              ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          'calories',
                          style:
                              AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Macronutrients
                  _buildNutrientRow(
                    'Protein',
                    widget.nutrition['protein'] ?? 0,
                    'g',
                    Colors.blue,
                    50, // Daily value reference
                  ),
                  SizedBox(height: 2.h),
                  _buildNutrientRow(
                    'Carbohydrates',
                    widget.nutrition['carbs'] ?? 0,
                    'g',
                    Colors.green,
                    300,
                  ),
                  SizedBox(height: 2.h),
                  _buildNutrientRow(
                    'Fat',
                    widget.nutrition['fat'] ?? 0,
                    'g',
                    Colors.orange,
                    65,
                  ),
                  SizedBox(height: 2.h),
                  _buildNutrientRow(
                    'Fiber',
                    widget.nutrition['fiber'] ?? 0,
                    'g',
                    Colors.purple,
                    25,
                  ),
                  SizedBox(height: 2.h),
                  _buildNutrientRow(
                    'Sugar',
                    widget.nutrition['sugar'] ?? 0,
                    'g',
                    Colors.red,
                    50,
                  ),
                  SizedBox(height: 3.h),

                  // Daily Value Note
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '* Percent Daily Values are based on a 2,000 calorie diet',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutrientRow(
    String name,
    dynamic value,
    String unit,
    Color color,
    int dailyValue,
  ) {
    final numValue =
        (value is String) ? double.tryParse(value) ?? 0.0 : value.toDouble();
    final percentage = (numValue / dailyValue * 100).clamp(0.0, 100.0);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  '${numValue.toStringAsFixed(1)}$unit',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          height: 0.8.h,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
