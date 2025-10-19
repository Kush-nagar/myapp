import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class StorageTipCardWidget extends StatefulWidget {
  final Map<String, dynamic> tipData;

  const StorageTipCardWidget({Key? key, required this.tipData})
      : super(key: key);

  @override
  State<StorageTipCardWidget> createState() => _StorageTipCardWidgetState();
}

class _StorageTipCardWidgetState extends State<StorageTipCardWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _animationController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  String _getStorageIcon(String? storageMethod) {
    if (storageMethod == null) return 'inventory';
    final method = storageMethod.toLowerCase();
    if (method.contains('refrigerat') || method.contains('fridge')) {
      return 'ac_unit';
    } else if (method.contains('freez')) {
      return 'ac_unit';
    } else if (method.contains('room') || method.contains('counter')) {
      return 'room';
    } else if (method.contains('pantry')) {
      return 'kitchen';
    }
    return 'inventory';
  }

  Color _getPriorityColor(String? shelfLife) {
    if (shelfLife == null || shelfLife.isEmpty) {
      return AppTheme.lightTheme.colorScheme.primary;
    }
    final life = shelfLife.toLowerCase();
    if (life.contains('day') &&
        !life.contains('week') &&
        !life.contains('month')) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (life.contains('week')) {
      return AppTheme.lightTheme.colorScheme.secondary;
    }
    return AppTheme.lightTheme.colorScheme.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    final ingredient = widget.tipData['ingredient'] ?? 'Unknown';
    final storageMethod = widget.tipData['storageMethod'] ?? '';
    final location = widget.tipData['location'] ?? '';
    final container = widget.tipData['container'] ?? '';
    final shelfLife = widget.tipData['shelfLife'] ?? '';
    final tips = List<String>.from(widget.tipData['tips'] ?? []);
    final preparation = widget.tipData['preparation'] ?? '';
    final signs = widget.tipData['signs'] ?? {};
    final freshnessSigns = List<String>.from(signs['freshness'] ?? []);
    final spoilageSigns = List<String>.from(signs['spoilage'] ?? []);

    final priorityColor = _getPriorityColor(shelfLife);
    final maxCardWidth = 900.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxCardWidth),
        child: Container(
          margin: EdgeInsets.only(bottom: 3.h),
          child: Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.lightTheme.colorScheme.surface,
                    AppTheme.lightTheme.colorScheme.surface.withOpacity(0.98),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Header
                  InkWell(
                    onTap: _toggleExpansion,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        children: [
                          // Storage icon
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Semantics(
                              label: 'Storage icon',
                              child: CustomIconWidget(
                                iconName: _getStorageIcon(storageMethod),
                                color: priorityColor,
                                size: 6.w,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),

                          // Ingredient info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ingredient,
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                SizedBox(height: 0.6.h),
                                Row(
                                  children: [
                                    if (location.isNotEmpty) ...[
                                      CustomIconWidget(
                                        iconName: 'place',
                                        color: AppTheme.lightTheme
                                            .colorScheme.onSurfaceVariant,
                                        size: 4.w,
                                      ),
                                      SizedBox(width: 1.w),
                                      Flexible(
                                        child: Text(
                                          location,
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.onSurfaceVariant,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                    if (location.isNotEmpty && shelfLife.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Text('•',
                                            style:
                                                AppTheme.lightTheme.textTheme.bodySmall),
                                      ),
                                    if (shelfLife.isNotEmpty) ...[
                                      CustomIconWidget(
                                        iconName: 'schedule',
                                        color: priorityColor,
                                        size: 4.w,
                                      ),
                                      SizedBox(width: 1.w),
                                      Flexible(
                                        child: Text(
                                          shelfLife,
                                          style: AppTheme
                                              .lightTheme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: priorityColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Expand arrow
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Tooltip(
                              message: _isExpanded ? 'Collapse' : 'Expand',
                              child: CustomIconWidget(
                                iconName: 'keyboard_arrow_down',
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                                size: 6.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expandable content
                  SizeTransition(
                    sizeFactor: _expandAnimation,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withOpacity(0.18),
                          ),

                          SizedBox(height: 2.h),

                          // Storage details
                          if (storageMethod.isNotEmpty) ...[
                            _buildDetailRow(
                              icon: 'inventory',
                              title: 'Storage Method',
                              content: storageMethod,
                            ),
                            SizedBox(height: 1.5.h),
                          ],

                          if (container.isNotEmpty) ...[
                            _buildDetailRow(
                              icon: 'archive',
                              title: 'Container',
                              content: container,
                            ),
                            SizedBox(height: 1.5.h),
                          ],

                          if (preparation.isNotEmpty) ...[
                            _buildDetailRow(
                              icon: 'build',
                              title: 'Preparation',
                              content: preparation,
                            ),
                            SizedBox(height: 1.5.h),
                          ],

                          // Storage tips
                          if (tips.isNotEmpty) ...[
                            _buildTipsSection(
                              'Tips',
                              tips,
                              'lightbulb',
                              AppTheme.lightTheme.colorScheme.primary,
                            ),
                            SizedBox(height: 2.h),
                          ],

                          // Freshness signs
                          if (freshnessSigns.isNotEmpty) ...[
                            _buildTipsSection(
                              'Signs of Freshness',
                              freshnessSigns,
                              'check_circle',
                              AppTheme.lightTheme.colorScheme.tertiary,
                            ),
                            SizedBox(height: 2.h),
                          ],

                          // Spoilage signs
                          if (spoilageSigns.isNotEmpty) ...[
                            _buildTipsSection(
                              'Signs of Spoilage',
                              spoilageSigns,
                              'warning',
                              AppTheme.lightTheme.colorScheme.error,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomIconWidget(
          iconName: icon,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 5.w,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
              ),
              SizedBox(height: 0.5.h),
              Text(content, style: AppTheme.lightTheme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(
    String title,
    List<String> items,
    String icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(iconName: icon, color: color, size: 5.w),
            SizedBox(width: 3.w),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        ...items.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 0.8.h, left: 8.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 1.6.w,
                  height: 1.6.w,
                  margin: EdgeInsets.only(top: 0.9.h, right: 3.w),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                    softWrap: true,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
