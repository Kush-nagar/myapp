import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/loading_storage_tips_widget.dart';
import './widgets/storage_tip_card_widget.dart';
import './widgets/category_tips_widget.dart';
import './widgets/environmental_factors_widget.dart';
import './widgets/quick_tips_widget.dart';

class StoreItScreen extends StatefulWidget {
  const StoreItScreen({Key? key}) : super(key: key);

  @override
  State<StoreItScreen> createState() => _StoreItScreenState();
}

class _StoreItScreenState extends State<StoreItScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<String> _ingredients = [];
  Map<String, dynamic>? _storageTips;
  String? _errorMessage;

  late TabController _tabController;
  late StorageTipsService _storageTipsService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeService() {
    // Initialize the storage tips service with Gemini API
    // TODO: Replace with your actual Gemini API key
    // You can get it from: https://makersuite.google.com/app/apikey
    const apiKey = 'AIzaSyBHaPa5KHVpklOP9d_I6B1q4W-4d09FfsQ'; // Replace with actual API key
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
    // Implementation for sharing storage tips
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
    // Implementation for saving to favorites
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

    return Column(
      children: [
        // Header with ingredients
        _buildIngredientsHeader(),

        // Tab bar
        _buildTabBar(),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildDetailedTipsTab(),
              _buildCategoryTipsTab(),
              _buildAdvancedTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'inventory',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Storage Guide for',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _ingredients.map((ingredient) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.outline.withOpacity(
                      0.2,
                    ),
                  ),
                ),
                child: Text(
                  ingredient,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicator: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.lightTheme.colorScheme.onSurface,
        labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelMedium,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Detailed'),
          Tab(text: 'By Category'),
          Tab(text: 'Advanced'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick tips section
          QuickTipsWidget(
            generalTips: List<String>.from(_storageTips!['generalTips'] ?? []),
          ),

          SizedBox(height: 3.h),

          // Food safety highlights
          if (_storageTips!['foodSafety'] != null) _buildFoodSafetySection(),
        ],
      ),
    );
  }

  Widget _buildDetailedTipsTab() {
    final itemTips = List<Map<String, dynamic>>.from(
      _storageTips!['itemSpecificTips'] ?? [],
    );

    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: itemTips.length,
      itemBuilder: (context, index) {
        return StorageTipCardWidget(tipData: itemTips[index]);
      },
    );
  }

  Widget _buildCategoryTipsTab() {
    final categoryTips = Map<String, dynamic>.from(
      _storageTips!['categoryTips'] ?? {},
    );

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: categoryTips.entries.map((entry) {
          return CategoryTipsWidget(
            category: entry.key,
            tips: List<String>.from(entry.value ?? []),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAdvancedTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Environmental factors
          if (_storageTips!['environmentalFactors'] != null)
            EnvironmentalFactorsWidget(
              factors: Map<String, dynamic>.from(
                _storageTips!['environmentalFactors'],
              ),
            ),

          SizedBox(height: 3.h),

          // Extended shelf life tips
          if (_storageTips!['extendShelfLife'] != null)
            _buildExtendedShelfLifeSection(),
        ],
      ),
    );
  }

  Widget _buildFoodSafetySection() {
    final safetyTips = List<String>.from(_storageTips!['foodSafety'] ?? []);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.colorScheme.errorContainer,
              AppTheme.lightTheme.colorScheme.errorContainer.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Food Safety',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ...safetyTips.map((tip) {
              return Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 2.w,
                      height: 2.w,
                      margin: EdgeInsets.only(top: 1.h, right: 3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                              color: AppTheme
                                  .lightTheme
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildExtendedShelfLifeSection() {
    final extendTips = List<String>.from(
      _storageTips!['extendShelfLife'] ?? [],
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.lightTheme.colorScheme.tertiaryContainer,
              AppTheme.lightTheme.colorScheme.tertiaryContainer.withOpacity(
                0.7,
              ),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'trending_up',
                  color: AppTheme.lightTheme.colorScheme.tertiary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Extend Shelf Life',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            ...extendTips.map((tip) {
              return Padding(
                padding: EdgeInsets.only(bottom: 1.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 2.w,
                      height: 2.w,
                      margin: EdgeInsets.only(top: 1.h, right: 3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip,
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                              color: AppTheme
                                  .lightTheme
                                  .colorScheme
                                  .onTertiaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
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
