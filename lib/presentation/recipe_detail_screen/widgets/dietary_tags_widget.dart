import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class DietaryTagsWidget extends StatelessWidget {
  final List<String> tags;

  const DietaryTagsWidget({
    Key? key,
    required this.tags,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Wrap(
        spacing: 2.w,
        runSpacing: 1.h,
        children: tags.map((tag) => _buildDietaryTag(tag)).toList(),
      ),
    );
  }

  Widget _buildDietaryTag(String tag) {
    Color tagColor;
    Color textColor;

    switch (tag.toLowerCase()) {
      case 'vegetarian':
        tagColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green.shade700;
        break;
      case 'vegan':
        tagColor = Colors.green.withValues(alpha: 0.15);
        textColor = Colors.green.shade800;
        break;
      case 'keto':
        tagColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple.shade700;
        break;
      case 'gluten-free':
        tagColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange.shade700;
        break;
      case 'dairy-free':
        tagColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue.shade700;
        break;
      default:
        tagColor = AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1);
        textColor = AppTheme.lightTheme.primaryColor;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: _getTagIcon(tag),
            color: textColor,
            size: 14,
          ),
          SizedBox(width: 1.w),
          Text(
            tag,
            style: TextStyle(
              color: textColor,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTagIcon(String tag) {
    switch (tag.toLowerCase()) {
      case 'vegetarian':
      case 'vegan':
        return 'eco';
      case 'keto':
        return 'fitness_center';
      case 'gluten-free':
        return 'no_meals';
      case 'dairy-free':
        return 'block';
      default:
        return 'local_dining';
    }
  }
}
