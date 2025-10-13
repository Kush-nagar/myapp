import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrganizationHeaderWidget extends StatelessWidget {
  final Map<String, dynamic> organization;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onShare;

  const OrganizationHeaderWidget({
    Key? key,
    required this.organization,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35.h,
      child: Stack(
        children: [
          // Hero Image
          Container(
            width: double.infinity,
            height: 35.h,
            child: CustomImageWidget(
              imageUrl: organization['image'] as String,
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
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          // Top Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: CustomIconWidget(
                          iconName: 'arrow_back',
                          color: Colors.white,
                          size: 6.w,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onShare,
                          child: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CustomIconWidget(
                              iconName: 'share',
                              color: Colors.white,
                              size: 6.w,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Container(
                            width: 10.w,
                            height: 10.w,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: CustomIconWidget(
                              iconName: isFavorite
                                  ? 'favorite'
                                  : 'favorite_border',
                              color: isFavorite ? Colors.red : Colors.white,
                              size: 6.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Organization Info at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    organization['name'] as String,
                    style: DonationAppTheme.lightTheme.textTheme.headlineMedium
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'star',
                        color: Colors.amber,
                        size: 5.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${organization['rating']}',
                        style: DonationAppTheme.lightTheme.textTheme.bodyLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(width: 4.w),
                      CustomIconWidget(
                        iconName: 'location_on',
                        color: Colors.white,
                        size: 5.w,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${organization['distance']} away',
                        style: DonationAppTheme.lightTheme.textTheme.bodyLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
