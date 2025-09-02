import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class IngredientsSection extends StatefulWidget {
  final List<Map<String, dynamic>> ingredients;
  final Function(int, bool) onIngredientToggle;
  final Function(String) onAddToShoppingList;

  const IngredientsSection({
    Key? key,
    required this.ingredients,
    required this.onIngredientToggle,
    required this.onAddToShoppingList,
  }) : super(key: key);

  @override
  State<IngredientsSection> createState() => _IngredientsSectionState();
}

class _IngredientsSectionState extends State<IngredientsSection> {
  List<bool> checkedIngredients = [];

  @override
  void initState() {
    super.initState();
    checkedIngredients =
        List.generate(widget.ingredients.length, (index) => false);
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
                'Ingredients',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.ingredients.length} items',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.ingredients.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final ingredient = widget.ingredients[index];
              final isChecked = checkedIngredients[index];
              final isMissing = ingredient['available'] == false;

              return _buildIngredientItem(
                ingredient: ingredient,
                index: index,
                isChecked: isChecked,
                isMissing: isMissing,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientItem({
    required Map<String, dynamic> ingredient,
    required int index,
    required bool isChecked,
    required bool isMissing,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          checkedIngredients[index] = !checkedIngredients[index];
        });
        widget.onIngredientToggle(index, checkedIngredients[index]);
      },
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isChecked
              ? AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isMissing
                ? Colors.red.withValues(alpha: 0.3)
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color: isChecked
                    ? AppTheme.lightTheme.primaryColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isChecked
                      ? AppTheme.lightTheme.primaryColor
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? Center(
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 14,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 3.w),

            // Ingredient Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient['name'] ?? 'Ingredient',
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                      color: isChecked
                          ? AppTheme.lightTheme.colorScheme.onSurfaceVariant
                          : isMissing
                              ? Colors.red.shade700
                              : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (ingredient['amount'] != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      ingredient['amount'],
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        decoration:
                            isChecked ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Missing Ingredient Action
            if (isMissing && !isChecked) ...[
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: () =>
                    widget.onAddToShoppingList(ingredient['name'] ?? ''),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'add_shopping_cart',
                        color: Colors.red.shade700,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
