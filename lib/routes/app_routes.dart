import 'package:flutter/material.dart';

import '../presentation/camera_screen/camera_screen.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/recipe_suggestions_screen/recipe_suggestions_screen.dart';
import '../presentation/recognition_results_screen/recognition_results_screen.dart';
import '../presentation/recipe_detail_screen/recipe_detail_screen.dart';
import '../presentation/organization_detail_screen/organization_detail_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/search_filter_screen/search_filter_screen.dart';
import '../presentation/favorites_screen/favorites_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/map_view_screen/map_view_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String camera = '/camera-screen';
  static const String onboarding = '/onboarding-screen';
  static const String splash = '/splash-screen';
  static const String recipeSuggestions = '/recipe-suggestions-screen';
  static const String recognitionResults = '/recognition-results-screen';
  static const String recipeDetail = '/recipe-detail-screen';
  static const String organizationDetail = '/organization-detail-screen';
  static const String onboardingFlow = '/onboarding-flow';
  static const String searchFilter = '/search-filter-screen';
  static const String favorites = '/favorites-screen';
  static const String home = '/home-screen';
  static const String mapView = '/map-view-screen';



  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    camera: (context) => const CameraScreen(),
    recognitionResults: (context) => const RecognitionResultsScreen(),
    recipeSuggestions: (context) => const RecipeSuggestionsScreen(),
    recipeDetail: (context) => const RecipeDetailScreen(),
    organizationDetail: (context) => const OrganizationDetailScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    searchFilter: (context) => const SearchFilterScreen(),
    favorites: (context) => const FavoritesScreen(),
    home: (context) => const HomeScreen(),
    mapView: (context) => const MapViewScreen(),
  };
}
