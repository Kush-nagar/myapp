import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../widgets/user_profile_widget.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToCamera() {
    Navigator.pushNamed(context, AppRoutes.camera);
  }

  void _navigateToManualEntry() {
    // Show a dialog to collect manual ingredients
    _showManualEntryDialog();
  }

  void _showManualEntryDialog() {
    final TextEditingController controller = TextEditingController();
    final List<String> manualIngredients = [];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: DonationAppTheme.lightTheme.colorScheme.primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: 'edit',
                      color: DonationAppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Add Ingredients',
                      style: DonationAppTheme.lightTheme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700, fontSize: 20),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter ingredient names manually',
                      style: DonationAppTheme.lightTheme.textTheme.bodyMedium
                          ?.copyWith(
                            color: DonationAppTheme
                                .lightTheme
                                .colorScheme
                                .onSurface
                                .withOpacity(0.7),
                          ),
                    ),
                    SizedBox(height: 3.h),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'e.g., Tomatoes',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(3.w),
                          child: CustomIconWidget(
                            iconName: 'fastfood',
                            color: DonationAppTheme
                                .lightTheme
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                            size: 20,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color:
                                DonationAppTheme.lightTheme.colorScheme.primary,
                            size: 28,
                          ),
                          onPressed: () {
                            if (controller.text.trim().isNotEmpty) {
                              setDialogState(() {
                                manualIngredients.add(controller.text.trim());
                                controller.clear();
                              });
                            }
                          },
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          setDialogState(() {
                            manualIngredients.add(value.trim());
                            controller.clear();
                          });
                        }
                      },
                    ),
                    if (manualIngredients.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color:
                              DonationAppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: DonationAppTheme
                                .lightTheme
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Added ingredients:',
                              style: DonationAppTheme
                                  .lightTheme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: DonationAppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                            ),
                            SizedBox(height: 1.h),
                            Wrap(
                              spacing: 2.w,
                              runSpacing: 1.h,
                              children: manualIngredients.map((ingredient) {
                                return Chip(
                                  label: Text(ingredient),
                                  deleteIcon: Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    setDialogState(() {
                                      manualIngredients.remove(ingredient);
                                    });
                                  },
                                  backgroundColor: DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  labelStyle: TextStyle(
                                    color: DonationAppTheme
                                        .lightTheme
                                        .colorScheme
                                        .primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  deleteIconColor: DonationAppTheme
                                      .lightTheme
                                      .colorScheme
                                      .primary,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: DonationAppTheme.lightTheme.colorScheme.onSurface
                          .withOpacity(0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: manualIngredients.isEmpty
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          // Navigate to recognition results with manual ingredients
                          Navigator.pushNamed(
                            context,
                            AppRoutes.recognitionResults,
                            arguments: {'manualIngredients': manualIngredients},
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        DonationAppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.5.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = DonationAppTheme.lightTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      // Header
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Home',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          UserProfileWidget(size: 12.w, showBorder: true),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // Hero Icon
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.8),
                              theme.colorScheme.secondary.withOpacity(0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 30,
                              offset: Offset(0, 10),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          size: 20.w,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 3.h),

                      // Welcome Text
                      Text(
                        'Share Your Food',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                          fontSize: 32,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 1.5.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          'Choose how you\'d like to identify ingredients for donation',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(height: 5.h),

                      // Scan Button
                      _buildActionButton(
                        context: context,
                        theme: theme,
                        icon: Icons.camera_alt_rounded,
                        title: 'Scan',
                        subtitle: 'Use camera to identify ingredients',
                        onTap: _navigateToCamera,
                        isPrimary: true,
                      ),

                      SizedBox(height: 2.h),

                      // Manual Entry Button
                      _buildActionButton(
                        context: context,
                        theme: theme,
                        icon: Icons.edit_rounded,
                        title: 'Manual Entry',
                        subtitle: 'Add ingredients by typing',
                        onTap: _navigateToManualEntry,
                        isPrimary: false,
                      ),

                      SizedBox(height: 3.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.9),
            theme.colorScheme.secondary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.white.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),

                SizedBox(width: 4.w),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 24,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
