// current_needs_widget.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CurrentNeedsWidget extends StatefulWidget {
  final Map<String, dynamic> organization;

  const CurrentNeedsWidget({
    Key? key,
    required this.organization,
  }) : super(key: key);

  @override
  State<CurrentNeedsWidget> createState() => _CurrentNeedsWidgetState();
}

class _CurrentNeedsWidgetState extends State<CurrentNeedsWidget> {
  late final List<Map<String, dynamic>> _needs;
  late List<bool> _expanded;

  @override
  void initState() {
    super.initState();

    final raw = widget.organization['currentNeeds'];
    if (raw is List) {
      // Normalize each element to a map to avoid type errors
      _needs = raw.map((e) {
        if (e is Map<String, dynamic>) return e;
        // If item is something else, try to coerce
        return <String, dynamic>{
          'item': e?.toString() ?? 'Unknown Item',
          'priority': 'medium',
          'description': '',
          'quantity': ''
        };
      }).toList();
    } else {
      _needs = [];
    }

    // Expansion state
    _expanded = List<bool>.filled(_needs.length, false);
  }

  Color _priorityColor(String? priority) {
    switch ((priority ?? '').toLowerCase()) {
      case 'urgent':
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return DonationAppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _priorityLabel(String? priority) {
    if (priority == null) return 'Medium';
    final p = priority.toString().toLowerCase();
    if (p == 'urgent' || p == 'high') return 'Urgent';
    if (p == 'medium') return 'Medium';
    if (p == 'low') return 'Low';
    return priority.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_needs.isEmpty) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Needs',
              style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'No current needs listed for this organization.',
              style: DonationAppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Needs',
                  style: DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_needs.length} item${_needs.length > 1 ? 's' : ''}',
                  style: DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: DonationAppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // List of needs as ExpansionTiles. Using Column with children prevents nested
          // unbounded ListView issues inside other scrollables.
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Column(
              children: List.generate(_needs.length, (index) {
                final need = _needs[index];
                final item = need['item']?.toString() ?? 'Unnamed Item';
                final priority = need['priority']?.toString() ?? 'medium';
                final description = need['description']?.toString() ?? '';
                final quantity = need['quantity']?.toString() ?? '';

                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  decoration: BoxDecoration(
                    color: DonationAppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: DonationAppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.12),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ExpansionTile(
                      key: PageStorageKey('need_$index\_$item'),
                      initiallyExpanded: _expanded[index],
                      onExpansionChanged: (v) {
                        setState(() {
                          _expanded[index] = v;
                        });
                      },
                      tilePadding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 1.2.h),
                      collapsedShape: RoundedRectangleBorder(),
                      childrenPadding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      leading: Container(
                        constraints: BoxConstraints(minWidth: 16.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.8.h),
                        decoration: BoxDecoration(
                          color: _priorityColor(priority).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _priorityLabel(priority).toUpperCase(),
                          style:
                              DonationAppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: _priorityColor(priority),
                            fontWeight: FontWeight.w700,
                            fontSize: 9.sp,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              item,
                              style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (quantity.isNotEmpty) ...[
                            SizedBox(width: 2.w),
                            Flexible(
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 25.w),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.5.w, vertical: 0.6.h),
                                decoration: BoxDecoration(
                                  color: DonationAppTheme.lightTheme.colorScheme.primary
                                      .withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  quantity,
                                  style: DonationAppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color:
                                        DonationAppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      children: [
                        if (description.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: DonationAppTheme
                                  .lightTheme.colorScheme.surfaceVariant
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              description,
                              style: DonationAppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: DonationAppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          SizedBox(height: 1.5.h),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                // Optional: navigate to donation flow / contact
                                final contact = widget.organization['contact']
                                    as Map<String, dynamic>?;
                                final phone = contact?['phone']?.toString();
                                if (phone != null && phone.isNotEmpty) {
                                  // Try to launch call from parent code; here we just show a snack
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Call ${widget.organization['name']} at $phone',
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Contact not available'),
                                    ),
                                  );
                                }
                              },
                              icon: CustomIconWidget(
                                iconName:
                                    'volunteer_activism', // change to an icon name you use
                                color: DonationAppTheme.lightTheme.colorScheme.primary,
                                size: 16,
                              ),
                              label: Text(
                                'Help / Donate',
                                style: DonationAppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      DonationAppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
