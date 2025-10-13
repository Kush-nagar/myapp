import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class StorageTipDetailScreen extends StatelessWidget {
  const StorageTipDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args == null) {
      return _buildErrorScreen(context);
    }

    final String title = args['title'] ?? 'Storage Tip';
    final String category = args['category'] ?? '';
    final Map<String, dynamic> data = args['data'] ?? {};
    final String type = args['type'] ?? 'general';

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _shareContent(context, title, data),
            icon: CustomIconWidget(
              iconName: 'share',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: _buildContent(context, title, category, data, type),
    );
  }

  Widget _buildContent(
    BuildContext context,
    String title,
    String category,
    Map<String, dynamic> data,
    String type,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card with category and icon
          _buildHeaderCard(title, category, type),

          SizedBox(height: 3.h),

          // Main content based on type
          if (type == 'general') ..._buildGeneralTipContent(data),
          if (type == 'ingredient') ..._buildIngredientContent(data),
          if (type == 'environmental') ..._buildEnvironmentalContent(data),

          SizedBox(height: 8.h), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildHeaderCard(String title, String category, String type) {
    final iconData = _getIconForType(type);
    final color = _getColorForType(type);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CustomIconWidget(
              iconName: iconData,
              color: Colors.white,
              size: 8.w,
            ),
          ),

          SizedBox(height: 2.h),

          // Title
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          if (category.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                category,
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildGeneralTipContent(Map<String, dynamic> data) {
    final String tip = data['tip'] ?? '';
    final List<String> details = List<String>.from(data['details'] ?? []);

    return [
      // Main tip
      _buildContentCard(
        title: 'Quick Tip',
        icon: 'lightbulb',
        color: Colors.amber,
        child: Text(
          tip,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            fontSize: 16.sp,
          ),
        ),
      ),

      if (details.isNotEmpty) ...[
        SizedBox(height: 3.h),
        _buildContentCard(
          title: 'Additional Details',
          icon: 'info',
          color: AppTheme.lightTheme.colorScheme.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details
                .map(
                  (detail) => Padding(
                    padding: EdgeInsets.only(bottom: 1.5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 0.8.h, right: 3.w),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            detail,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildIngredientContent(Map<String, dynamic> data) {
    final String location = data['location'] ?? '';
    final String shelfLife = data['shelfLife'] ?? '';
    final String storageMethod = data['storageMethod'] ?? '';
    final List<String> tips = List<String>.from(data['tips'] ?? []);
    final Map<String, dynamic> signs = data['spoilageSigns'] ?? {};

    return [
      // Storage basics
      _buildContentCard(
        title: 'Storage Basics',
        icon: 'home',
        color: Colors.blue,
        child: Column(
          children: [
            if (location.isNotEmpty)
              _buildInfoRow('Location', location, 'place'),
            if (storageMethod.isNotEmpty)
              _buildInfoRow('Method', storageMethod, 'settings'),
            if (shelfLife.isNotEmpty)
              _buildInfoRow('Shelf Life', shelfLife, 'schedule'),
          ],
        ),
      ),

      if (tips.isNotEmpty) ...[
        SizedBox(height: 3.h),
        _buildContentCard(
          title: 'Pro Tips',
          icon: 'star',
          color: Colors.green,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tips
                .map(
                  (tip) => Padding(
                    padding: EdgeInsets.only(bottom: 1.5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomIconWidget(
                          iconName: 'check_circle',
                          color: Colors.green,
                          size: 5.w,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            tip,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],

      if (signs.isNotEmpty) ...[
        SizedBox(height: 3.h),
        _buildContentCard(
          title: 'Spoilage Signs',
          icon: 'warning',
          color: Colors.orange,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: signs.entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: 1.5.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.toUpperCase(),
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          entry.value.toString(),
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildEnvironmentalContent(Map<String, dynamic> data) {
    return [
      _buildContentCard(
        title: 'Environmental Details',
        icon: _getIconForEnvironmentalFactor(data['factor'] ?? ''),
        color: _getColorForEnvironmentalFactor(data['factor'] ?? ''),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['description'] ?? '',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontSize: 16.sp,
              ),
            ),

            if (data['optimalRange'] != null) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: _getColorForEnvironmentalFactor(
                    data['factor'] ?? '',
                  ).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getColorForEnvironmentalFactor(
                      data['factor'] ?? '',
                    ).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'tune',
                      color: _getColorForEnvironmentalFactor(
                        data['factor'] ?? '',
                      ),
                      size: 5.w,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Optimal Range',
                            style: AppTheme.lightTheme.textTheme.labelMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            data['optimalRange'].toString(),
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                                  color: _getColorForEnvironmentalFactor(
                                    data['factor'] ?? '',
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _buildContentCard({
    required String title,
    required String icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: icon,
                  color: color,
                  size: 5.5.w,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Content
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, String icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
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
                  label,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No content available',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }

  void _shareContent(
    BuildContext context,
    String title,
    Map<String, dynamic> data,
  ) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title details copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _getIconForType(String type) {
    switch (type) {
      case 'general':
        return 'tips_and_updates';
      case 'ingredient':
        return 'local_dining';
      case 'environmental':
        return 'thermostat';
      default:
        return 'info';
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'general':
        return Colors.amber;
      case 'ingredient':
        return Colors.green;
      case 'environmental':
        return Colors.blue;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getIconForEnvironmentalFactor(String factor) {
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

  Color _getColorForEnvironmentalFactor(String factor) {
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
}
