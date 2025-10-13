import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class IngredientChipWidget extends StatelessWidget {
  final String ingredientName;
  final double confidence;
  final VoidCallback onRemove;
  final VoidCallback? onLongPress;

  const IngredientChipWidget({
    Key? key,
    required this.ingredientName,
    required this.confidence,
    required this.onRemove,
    this.onLongPress,
  }) : super(key: key);

  Color _getConfidenceColor() {
    if (confidence >= 0.8) {
      return AppTheme
          .lightTheme
          .colorScheme
          .tertiary; // Green for high confidence
    } else if (confidence >= 0.5) {
      return AppTheme
          .lightTheme
          .colorScheme
          .secondary; // Amber for medium confidence
    } else {
      return AppTheme.lightTheme.colorScheme.error; // Red for low confidence
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: _getConfidenceColor().withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _getConfidenceColor(), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 3.w,
              height: 3.w,
              decoration: BoxDecoration(
                color: _getConfidenceColor(),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Flexible(
              child: Text(
                ingredientName,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: _getConfidenceColor(),
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '${(confidence * 100).toInt()}%',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: _getConfidenceColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: EdgeInsets.all(0.5.w),
                decoration: BoxDecoration(
                  color: _getConfidenceColor().withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: _getConfidenceColor(),
                  size: 4.w,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
