import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../../routes/app_routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;

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
              theme.colorScheme.primary.withOpacity(0.8),
              theme.colorScheme.secondary.withOpacity(0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.1),

                  // App Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 60,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Name
                  Text(
                    'Chefify',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  Text(
                    'Capture, Cook, Create',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: size.height * 0.08),

                  // Welcome Text
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Sign in to continue your culinary journey',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Google Sign In Button
                  _buildGoogleSignInButton(theme),

                  SizedBox(height: size.height * 0.1),

                  // Terms and Privacy
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'By signing in, you agree to our Terms of Service and Privacy Policy',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                else ...[
                  Image.network(
                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                    height: 24,
                    width: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.g_mobiledata,
                        size: 28,
                        color: theme.colorScheme.primary,
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Sign in with Google',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await auth.signInWithPopup(provider);
      } else {
        const webClientId =
            '242208760241-nt0hnu6k3cod9lgka12n66ji7p6thro5.apps.googleusercontent.com';

        final googleSignIn = GoogleSignIn.instance;

        await googleSignIn.initialize(serverClientId: webClientId);

        final GoogleSignInAccount account = await googleSignIn.authenticate(
          scopeHint: ['email', 'profile'],
        );

        final GoogleSignInAuthentication googleAuth =
            await account.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        await auth.signInWithCredential(credential);
      }

      // Navigate to camera screen on successful sign in
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.camera);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed in!'),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign in failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleGoogleSignIn,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
