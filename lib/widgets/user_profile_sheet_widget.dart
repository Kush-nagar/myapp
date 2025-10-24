import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../routes/app_routes.dart';
import './custom_icon_widget.dart';

/// A bottom sheet widget that displays user profile information
/// with options to logout and manage account
class UserProfileSheetWidget extends StatelessWidget {
  final User user;

  const UserProfileSheetWidget({Key? key, required this.user})
    : super(key: key);

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Sign Out',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      try {
        // Close the bottom sheet first
        Navigator.of(context).pop();

        // Show loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        );

        // Sign out
        await AuthService().signOut();

        if (context.mounted) {
          // Close loading dialog
          Navigator.of(context).pop();

          // Navigate to sign in screen
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.signIn, (route) => false);

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Successfully signed out'),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          // Close loading dialog
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out: ${e.toString()}'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final photoUrl = user.photoURL;
    final displayName = user.displayName ?? 'User';
    final email = user.email ?? '';
    final creationDate = authService.userCreationDate;
    final lastSignIn = authService.lastSignInDate;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 12.w,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                SizedBox(height: 3.h),

                // Profile Picture
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: photoUrl != null && photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildInitialsAvatar(displayName);
                            },
                          )
                        : _buildInitialsAvatar(displayName),
                  ),
                ),

                SizedBox(height: 2.h),

                // User Name
                Text(
                  displayName,
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 0.5.h),

                // Email
                Text(
                  email,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 3.h),

                // Account Info Card
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surfaceVariant
                        .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        context,
                        icon: 'calendar_today',
                        label: 'Member Since',
                        value: _formatDate(creationDate),
                      ),
                      SizedBox(height: 2.h),
                      _buildInfoRow(
                        context,
                        icon: 'schedule',
                        label: 'Last Sign In',
                        value: _formatDate(lastSignIn),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Action Buttons
                Column(
                  children: [
                    // Edit Profile Button (placeholder - can be implemented)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Edit profile coming soon!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: CustomIconWidget(
                          iconName: 'edit',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 5.w,
                        ),
                        label: Text(
                          'Edit Profile',
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                              ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleLogout(context),
                        icon: CustomIconWidget(
                          iconName: 'logout',
                          color: Colors.white,
                          size: 5.w,
                        ),
                        label: Text(
                          'Sign Out',
                          style: AppTheme.lightTheme.textTheme.labelLarge
                              ?.copyWith(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.error,
                          padding: EdgeInsets.symmetric(vertical: 1.8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    final initials = _getInitials(name);
    return Container(
      color: AppTheme.lightTheme.colorScheme.primary,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 5.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.3.h),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
