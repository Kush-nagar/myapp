import 'package:flutter/material.dart';
import '../presentation/camera_screen/camera_screen.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/recipe_suggestions_screen/recipe_suggestions_screen.dart';
import '../presentation/recognition_results_screen/recognition_results_screen.dart';
import '../presentation/recipe_detail_screen/recipe_detail_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String camera = '/camera-screen';
  static const String onboarding = '/onboarding-screen';
  static const String splash = '/splash-screen';
  static const String recipeSuggestions = '/recipe-suggestions-screen';
  static const String recognitionResults = '/recognition-results-screen';
  static const String recipeDetail = '/recipe-detail-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    camera: (context) => const CameraScreen(),
    onboarding: (context) => const OnboardingScreen(),
    splash: (context) => const SplashScreen(),
    recipeSuggestions: (context) => const RecipeSuggestionsScreen(),
    recognitionResults: (context) => const RecognitionResultsScreen(),
    recipeDetail: (context) => const RecipeDetailScreen(),
    // TODO: Add your other routes here
  };
}
