import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final Function() onVoiceSearch;
  final Function() onClear;
  final List<String> recentSearches;
  final Function(String) onRecentSearchTap;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onVoiceSearch,
    required this.onClear,
    required this.recentSearches,
    required this.onRecentSearchTap,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _showRecentSearches = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _showRecentSearches =
            _focusNode.hasFocus && widget.recentSearches.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 6.h,
          decoration: BoxDecoration(
            color: DonationAppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: DonationAppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search organizations, food types...',
              hintStyle: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.all(2.w),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: widget.onClear,
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: CustomIconWidget(
                          iconName: 'clear',
                          color:
                              DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 5.w,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: widget.onVoiceSearch,
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: CustomIconWidget(
                        iconName: 'mic',
                        color: DonationAppTheme.lightTheme.primaryColor,
                        size: 5.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                ],
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            ),
          ),
        ),
        if (_showRecentSearches) ...[
          SizedBox(height: 1.h),
          Container(
            constraints: BoxConstraints(maxHeight: 20.h),
            decoration: BoxDecoration(
              color: DonationAppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: DonationAppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.recentSearches.length > 5
                  ? 5
                  : widget.recentSearches.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: DonationAppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
              ),
              itemBuilder: (context, index) {
                final search = widget.recentSearches[index];
                return ListTile(
                  dense: true,
                  leading: CustomIconWidget(
                    iconName: 'history',
                    color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 4.w,
                  ),
                  title: Text(
                    search,
                    style: DonationAppTheme.lightTheme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    widget.onRecentSearchTap(search);
                    setState(() {
                      _showRecentSearches = false;
                    });
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
