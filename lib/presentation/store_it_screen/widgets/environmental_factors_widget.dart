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
    return factor[0].toUpperCase() + factor.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    if (factors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.colorScheme.secondaryContainer.withOpacity(
                0.3,
              ),
              AppTheme.lightTheme.colorScheme.secondaryContainer.withOpacity(
                0.1,
              ),
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
                    child: CustomIconWidget(
                      iconName: 'settings',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Environmental Factors',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color:
                                    AppTheme.lightTheme.colorScheme.secondary,
                              ),
                        ),
                        Text(
                          'Optimal storage conditions',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.secondary
                                    .withOpacity(0.8),
                              ),
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
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 3.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 1.2,
                ),
                itemCount: factors.length,
                itemBuilder: (context, index) {
                  final factor = factors.keys.elementAt(index);
                  final value = factors[factor]?.toString() ?? '';

                  if (value.isEmpty) return const SizedBox.shrink();

                  final factorColor = _getFactorColor(factor);

                  return Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: factorColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: factorColor.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: factorColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: CustomIconWidget(
                            iconName: _getFactorIcon(factor),
                            color: factorColor,
                            size: 8.w,
                          ),
                        ),

                        SizedBox(height: 1.5.h),

                        Text(
                          _getFactorTitle(factor),
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: factorColor,
                              ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: 1.h),

                        Expanded(
                          child: Text(
                            value,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.onSurface,
                                  height: 1.3,
                                ),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Additional info callout
            Container(
              margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary.withOpacity(
                    0.3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Maintaining these environmental conditions will help preserve your ingredients for maximum freshness and nutritional value.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
