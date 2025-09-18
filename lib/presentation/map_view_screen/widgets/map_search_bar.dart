import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MapSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback? onFilterTap;

  const MapSearchBar({
    Key? key,
    required this.onSearch,
    this.onFilterTap,
  }) : super(key: key);

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: DonationAppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search locations...',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'search',
                    color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                suffixIcon: _isSearching
                    ? GestureDetector(
                        onTap: _clearSearch,
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: DonationAppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                hintStyle: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
              onChanged: (value) {
                setState(() {
                  _isSearching = value.isNotEmpty;
                });
                widget.onSearch(value);
              },
              onSubmitted: (value) {
                widget.onSearch(value);
                _focusNode.unfocus();
              },
            ),
          ),
          Container(
            width: 1,
            height: 6.h,
            color:
                DonationAppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          GestureDetector(
            onTap: widget.onFilterTap,
            child: Container(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'tune',
                color: DonationAppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    widget.onSearch('');
    _focusNode.unfocus();
  }
}
