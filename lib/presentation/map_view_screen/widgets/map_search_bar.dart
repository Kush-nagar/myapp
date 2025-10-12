// lib/screens/map_view/widgets/map_search_bar.dart

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
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _hasText = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(() {});
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
                // Show clear icon when text exists
                suffixIcon: _hasText
                    ? GestureDetector(
                        onTap: _clearSearch,
                        child: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'close',
                            color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                hintStyle: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
              // Do NOT call widget.onSearch here — only update UI state
              onChanged: (value) {
                // just updates _hasText via controller listener
              },
              // Perform search only when user presses Enter/Submit
              onSubmitted: (value) {
                _performSearch();
              },
              textInputAction: TextInputAction.search,
            ),
          ),

          // Vertical divider
          Container(
            width: 1,
            height: 6.h,
            color: DonationAppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),

          // Search button (explicit)
          GestureDetector(
            onTap: _performSearch,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
              child: CustomIconWidget(
                iconName: 'search',
                color: DonationAppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ),
          ),

          // Filter button
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

  void _performSearch() {
    final query = _searchController.text.trim();
    // Unfocus keyboard
    _focusNode.unfocus();
    widget.onSearch(query);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _hasText = false;
    });
    // tell parent to reset results
    widget.onSearch('');
    _focusNode.unfocus();
  }
}