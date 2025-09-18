// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isInitialized = false;
  String _initializationStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _logoAnimationController.forward();
    _fadeAnimationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Hide system UI for immersive experience
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      // Set status bar color
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.lightTheme.primaryColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      setState(() {
        _initializationStatus = 'Checking permissions...';
      });

      // Check and request camera permissions
      await _checkCameraPermissions();

      setState(() {
        _initializationStatus = 'Loading recipe database...';
      });

      // Simulate loading recipe database
      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _initializationStatus = 'Preparing storage...';
      });

      // Initialize SharedPreferences
      await _initializeStorage();

      setState(() {
        _initializationStatus = 'Setting up camera service...';
      });

      // Initialize image picker service
      await Future.delayed(const Duration(milliseconds: 600));

      setState(() {
        _initializationStatus = 'Ready to cook!';
        _isInitialized = true;
      });

      // Wait for animations to complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate to appropriate screen
      await _navigateToNextScreen();
    } catch (e) {
      setState(() {
        _initializationStatus = 'Initialization failed';
      });

      // Show error dialog after a brief delay
      await Future.delayed(const Duration(milliseconds: 1000));
      _showErrorDialog();
    }
  }

  Future<void> _checkCameraPermissions() async {
    final cameraStatus = await Permission.camera.status;

    if (cameraStatus.isDenied) {
      final result = await Permission.camera.request();
      if (result.isPermanentlyDenied) {
        _showPermissionDialog();
        return;
      }
    }
  }

  Future<void> _initializeStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Initialize default preferences if first time
      if (!prefs.containsKey('first_launch')) {
        await prefs.setBool('first_launch', true);
        await prefs.setStringList('dietary_preferences', []);
        await prefs.setStringList('allergies', []);
        await prefs.setStringList('saved_recipes', []);
      }
    } catch (e) {
      throw Exception('Storage initialization failed');
    }
  }

  // In your SplashScreen state class:
  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('first_launch') ?? true;

    // Restore system UI before navigation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (mounted) {
      // Instead of going straight to camera/onboarding,
      // go to a new choice screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => _ChoiceScreen(isFirstLaunch: isFirstLaunch)),
      );
    }
  }


  void _showPermissionDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Text(
              'Camera Permission Required',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            content: Text(
              'Chefify needs camera access to recognize ingredients from photos. Please enable camera permission in settings.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/onboarding-screen');
                },
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );
    }
  }

  void _showErrorDialog() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppTheme.lightTheme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Text(
              'Initialization Error',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
            content: Text(
              'There was an issue starting the app. Please check your device storage and try again.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _initializeApp();
                },
                child: const Text('Retry'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightTheme.primaryColor,
              AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoScaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // App Logo
                              Container(
                                width: 25.w,
                                height: 25.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 20.0,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomIconWidget(
                                    iconName: 'restaurant',
                                    size: 12.w,
                                    color: AppTheme.lightTheme.primaryColor,
                                  ),
                                ),
                              ),

                              SizedBox(height: 3.h),

                              // App Name
                              Text(
                                'Chefify',
                                style: AppTheme
                                    .lightTheme.textTheme.displaySmall
                                    ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),

                              SizedBox(height: 1.h),

                              // Tagline
                              Text(
                                'Cook Smart, Eat Better',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Loading Section
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading Indicator
                    SizedBox(
                      width: 8.w,
                      height: 8.w,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                        strokeWidth: 3.0,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Status Text
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _initializationStatus,
                        key: ValueKey(_initializationStatus),
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Section
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        'Discover recipes from your ingredients',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'camera_alt',
                            size: 4.w,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: 'arrow_forward',
                            size: 4.w,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: 'restaurant_menu',
                            size: 4.w,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceScreen extends StatelessWidget {
  final bool isFirstLaunch;
  const _ChoiceScreen({Key? key, required this.isFirstLaunch}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Welcome to Chefify'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'What would you like to do today?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.restaurant),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                // normal recipe flow
                if (isFirstLaunch) {
                  Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
                } else {
                  Navigator.pushReplacementNamed(context, AppRoutes.camera);
                }
              },
              label: const Text('Cook / Get Recipes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.volunteer_activism),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                // donation flow (your donation onboarding or map view)
                Navigator.pushReplacementNamed(context, AppRoutes.home); 
                // or AppRoutes.mapView if you want to go directly to map
              },
              label: const Text('Donate Food'),
            ),
          ],
        ),
      ),
    );
  }
}
