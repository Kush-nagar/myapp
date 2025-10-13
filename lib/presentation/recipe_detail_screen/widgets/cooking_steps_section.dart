import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CookingStepsSection extends StatefulWidget {
  final List<Map<String, dynamic>> steps;
  final Function(int, bool) onStepToggle;

  const CookingStepsSection({
    Key? key,
    required this.steps,
    required this.onStepToggle,
  }) : super(key: key);

  @override
  State<CookingStepsSection> createState() => _CookingStepsSectionState();
}

class _CookingStepsSectionState extends State<CookingStepsSection> {
  List<bool> completedSteps = [];

  @override
  void initState() {
    super.initState();
    completedSteps = List.generate(widget.steps.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cooking Steps',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${completedSteps.where((step) => step).length}/${widget.steps.length}',
                  style: TextStyle(
                    color: AppTheme.lightTheme.primaryColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.steps.length,
            separatorBuilder: (context, index) => SizedBox(height: 2.h),
            itemBuilder: (context, index) {
              final step = widget.steps[index];
              final isCompleted = completedSteps[index];

              return _buildStepItem(
                step: step,
                index: index,
                isCompleted: isCompleted,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required Map<String, dynamic> step,
    required int index,
    required bool isCompleted,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          completedSteps[index] = !completedSteps[index];
        });
        widget.onStepToggle(index, completedSteps[index]);
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.2,
                  ),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step Number/Checkbox
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isCompleted
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 16,
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 4.w),

            // Step Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['instruction'] ?? 'Step instruction',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: isCompleted
                          ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                  if (step['duration'] != null) ...[
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${step['duration']} minutes',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                      ],
                    ),
                  ],
                  if (step['tip'] != null) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomIconWidget(
                            iconName: 'lightbulb',
                            color: Colors.amber.shade700,
                            size: 14,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              step['tip'],
                              style: TextStyle(
                                color: Colors.amber.shade800,
                                fontSize: 11.sp,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
