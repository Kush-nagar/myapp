// ignore_for_file: unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool isFavorited = false;
  bool _expanded = false;
  late final AnimationController _chevController;

  // Status management
  String _orgStatus = 'Not started';
  static const List<String> _statusOptions = [
    'Not started',
    'In progress',
    'Completed',
  ];
  static const Map<String, Color> _statusColors = {
    'Not started': Color.fromARGB(255, 0, 153, 255),
    'In progress': Color(0xFFFFA726), // amber/orange
    'Completed': Color(0xFF66BB6A), // green
  };

  // Cache for SharedPreferences
  static SharedPreferences? _prefs;
  static Future<SharedPreferences> get _sharedPreferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    isFavorited = widget.organization["isFavorited"] ?? false;
    _chevController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    // Load data asynchronously without blocking build
    _loadDataAsync();
  }

  Future<void> _loadDataAsync() async {
    await Future.wait([_loadOrgStatus(), _loadFavoriteStatus()]);
  }

  @override
  void dispose() {
    _chevController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OrganizationCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reload if organization ID changed
    if (oldWidget.organization['id'] != widget.organization['id']) {
      _loadDataAsync();
    }
  }

  Future<void> _toggleFavorite() async {
    final newFavoriteState = !isFavorited;
    setState(() {
      isFavorited = newFavoriteState;
    });

    // Save to SharedPreferences
    await _saveFavoriteStatus(newFavoriteState);

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

  // Load organization status from SharedPreferences (optimized)
  Future<void> _loadOrgStatus() async {
    final prefs = await _sharedPreferences;
    final orgId =
        widget.organization['id']?.toString() ??
        widget.organization['mockId']?.toString() ??
        '';
    if (orgId.isNotEmpty) {
      final key = 'org_status_$orgId';
      final saved = prefs.getString(key);
      if (saved != null && saved.isNotEmpty && mounted) {
        setState(() {
          _orgStatus = saved;
        });
      }
    }
  }

  // Load favorite status from SharedPreferences (optimized)
  Future<void> _loadFavoriteStatus() async {
    final prefs = await _sharedPreferences;
    final favoriteIds = prefs.getStringList('favorite_organizations') ?? [];
    final orgId =
        widget.organization['id']?.toString() ??
        widget.organization['mockId']?.toString() ??
        '';

    if (orgId.isNotEmpty && mounted) {
      setState(() {
        isFavorited = favoriteIds.contains(orgId);
      });
    }
  }

  // Save favorite status to SharedPreferences (optimized)
  Future<void> _saveFavoriteStatus(bool isFavorite) async {
    final prefs = await _sharedPreferences;
    final favoriteIds = prefs.getStringList('favorite_organizations') ?? [];
    final orgId =
        widget.organization['id']?.toString() ??
        widget.organization['mockId']?.toString() ??
        '';

    if (orgId.isEmpty) return;

    if (isFavorite) {
      if (!favoriteIds.contains(orgId)) {
        favoriteIds.add(orgId);

        // Also save the complete organization data
        final orgDataJson = prefs.getString('favorite_org_data') ?? '{}';
        final Map<String, dynamic> allOrgData = {};
        try {
          allOrgData.addAll(
            Map<String, dynamic>.from(jsonDecode(orgDataJson) as Map),
          );
        } catch (e) {
          debugPrint('Error parsing favorite org data: $e');
        }

        // Store the organization data using its ID as key
        allOrgData[orgId] = {
          'id': widget.organization['id'],
          'mockId': widget.organization['mockId'],
          'placeId': widget.organization['placeId'],
          'name': widget.organization['name'] ?? '',
          'logo':
              widget.organization['logo'] ?? widget.organization['image'] ?? '',
          'image':
              widget.organization['image'] ?? widget.organization['logo'] ?? '',
          'rating': widget.organization['rating'],
          'distance': widget.organization['distance'] ?? '',
          'currentNeeds': widget.organization['currentNeeds'] ?? [],
          'phone': widget.organization['phone'] ?? '',
          'address': widget.organization['address'] ?? '',
          'website': widget.organization['website'] ?? '',
          'contact': widget.organization['contact'] ?? {},
        };

        await prefs.setString('favorite_org_data', jsonEncode(allOrgData));
      }
    } else {
      favoriteIds.remove(orgId);

      // Also remove from stored organization data
      final orgDataJson = prefs.getString('favorite_org_data') ?? '{}';
      try {
        final Map<String, dynamic> allOrgData = Map<String, dynamic>.from(
          jsonDecode(orgDataJson) as Map,
        );
        allOrgData.remove(orgId);
        await prefs.setString('favorite_org_data', jsonEncode(allOrgData));
      } catch (e) {
        debugPrint('Error removing favorite org data: $e');
      }
    }

    await prefs.setStringList('favorite_organizations', favoriteIds);
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
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final org = widget.organization;
    final rating = (org["rating"] as num?)?.toDouble() ?? 0.0;
    final distance = org["distance"] as String? ?? "";
    final currentNeeds =
        (org["currentNeeds"] as List?)?.cast<String>() ?? <String>[];

    return RepaintBoundary(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
        elevation: 1.5,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    _buildImageSection(org, rating),
                    SizedBox(width: 3.w),
                    // RIGHT: Content section with optimized layout
                    Expanded(child: _buildContentSection(org, distance)),
                  ],
                ),

                // EXPANDED CONTENT (animated)
                if (_expanded) _buildExpandedContent(currentNeeds),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(Map<String, dynamic> org, double rating) {
    return SizedBox(
      width: 18.w,
      child: Stack(
        children: [
          Container(
            width: 18.w,
            height: 12.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: DonationAppTheme.lightTheme.colorScheme.surface,
              border: Border.all(
                color: DonationAppTheme.lightTheme.colorScheme.outline
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
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'star',
                    color: DonationAppTheme.lightTheme.colorScheme.tertiary,
                    size: 12,
                  ),
                  SizedBox(width: 0.8.w),
                  Text(
                    rating.toStringAsFixed(1),
                    style: DonationAppTheme.lightTheme.textTheme.bodySmall
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
    );
  }

  Widget _buildContentSection(Map<String, dynamic> org, String distance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Name + Status indicator + Favorite button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Status indicator circle with tooltip
                  Tooltip(
                    message: 'Status: $_orgStatus',
                    child: Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: _statusColors[_orgStatus] ?? Colors.grey,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 0.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      org["name"] as String? ?? 'Unknown Organization',
                      style: DonationAppTheme.lightTheme.textTheme.titleMedium
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
                ],
              ),
            ),
            SizedBox(width: 1.w),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              visualDensity: VisualDensity.compact,
              splashRadius: 14,
              onPressed: _toggleFavorite,
              icon: CustomIconWidget(
                iconName: isFavorited ? 'favorite' : 'favorite_border',
                color: isFavorited
                    ? DonationAppTheme.lightTheme.colorScheme.error
                    : DonationAppTheme.lightTheme.colorScheme.onSurface
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
                color: DonationAppTheme.lightTheme.colorScheme.primary,
                size: 12,
              ),
              SizedBox(width: 0.5.w),
              Text(
                distance,
                style: DonationAppTheme.lightTheme.textTheme.bodySmall
                    ?.copyWith(
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
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
            const Spacer(),

            // Compact expand button
            GestureDetector(
              onTap: _toggleExpand,
              child: RotationTransition(
                turns: Tween<double>(begin: 0, end: 0.5).animate(
                  CurvedAnimation(
                    parent: _chevController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: Container(
                  width: 7.w,
                  height: 3.2.h,
                  decoration: BoxDecoration(
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: DonationAppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.15),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: DonationAppTheme.lightTheme.colorScheme.onPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpandedContent(List<String> currentNeeds) {
    final org = widget.organization;
    return Padding(
      padding: EdgeInsets.only(top: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentNeeds.isNotEmpty) ...[
            Text(
              'Current Needs',
              style: DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: DonationAppTheme.lightTheme.colorScheme.primary,
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
                    color: DonationAppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DonationAppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.06),
                    ),
                  ),
                  child: Text(
                    need,
                    style: DonationAppTheme.lightTheme.textTheme.bodySmall,
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
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                  label: const Text('Call'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.2.h),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onDirections,
                  icon: CustomIconWidget(
                    iconName: 'directions',
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    size: 18,
                  ),
                  label: const Text('Directions'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.2.h),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              OutlinedButton(
                onPressed: _openWebsite,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'public',
                      color: DonationAppTheme.lightTheme.colorScheme.onSurface,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    const Text('Site'),
                  ],
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
                  color: DonationAppTheme.lightTheme.colorScheme.onSurface,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    org['address'] as String? ?? '',
                    style: DonationAppTheme.lightTheme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
