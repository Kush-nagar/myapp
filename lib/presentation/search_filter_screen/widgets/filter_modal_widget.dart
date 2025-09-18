import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterModalWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;
  final Function() onClearFilters;

  const FilterModalWidget({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late Map<String, dynamic> _tempFilters;
  int _resultCount = 0;

  @override
  void initState() {
    super.initState();
    _tempFilters = Map<String, dynamic>.from(widget.currentFilters);
    _calculateResultCount();
  }

  void _calculateResultCount() {
    // Mock calculation based on filters
    int baseCount = 45;

    if (_tempFilters['organizationType'] != null &&
        (_tempFilters['organizationType'] as List).isNotEmpty) {
      baseCount = (baseCount * 0.7).round();
    }
    if (_tempFilters['donationTypes'] != null &&
        (_tempFilters['donationTypes'] as List).isNotEmpty) {
      baseCount = (baseCount * 0.8).round();
    }
    if (_tempFilters['distance'] != null && _tempFilters['distance'] > 0) {
      baseCount = (baseCount * 0.6).round();
    }
    if (_tempFilters['openNow'] == true) {
      baseCount = (baseCount * 0.4).round();
    }
    if (_tempFilters['highRating'] == true) {
      baseCount = (baseCount * 0.7).round();
    }

    setState(() {
      _resultCount = baseCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      decoration: BoxDecoration(
        color: DonationAppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: DonationAppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: DonationAppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _tempFilters.clear();
                          _calculateResultCount();
                        });
                      },
                      child: Text(
                        'Clear All',
                        style:
                            DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: DonationAppTheme.lightTheme.primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        size: 6.w,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrganizationTypeSection(),
                  SizedBox(height: 3.h),
                  _buildDonationTypesSection(),
                  SizedBox(height: 3.h),
                  _buildDistanceSection(),
                  SizedBox(height: 3.h),
                  _buildOperatingHoursSection(),
                  SizedBox(height: 3.h),
                  _buildRatingSection(),
                ],
              ),
            ),
          ),

          // Apply button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: DonationAppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApplyFilters(_tempFilters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text(
                  'Show $_resultCount Results',
                  style: DonationAppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationTypeSection() {
    final List<String> types = [
      'Food Bank',
      'Shelter',
      'Restaurant',
      'Community Center'
    ];
    final List<String> selectedTypes =
        (_tempFilters['organizationType'] as List?)?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organization Type',
          style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: types.map((type) {
            final isSelected = selectedTypes.contains(type);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedTypes.remove(type);
                  } else {
                    selectedTypes.add(type);
                  }
                  _tempFilters['organizationType'] = selectedTypes;
                  _calculateResultCount();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DonationAppTheme.lightTheme.primaryColor
                      : DonationAppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? DonationAppTheme.lightTheme.primaryColor
                        : DonationAppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  type,
                  style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDonationTypesSection() {
    final List<String> types = [
      'Canned Goods',
      'Fresh Produce',
      'Prepared Meals',
      'Dairy Products',
      'Baked Goods'
    ];
    final List<String> selectedTypes =
        (_tempFilters['donationTypes'] as List?)?.cast<String>() ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Donation Types Accepted',
          style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: types.map((type) {
            final isSelected = selectedTypes.contains(type);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedTypes.remove(type);
                  } else {
                    selectedTypes.add(type);
                  }
                  _tempFilters['donationTypes'] = selectedTypes;
                  _calculateResultCount();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DonationAppTheme.lightTheme.primaryColor
                      : DonationAppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? DonationAppTheme.lightTheme.primaryColor
                        : DonationAppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  type,
                  style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    final List<double> distances = [1, 5, 10, 25];
    final double selectedDistance = _tempFilters['distance'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distance Radius',
          style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: distances.map((distance) {
            final isSelected = selectedDistance == distance;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _tempFilters['distance'] = isSelected ? 0 : distance;
                  _calculateResultCount();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? DonationAppTheme.lightTheme.primaryColor
                      : DonationAppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? DonationAppTheme.lightTheme.primaryColor
                        : DonationAppTheme.lightTheme.colorScheme.outline
                            .withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${distance.toInt()} mile${distance > 1 ? 's' : ''}',
                  style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? Colors.white
                        : DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOperatingHoursSection() {
    final bool openNow = _tempFilters['openNow'] ?? false;
    final bool weekendHours = _tempFilters['weekendHours'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Operating Hours',
          style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Column(
          children: [
            _buildSwitchTile(
              'Open Now',
              openNow,
              (value) {
                setState(() {
                  _tempFilters['openNow'] = value;
                  _calculateResultCount();
                });
              },
            ),
            _buildSwitchTile(
              'Weekend Hours',
              weekendHours,
              (value) {
                setState(() {
                  _tempFilters['weekendHours'] = value;
                  _calculateResultCount();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    final bool highRating = _tempFilters['highRating'] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ratings',
          style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        _buildSwitchTile(
          '4+ Stars',
          highRating,
          (value) {
            setState(() {
              _tempFilters['highRating'] = value;
              _calculateResultCount();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: DonationAppTheme.lightTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
