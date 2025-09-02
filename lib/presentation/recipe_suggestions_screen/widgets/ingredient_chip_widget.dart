import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class IngredientChipWidget extends StatelessWidget {
  final String ingredient;
  final VoidCallback onRemove;

  const IngredientChipWidget({
    Key? key,
    required this.ingredient,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      child: Chip(
        label: Text(
          ingredient,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
              ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
        deleteIcon: CustomIconWidget(
          iconName: 'close',
          color: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
          size: 4.w,
        ),
        onDeleted: onRemove,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
