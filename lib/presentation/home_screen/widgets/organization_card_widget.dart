import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OrganizationCardWidget extends StatefulWidget {
  final Map<String, dynamic> organization;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onDirections;
  final VoidCallback? onFavorite;

  const OrganizationCardWidget({
    Key? key,
    required this.organization,
    this.onTap,
    this.onCall,
    this.onDirections,
    this.onFavorite,
  }) : super(key: key);

  @override
  State<OrganizationCardWidget> createState() => _OrganizationCardWidgetState();
}

class _OrganizationCardWidgetState extends State<OrganizationCardWidget>
    with SingleTickerProviderStateMixin {
  bool isFavorited = false;
  bool _expanded = false;
  late final AnimationController _chevController;

  @override
  void initState() {
    super.initState();
    isFavorited = widget.organization["isFavorited"] ?? false;
    _chevController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void dispose() {
    _chevController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });
    widget.onFavorite?.call();
  }

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _chevController.forward();
      } else {
        _chevController.reverse();
      }
    });
  }

  void _openWebsite() {
    final website = widget.organization["website"] as String?;
    if (website != null && website.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Opening website: $website')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No website listed for this organization'),
        ),
      );
    }
  }

  // Ultra compact icon button for maximum space efficiency
  Widget compactIcon({
    required VoidCallback? onPressed,
    required String iconName,
    double size = 18,
    String? tooltip,
  }) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      visualDensity: VisualDensity.compact,
      splashRadius: 15,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: CustomIconWidget(
        iconName: iconName,
        color: DonationAppTheme.lightTheme.colorScheme.onSurface.withValues(
          alpha: 0.7,
        ),
        size: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final org = widget.organization;
    final rating = (org["rating"] as num?)?.toDouble() ?? 0.0;
    final distance = org["distance"] as String? ?? "";
    final currentNeeds =
        (org["currentNeeds"] as List?)?.cast<String>() ?? <String>[];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
      elevation: 1.5,
      shadowColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(2.5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact horizontal layout maximizing space usage
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT: Compact image with rating overlay
                    SizedBox(
                      width: 18.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image with rating overlay in bottom corner
                          Stack(
                            children: [
                              Container(
                                width: 18.w,
                                height: 12.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .surface,
                                  border: Border.all(
                                    color: DonationAppTheme
                                        .lightTheme
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.08),
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CustomImageWidget(
                                    imageUrl: org["logo"] as String? ?? "",
                                    width: 18.w,
                                    height: 12.h,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Rating overlay in bottom-right corner
                              Positioned(
                                bottom: 1.w,
                                right: 1.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 1.5.w,
                                    vertical: 0.3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'star',
                                        color: DonationAppTheme
                                            .lightTheme
                                            .colorScheme
                                            .tertiary,
                                        size: 12,
                                      ),
                                      SizedBox(width: 0.8.w),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: DonationAppTheme
                                            .lightTheme
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 3.w),

                    // RIGHT: Content section with optimized layout
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Name + Favorite button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  org["name"] as String? ??
                                      'Unknown Organization',
                                  style: DonationAppTheme
                                      .lightTheme
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                        letterSpacing: -0.3,
                                        fontSize: 18,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                                visualDensity: VisualDensity.compact,
                                splashRadius: 14,
                                onPressed: _toggleFavorite,
                                icon: CustomIconWidget(
                                  iconName: isFavorited
                                      ? 'favorite'
                                      : 'favorite_border',
                                  color: isFavorited
                                      ? DonationAppTheme
                                            .lightTheme
                                            .colorScheme
                                            .error
                                      : DonationAppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.5),
                                  size: 20,
                                ),
                              ),
                            ],
                          ),

                          // Distance + Action icons + Expand button in one compact row
                          SizedBox(height: 0.8.h),
                          Row(
                            children: [
                              // Distance info (if available)
                              if (distance.isNotEmpty) ...[
                                CustomIconWidget(
                                  iconName: 'location_on',
                                  color: DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .primary,
                                  size: 12,
                                ),
                                SizedBox(width: 0.5.w),
                                Text(
                                  distance,
                                  style: DonationAppTheme
                                      .lightTheme
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: DonationAppTheme
                                            .lightTheme
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 11,
                                      ),
                                ),
                                SizedBox(width: 10.w),
                              ],

                              // Action icons
                              compactIcon(
                                onPressed: widget.onCall,
                                iconName: 'phone',
                                tooltip: 'Call',
                                size: 18,
                              ),
                              SizedBox(width: 0.3.w),
                              compactIcon(
                                onPressed: widget.onDirections,
                                iconName: 'directions',
                                tooltip: 'Directions',
                                size: 18,
                              ),
                              SizedBox(width: 0.3.w),
                              compactIcon(
                                onPressed: _openWebsite,
                                iconName: 'public',
                                tooltip: 'Website',
                                size: 18,
                              ),

                              // Push expand button to the right
                              Spacer(),

                              // Compact expand button
                              GestureDetector(
                                onTap: _toggleExpand,
                                child: RotationTransition(
                                  turns: Tween<double>(begin: 0, end: 0.5)
                                      .animate(
                                        CurvedAnimation(
                                          parent: _chevController,
                                          curve: Curves.easeInOut,
                                        ),
                                      ),
                                  child: Container(
                                    width: 7.w,
                                    height: 3.2.h,
                                    decoration: BoxDecoration(
                                      color: DonationAppTheme
                                          .lightTheme
                                          .colorScheme
                                          .primary,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: DonationAppTheme
                                              .lightTheme
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.15),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: CustomIconWidget(
                                        iconName: 'keyboard_arrow_down',
                                        color: DonationAppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onPrimary,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // EXPANDED CONTENT (animated)
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentNeeds.isNotEmpty) ...[
                          Text(
                            'Current Needs',
                            style: DonationAppTheme
                                .lightTheme
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .primary,
                                ),
                          ),
                          SizedBox(height: 1.h),
                          Wrap(
                            spacing: 2.w,
                            runSpacing: 1.h,
                            children: currentNeeds.take(6).map((need) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 0.8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: DonationAppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.06),
                                  ),
                                ),
                                child: Text(
                                  need,
                                  style: DonationAppTheme
                                      .lightTheme
                                      .textTheme
                                      .bodySmall,
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 2.h),
                        ],
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onCall,
                                icon: CustomIconWidget(
                                  iconName: 'phone',
                                  color: DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .primary,
                                  size: 18,
                                ),
                                label: const Text('Call'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.2.h,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: widget.onDirections,
                                icon: CustomIconWidget(
                                  iconName: 'directions',
                                  color: DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .primary,
                                  size: 18,
                                ),
                                label: const Text('Directions'),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 1.2.h,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            OutlinedButton(
                              onPressed: _openWebsite,
                              child: Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'public',
                                    color: DonationAppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurface,
                                    size: 16,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text('Site'),
                                ],
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                  vertical: 1.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        if ((org['address'] as String?)?.isNotEmpty ?? false)
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'place',
                                color: DonationAppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurface,
                                size: 16,
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Text(
                                  org['address'] as String? ?? '',
                                  style: DonationAppTheme
                                      .lightTheme
                                      .textTheme
                                      .bodySmall,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 280),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
