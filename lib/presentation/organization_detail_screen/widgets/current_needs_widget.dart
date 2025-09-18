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
  bool isExpanded = false;

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final needs = widget.organization['currentNeeds'] as List;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'priority_high',
                        color: Colors.red,
                        size: 6.w,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Current Needs',
                        style:
                            DonationAppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  CustomIconWidget(
                    iconName: isExpanded ? 'expand_less' : 'expand_more',
                    color: DonationAppTheme.lightTheme.colorScheme.primary,
                    size: 6.w,
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              SizedBox(height: 2.h),
              ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: needs.length,
                separatorBuilder: (context, index) => SizedBox(height: 1.h),
                itemBuilder: (context, index) {
                  final need = needs[index] as Map<String, dynamic>;
                  return Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: DonationAppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getPriorityColor(need['priority'] as String)
                            .withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 1.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color:
                                _getPriorityColor(need['priority'] as String),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      need['item'] as String,
                                      style: DonationAppTheme
                                          .lightTheme.textTheme.bodyLarge
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 2.w, vertical: 0.5.h),
                                    decoration: BoxDecoration(
                                      color: _getPriorityColor(
                                              need['priority'] as String)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      need['priority'] as String,
                                      style: DonationAppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: _getPriorityColor(
                                            need['priority'] as String),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                need['description'] as String,
                                style: DonationAppTheme.lightTheme.textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Quantity needed: ${need['quantity']}',
                                style: DonationAppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      DonationAppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
