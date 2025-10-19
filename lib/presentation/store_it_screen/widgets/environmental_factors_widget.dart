import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class EnvironmentalFactorsWidget extends StatelessWidget {
  final Map<String, dynamic> factors;

  const EnvironmentalFactorsWidget({Key? key, required this.factors})
      : super(key: key);

  String _getFactorIcon(String factor) {
    switch (factor.toLowerCase()) {
      case 'temperature':
        return 'thermostat';
      case 'humidity':
        return 'water_drop';
      case 'light':
        return 'wb_sunny';
      case 'airflow':
        return 'air';
      default:
        return 'tune';
    }
  }

  Color _getFactorColor(String factor) {
    switch (factor.toLowerCase()) {
      case 'temperature':
        return Colors.red;
      case 'humidity':
        return Colors.blue;
      case 'light':
        return Colors.amber;
      case 'airflow':
        return Colors.cyan;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getFactorTitle(String factor) {
    if (factor.isEmpty) return '';
    return factor[0].toUpperCase() + factor.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (factors.isEmpty) return const SizedBox.shrink();

    final maxCardWidth = 900.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxCardWidth),
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  AppTheme.lightTheme.colorScheme.secondaryContainer
                      .withOpacity(0.28),
                  AppTheme.lightTheme.colorScheme.secondaryContainer
                      .withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.secondaryContainer
                        .withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Semantics(
                          label: 'Environmental factors icon',
                          child: CustomIconWidget(
                            iconName: 'settings',
                            color: Colors.white,
                            size: 6.w,
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Environmental Factors',
                              style:
                                  AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme
                                            .lightTheme.colorScheme.secondary,
                                      ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Optimal storage conditions',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.secondary
                                    .withOpacity(0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Factors grid
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: LayoutBuilder(builder: (context, constraints) {
                    // Switch to 1 column for narrow widths
                    final crossAxisCount = constraints.maxWidth < 420 ? 1 : 2;
                    final entries = factors.entries
                        .where((e) => (e.value?.toString() ?? '').isNotEmpty)
                        .toList();

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 3.w,
                        mainAxisSpacing: 2.h,
                        childAspectRatio: 2.4,
                      ),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final factor = entries[index].key;
                        final value = entries[index].value?.toString() ?? '';
                        final factorColor = _getFactorColor(factor);

                        return Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: factorColor.withOpacity(0.18),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: factorColor.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(2.6.w),
                                decoration: BoxDecoration(
                                  color: factorColor.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: CustomIconWidget(
                                  iconName: _getFactorIcon(factor),
                                  color: factorColor,
                                  size: 6.w,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getFactorTitle(factor),
                                      style: AppTheme
                                          .lightTheme.textTheme.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: factorColor,
                                      ),
                                    ),
                                    SizedBox(height: 0.6.h),
                                    Text(
                                      value,
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ),

                // Additional info callout
                Container(
                  margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Semantics(
                        label: 'Information',
                        child: CustomIconWidget(
                          iconName: 'info',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 5.w,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Maintaining these environmental conditions helps preserve ingredients for freshness and nutrition.',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
