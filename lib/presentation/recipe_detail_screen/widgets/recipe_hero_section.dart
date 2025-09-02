import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class RecipeHeroSection extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onBack;
  final VoidCallback onSave;
  final bool isSaved;

  const RecipeHeroSection({
    Key? key,
    required this.recipe,
    required this.onBack,
    required this.onSave,
    required this.isSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hero Image
        Container(
          width: double.infinity,
          height: 35.h,
          child: CustomImageWidget(
            imageUrl: recipe['image'] ??
                'https://images.unsplash.com/photo-1546548970-71785318a17b?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3',
            width: double.infinity,
            height: 35.h,
            fit: BoxFit.cover,
          ),
        ),

        // Gradient Overlay
        Container(
          width: double.infinity,
          height: 35.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 6.h,
          left: 4.w,
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              width: 10.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // Save Button
        Positioned(
          top: 6.h,
          right: 4.w,
          child: GestureDetector(
            onTap: onSave,
            child: Container(
              width: 10.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: isSaved ? 'favorite' : 'favorite_border',
                  color: isSaved ? Colors.red : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // Recipe Title and Info
        Positioned(
          bottom: 2.h,
          left: 4.w,
          right: 4.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe['title'] ?? 'Recipe Title',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  _buildInfoChip(
                    icon: 'schedule',
                    text: '${recipe['cookingTime'] ?? 30} min',
                  ),
                  SizedBox(width: 3.w),
                  _buildInfoChip(
                    icon: 'people',
                    text: '${recipe['servings'] ?? 4} servings',
                  ),
                  SizedBox(width: 3.w),
                  _buildDifficultyChip(recipe['difficulty'] ?? 'Medium'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({required String icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 14,
          ),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    Color chipColor;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        chipColor = Colors.green;
        break;
      case 'hard':
        chipColor = Colors.red;
        break;
      default:
        chipColor = Colors.orange;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
