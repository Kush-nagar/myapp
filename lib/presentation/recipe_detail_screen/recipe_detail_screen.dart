import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/cooking_steps_section.dart';
import './widgets/dietary_tags_widget.dart';
import './widgets/ingredients_section.dart';
import './widgets/nutrition_section.dart';
import './widgets/recipe_hero_section.dart';
import './widgets/start_cooking_bar.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({Key? key}) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isSaved = false;
  int completedSteps = 0;
  int completedIngredients = 0;

  late Map<String, dynamic> recipeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    recipeData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
  }

  void _toggleSave() {
    setState(() {
      isSaved = !isSaved;
    });

    Fluttertoast.showToast(
      msg: isSaved ? "Recipe saved!" : "Recipe removed from saved",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isSaved ? Colors.green : Colors.grey[600],
      textColor: Colors.white,
    );
  }

  void _onIngredientToggle(int index, bool isChecked) {
    setState(() {
      if (isChecked) {
        completedIngredients++;
      } else {
        completedIngredients--;
      }
    });
  }

  void _onStepToggle(int index, bool isCompleted) {
    setState(() {
      if (isCompleted) {
        completedSteps++;
      } else {
        completedSteps--;
      }
    });
  }

  void _addToShoppingList(String ingredient) {
    Fluttertoast.showToast(
      msg: "$ingredient added to shopping list",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.primaryColor,
      textColor: Colors.white,
    );
  }

  void _startCooking() {
    final steps = (recipeData['steps'] as List?) ?? [];
    if (completedSteps == steps.length) {
      // Reset cooking progress
      setState(() {
        completedSteps = 0;
        completedIngredients = 0;
      });
      Fluttertoast.showToast(
        msg: "Starting fresh cooking session!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Step-by-step cooking mode activated!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.primaryColor,
        textColor: Colors.white,
      );
    }
  }

  void _shareRecipe() {
    final title = recipeData['title'] ?? "Recipe";
    final cookingTime = recipeData['cookingTime'] ?? "N/A";
    final servings = recipeData['servings'] ?? "N/A";
    final difficulty = recipeData['difficulty'] ?? "N/A";

    final ingredients = (recipeData['ingredients'] as List?)
            ?.map((i) => "• $i")
            .join('\n') ??
        "";

    final steps = (recipeData['steps'] as List?)
            ?.asMap()
            .entries
            .map((e) => "${e.key + 1}. ${e.value}")
            .join('\n\n') ??
        "";

    final nutrition = recipeData['nutrition'] as Map<String, dynamic>? ?? {};

    final recipeText = """
$title

Cooking Time: $cookingTime minutes
Servings: $servings
Difficulty: $difficulty

Ingredients:
$ingredients

Instructions:
$steps

Nutrition (per serving):
• Calories: ${nutrition['calories'] ?? "N/A"}
• Protein: ${nutrition['protein'] ?? "N/A"}g
• Carbs: ${nutrition['carbs'] ?? "N/A"}g
• Fat: ${nutrition['fat'] ?? "N/A"}g

Shared from Chefify App
    """;

    Clipboard.setData(ClipboardData(text: recipeText));

    Fluttertoast.showToast(
      msg: "Recipe copied to clipboard!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.primaryColor,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ingredients =
        (recipeData['ingredients'] as List?)?.cast<String>() ?? [];
    final steps = (recipeData['steps'] as List?)?.cast<String>() ?? [];
    final dietaryTags =
        (recipeData['dietaryTags'] as List?)?.cast<String>() ?? [];
    final nutrition = recipeData['nutrition'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                RecipeHeroSection(
                  recipe: recipeData,
                  onBack: () => Navigator.pop(context),
                  onSave: _toggleSave,
                  isSaved: isSaved,
                ),

                SizedBox(height: 2.h),

                // Dietary Tags
                DietaryTagsWidget(tags: dietaryTags),

                SizedBox(height: 1.h),

                // Description
                if (recipeData['description'] != null) ...[
                  Container(
                    width: double.infinity,
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Text(
                      recipeData['description'] ?? "",
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 2.h),

                // Ingredients Section
                IngredientsSection(
                  ingredients: ingredients
                      .map((i) =>
                          {"name": i, "amount": "", "available": true})
                      .toList(),
                  onIngredientToggle: _onIngredientToggle,
                  onAddToShoppingList: _addToShoppingList,
                ),

                SizedBox(height: 3.h),

                // Cooking Steps Section
                CookingStepsSection(
                  steps: steps
                      .map((s) => {"instruction": s, "duration": null})
                      .toList(),
                  onStepToggle: _onStepToggle,
                ),

                SizedBox(height: 3.h),

                // Nutrition Section
                NutritionSection(nutrition: nutrition),

                SizedBox(height: 12.h), // Space for bottom bar
              ],
            ),
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: StartCookingBar(
              onStartCooking: _startCooking,
              onShare: _shareRecipe,
              completedSteps: completedSteps,
              totalSteps: steps.length,
            ),
          ),
        ],
      ),
    );
  }
}