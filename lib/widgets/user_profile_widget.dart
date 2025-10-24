import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import './user_profile_sheet_widget.dart';

/// A reusable user profile avatar widget that shows profile picture
/// and opens profile details when tapped
class UserProfileWidget extends StatelessWidget {
  final double size;
  final bool showBorder;
  final VoidCallback? onTap;

  const UserProfileWidget({
    Key? key,
    this.size = 44,
    this.showBorder = true,
    this.onTap,
  }) : super(key: key);

  void _showProfileSheet(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserProfileSheetWidget(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          // Show a default icon if not signed in
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/sign-in-screen');
            },
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceVariant,
                shape: BoxShape.circle,
                border: showBorder
                    ? Border.all(
                        color: AppTheme.lightTheme.colorScheme.outline,
                        width: 2,
                      )
                    : null,
              ),
              child: Icon(
                Icons.person_outline,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: size * 0.5,
              ),
            ),
          );
        }

        final photoUrl = user.photoURL;
        final displayName = user.displayName ?? 'User';
        final initials = _getInitials(displayName);

        return GestureDetector(
          onTap: onTap ?? () => _showProfileSheet(context, user),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder
                  ? Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 2,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: photoUrl != null && photoUrl.isNotEmpty
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar(initials, size);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        );
                      },
                    )
                  : _buildInitialsAvatar(initials, size),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitialsAvatar(String initials, double size) {
    return Container(
      color: AppTheme.lightTheme.colorScheme.primary,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
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
}
