import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../core/app_export.dart';
import './widgets/loading_storage_tips_widget.dart';

class StoreItScreen extends StatefulWidget {
  const StoreItScreen({Key? key}) : super(key: key);

  @override
  State<StoreItScreen> createState() => _StoreItScreenState();
}

class _StoreItScreenState extends State<StoreItScreen> {
  bool _isLoading = true;
  List<String> _ingredients = [];
  Map<String, dynamic>? _storageTips;
  String? _errorMessage;

  late StorageTipsService _storageTipsService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _initializeService() {
    // Initialize the storage tips service with Gemini API
    // TODO: Replace with your actual Gemini API key
    // You can get it from: https://makersuite.google.com/app/apikey
    const apiKey =
        'AIzaSyBHaPa5KHVpklOP9d_I6B1q4W-4d09FfsQ'; // Replace with actual API key
    _storageTipsService = StorageTipsService(apiKey: apiKey);
    _loadArguments();
  }

  void _loadArguments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['ingredients'] != null) {
        _ingredients = List<String>.from(args['ingredients'] as List<dynamic>);
        _generateStorageTips();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No ingredients provided';
        });
      }
    });
  }

  Future<void> _generateStorageTips() async {
    if (_ingredients.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No ingredients to analyze';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final tips = await _storageTipsService.generateStorageTips(_ingredients);

      setState(() {
        _storageTips = tips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to generate storage tips: ${e.toString()}';
      });
    }
  }

  void _retryGeneration() {
    _generateStorageTips();
  }

  void _shareStorageTips() {
    if (_storageTips == null) return;

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Storage tips copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveToFavorites() {
    if (_storageTips == null) return;

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Storage tips saved to favorites'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          'Storage Tips',
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
          if (!_isLoading && _storageTips != null) ...[
            IconButton(
              onPressed: _shareStorageTips,
              icon: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
            IconButton(
              onPressed: _saveToFavorites,
              icon: CustomIconWidget(
                iconName: 'favorite_border',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingStorageTipsWidget();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_storageTips == null) {
      return _buildEmptyState();
    }

    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with ingredients
          _buildIngredientsHeader(),

          SizedBox(height: 3.h),

          // Quick Actions Grid
          _buildQuickActionsGrid(),

          SizedBox(height: 3.h),

          // Storage Tips Cards
          _buildStorageTipsSection(),

          SizedBox(height: 3.h),

          // Environmental Factors
          _buildEnvironmentalSection(),

          SizedBox(height: 10.h), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildIngredientsHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            AppTheme.lightTheme.colorScheme.secondary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Icon and title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CustomIconWidget(
                  iconName: 'inventory',
                  color: Colors.white,
                  size: 7.w,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Storage Guide',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Ingredients count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'grain',
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  '${_ingredients.length} ingredients',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final generalTips = List<String>.from(_storageTips!['generalTips'] ?? []);

    // Define labels for each tip category
    final tipLabels = [
      'Temperature Control',
      'Freshness Tips',
      'Best Practices',
      'Storage Essentials',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Tips',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 2.h),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 2.h,
            childAspectRatio: 1.0,
          ),
          itemCount: math.min(generalTips.length, 4),
          itemBuilder: (context, index) {
            final tip = generalTips[index];
            final icons = ['tips_and_updates', 'ac_unit', 'schedule', 'eco'];
            final colors = [
              AppTheme.lightTheme.colorScheme.primary,
              AppTheme.lightTheme.colorScheme.secondary,
              AppTheme.lightTheme.colorScheme.tertiary,
              Colors.green,
            ];

            return GestureDetector(
              onTap: () => _navigateToTipDetail(
                title: tipLabels[index % tipLabels.length],
                category: 'Quick Storage Tip',
                data: {
                  'tip': tip,
                  'details': [
                    'Follow this tip for optimal storage results',
                    'Keep your ingredients fresh for longer',
                    'Reduce food waste with proper storage',
                  ],
                },
                type: 'general',
              ),
              child: Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors[index % colors.length].withOpacity(0.15),
                      colors[index % colors.length].withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors[index % colors.length].withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors[index % colors.length].withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colors[index % colors.length].withOpacity(
                              0.3,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: CustomIconWidget(
                        iconName: icons[index % icons.length],
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),

                    SizedBox(height: 1.5.h),

                    // Label
                    Text(
                      tipLabels[index % tipLabels.length],
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors[index % colors.length],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 0.5.h),

                    // Short description
                    Text(
                      tip.length > 40 ? '${tip.substring(0, 40)}...' : tip,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 1.h),

                    // Tap hint
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: colors[index % colors.length].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'TAP FOR MORE',
                        style: AppTheme.lightTheme.textTheme.labelSmall
                            ?.copyWith(
                              color: colors[index % colors.length],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStorageTipsSection() {
    final itemTips = List<Map<String, dynamic>>.from(
      _storageTips!['itemSpecificTips'] ?? [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredient Storage',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 2.h),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: math.min(itemTips.length, 6), // Limit to 6 items
          itemBuilder: (context, index) {
            return _buildSimpleStorageCard(itemTips[index]);
          },
        ),
      ],
    );
  }

  Widget _buildSimpleStorageCard(Map<String, dynamic> tipData) {
    final ingredient = tipData['ingredient'] ?? 'Unknown';
    final location = tipData['location'] ?? '';
    final shelfLife = tipData['shelfLife'] ?? '';
    final storageMethod = tipData['storageMethod'] ?? '';

    return GestureDetector(
      onTap: () => _navigateToTipDetail(
        title: ingredient,
        category: 'Ingredient Storage',
        data: {
          'ingredient': ingredient,
          'location': location,
          'shelfLife': shelfLife,
          'storageMethod': storageMethod,
          'tips': _generateIngredientTips(ingredient, storageMethod),
          'spoilageSigns': _generateSpoilageSigns(ingredient),
        },
        type: 'ingredient',
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: _getStorageIconColor(storageMethod).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: _getStorageIcon(storageMethod),
                color: _getStorageIconColor(storageMethod),
                size: 6.w,
              ),
            ),

            SizedBox(width: 4.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ingredient,
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'TAP FOR DETAILS',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 0.5.h),

                  if (location.isNotEmpty)
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'place',
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            location,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme
                                      .lightTheme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  if (shelfLife.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Flexible(
                          child: Text(
                            shelfLife,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.secondary,
                                  fontWeight: FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalSection() {
    final factors = Map<String, dynamic>.from(
      _storageTips!['environmentalFactors'] ?? {},
    );

    if (factors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Conditions',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 2.h),

        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.lightTheme.colorScheme.tertiaryContainer.withOpacity(
                  0.3,
                ),
                AppTheme.lightTheme.colorScheme.tertiaryContainer.withOpacity(
                  0.1,
                ),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.tertiary.withOpacity(0.2),
            ),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.3,
            ),
            itemCount: factors.length,
            itemBuilder: (context, index) {
              final factor = factors.keys.elementAt(index);
              final value = factors[factor]?.toString() ?? '';

              return _buildEnvironmentalFactor(factor, value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnvironmentalFactor(String factor, String value) {
    final factorData = _getEnvironmentalFactorData(factor);

    return GestureDetector(
      onTap: () => _navigateToTipDetail(
        title: factorData['title'],
        category: 'Environmental Factor',
        data: {
          'factor': factor,
          'description': value,
          'optimalRange': _getOptimalRange(factor),
        },
        type: 'environmental',
      ),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: factorData['color'].withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: factorData['color'].withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: factorData['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: factorData['icon'],
                color: factorData['color'],
                size: 6.w,
              ),
            ),

            SizedBox(height: 1.h),

            Text(
              factorData['title'],
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: factorData['color'],
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 0.5.h),

            Text(
              value.length > 30 ? '${value.substring(0, 30)}...' : value,
              style: AppTheme.lightTheme.textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: 0.5.h),

            // Tap hint
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
              decoration: BoxDecoration(
                color: factorData['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'TAP',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: factorData['color'],
                  fontWeight: FontWeight.w600,
                  fontSize: 8.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getEnvironmentalFactorData(String factor) {
    switch (factor.toLowerCase()) {
      case 'temperature':
        return {
          'icon': 'thermostat',
          'title': 'Temperature',
          'color': Colors.red,
        };
      case 'humidity':
        return {
          'icon': 'water_drop',
          'title': 'Humidity',
          'color': Colors.blue,
        };
      case 'light':
        return {'icon': 'wb_sunny', 'title': 'Light', 'color': Colors.amber};
      case 'airflow':
        return {'icon': 'air', 'title': 'Airflow', 'color': Colors.cyan};
      default:
        return {
          'icon': 'tune',
          'title': factor.substring(0, 1).toUpperCase() + factor.substring(1),
          'color': AppTheme.lightTheme.colorScheme.primary,
        };
    }
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

  Color _getStorageIconColor(String? storageMethod) {
    if (storageMethod == null) return AppTheme.lightTheme.colorScheme.primary;
    final method = storageMethod.toLowerCase();
    if (method.contains('refrigerat') || method.contains('fridge')) {
      return Colors.blue;
    } else if (method.contains('freez')) {
      return Colors.cyan;
    } else if (method.contains('room') || method.contains('counter')) {
      return Colors.orange;
    } else if (method.contains('pantry')) {
      return Colors.brown;
    }
    return AppTheme.lightTheme.colorScheme.primary;
  }

  // Navigation method to detail screen
  void _navigateToTipDetail({
    required String title,
    required String category,
    required Map<String, dynamic> data,
    required String type,
  }) {
    HapticFeedback.lightImpact();
    Navigator.of(context).pushNamed(
      AppRoutes.storageTipDetail,
      arguments: {
        'title': title,
        'category': category,
        'data': data,
        'type': type,
      },
    );
  }

  // Helper method to generate ingredient-specific tips
  List<String> _generateIngredientTips(
    String ingredient,
    String storageMethod,
  ) {
    final tips = <String>[];
    final method = storageMethod.toLowerCase();

    if (method.contains('refrigerat') || method.contains('fridge')) {
      tips.addAll([
        'Store in the main compartment, not in the door',
        'Keep in original packaging or airtight container',
        'Place on middle shelf for consistent temperature',
      ]);
    } else if (method.contains('freez')) {
      tips.addAll([
        'Wrap tightly to prevent freezer burn',
        'Label with date before freezing',
        'Use within recommended timeframe',
      ]);
    } else if (method.contains('room') || method.contains('counter')) {
      tips.addAll([
        'Keep in cool, dry place away from direct sunlight',
        'Ensure good air circulation around the item',
        'Check regularly for signs of spoilage',
      ]);
    } else {
      tips.addAll([
        'Follow storage instructions on packaging',
        'Keep in optimal storage conditions',
        'Monitor for freshness regularly',
      ]);
    }

    return tips;
  }

  // Helper method to generate spoilage signs
  Map<String, dynamic> _generateSpoilageSigns(String ingredient) {
    final signs = <String, dynamic>{};
    final item = ingredient.toLowerCase();

    if (item.contains('meat') ||
        item.contains('chicken') ||
        item.contains('beef')) {
      signs['Visual'] = 'Gray or green discoloration, slimy texture';
      signs['Smell'] = 'Sour or putrid odor';
      signs['Texture'] = 'Sticky or slimy surface';
    } else if (item.contains('vegetable') ||
        item.contains('lettuce') ||
        item.contains('spinach')) {
      signs['Visual'] = 'Wilting, yellowing, dark spots';
      signs['Texture'] = 'Slimy or mushy feel';
      signs['Smell'] = 'Off or sour smell';
    } else if (item.contains('fruit') ||
        item.contains('apple') ||
        item.contains('banana')) {
      signs['Visual'] = 'Brown spots, wrinkled skin, mold';
      signs['Texture'] = 'Soft or mushy areas';
      signs['Smell'] = 'Fermented or off odor';
    } else {
      signs['Visual'] = 'Discoloration, unusual appearance';
      signs['Smell'] = 'Off or unusual odor';
      signs['Texture'] = 'Changes in normal texture';
    }

    return signs;
  }

  // Helper method to get optimal ranges for environmental factors
  String _getOptimalRange(String factor) {
    switch (factor.toLowerCase()) {
      case 'temperature':
        return '32-40°F (0-4°C) for refrigeration, 0°F (-18°C) for freezing';
      case 'humidity':
        return '30-50% relative humidity for most dry goods';
      case 'light':
        return 'Keep away from direct sunlight and bright lights';
      case 'airflow':
        return 'Good ventilation without direct air currents';
      default:
        return 'Follow specific storage guidelines for optimal results';
    }
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 20.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'Oops! Something went wrong',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              _errorMessage ?? 'Unable to generate storage tips',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: _retryGeneration,
              icon: CustomIconWidget(
                iconName: 'refresh',
                color: Colors.white,
                size: 5.w,
              ),
              label: Text(
                'Try Again',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'inventory_2',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'No Ingredients Found',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Please go back and select some ingredients to get storage tips.',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: CustomIconWidget(
                iconName: 'arrow_back',
                color: Colors.white,
                size: 5.w,
              ),
              label: Text(
                'Go Back',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
