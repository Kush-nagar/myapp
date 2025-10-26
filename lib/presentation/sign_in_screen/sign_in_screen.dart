// paste this content into lib/presentation/sign_in_screen/sign_in_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../routes/app_routes.dart';

enum SignRole { user, organization }

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;
  SignRole? _selectedRole;

  // Use web client id (from your google-services.json client_type:3)
  static const String _webClientId =
      '242208760241-nt0hnu6k3cod9lgka12n66ji7p6thro5.apps.googleusercontent.com';

  Future<UserCredential?> _doGoogleSignIn() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return await auth.signInWithPopup(provider);
    }

    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(serverClientId: _webClientId);

      // Start the interactive auth flow
      final GoogleSignInAccount? account = await googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );

      // If user cancelled the flow, account may be null (handle gracefully)
      if (account == null) return null;

      // Get the authentication object (idToken is expected)
      final GoogleSignInAuthentication googleAuth =
          await account.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Missing idToken from Google Sign-In. '
          'On Android you must provide serverClientId (web client id) in initialize(). '
          'On iOS ensure the reversed client ID is in Info.plist and GoogleService-Info.plist is correct.',
        );
      }

      // Only idToken is required for Firebase mobile sign-in
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      return await auth.signInWithCredential(credential);
    } catch (e) {
      // rethrow or return null depending how you want to handle it upstream
      rethrow;
    }
  }

  Future<void> _onRoleSelected(SignRole role) async {
    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCred = await _doGoogleSignIn();
      if (userCred == null || userCred.user == null) return;

      final user = userCred.user!;
      if (_selectedRole == SignRole.organization) {
        // if org doc already exists, go home, else go fill org data
        final doc = await FirebaseFirestore.instance
            .collection('organizations')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          if (mounted)
            Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else {
          if (mounted)
            Navigator.of(
              context,
            ).pushReplacementNamed(AppRoutes.getOrganizationData);
        }
      } else {
        // user -> existing flow: landing screen
        if (mounted)
          Navigator.of(context).pushReplacementNamed(AppRoutes.landing);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _googleSignInButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        height: 24,
                        width: 24,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.g_mobiledata,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Sign in with Google',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.85),
              theme.colorScheme.secondary.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.08),

                  // App Logo/Icon
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.food_bank,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Welcome Text
                  Text(
                    'Welcome!',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to reduce food waste and make a difference!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: size.height * 0.08),

                  // Role selection card
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _selectedRole == null
                        ? _buildRoleSelectionCard(theme)
                        : _buildSignInCard(theme),
                  ),

                  const SizedBox(height: 24),

                  // Footer text
                  Text(
                    'By signing in, you agree to our Terms & Conditions',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: size.height * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectionCard(ThemeData theme) {
    return Container(
      key: const ValueKey('role_selection'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Choose Your Role',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select how you want to sign in',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 28),
          _buildRoleButton(
            theme: theme,
            icon: Icons.person_outline_rounded,
            title: 'User',
            subtitle: 'Discover and save recipes',
            onTap: () => _onRoleSelected(SignRole.user),
            isPrimary: true,
          ),
          const SizedBox(height: 16),
          _buildRoleButton(
            theme: theme,
            icon: Icons.business_outlined,
            title: 'Organization',
            subtitle: 'Manage donations and events',
            onTap: () => _onRoleSelected(SignRole.organization),
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSignInCard(ThemeData theme) {
    return Container(
      key: const ValueKey('sign_in'),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _selectedRole == SignRole.organization
                  ? Icons.business_rounded
                  : Icons.person_rounded,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Signing in as',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedRole == SignRole.organization ? 'Organization' : 'User',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 28),
          _googleSignInButton(theme),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() => _selectedRole = null),
            icon: Icon(
              Icons.arrow_back,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              'Choose a different role',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPrimary
                ? theme.colorScheme.primary.withOpacity(0.08)
                : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? theme.colorScheme.primary
                      : Colors.grey[400],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPrimary
                            ? theme.colorScheme.primary
                            : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: isPrimary ? theme.colorScheme.primary : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
