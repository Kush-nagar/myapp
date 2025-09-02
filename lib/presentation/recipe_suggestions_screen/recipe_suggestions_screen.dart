// lib/screens/recipe_suggestions/recipe_suggestions_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/gemini_service.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/ingredient_chip_widget.dart';
import './widgets/quick_actions_dialog_widget.dart';
import './widgets/recipe_card_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';


class RecipeSuggestionsScreen extends StatefulWidget {
  const RecipeSuggestionsScreen({Key? key}) : super(key: key);

  @override
  State<RecipeSuggestionsScreen> createState() =>
      _RecipeSuggestionsScreenState();
}

class _RecipeSuggestionsScreenState extends State<RecipeSuggestionsScreen> {
  List<String> selectedIngredients = [];
  String selectedFilter = 'All';
  String selectedSort = 'match';
  bool isLoading = false;

  // Now starts empty; will be populated by Gemini
  final List<Map<String, dynamic>> allRecipes = [];

  late final GeminiService _geminiService;

  @override
  void initState() {
    super.initState();

    // IMPORTANT: don't hardcode your real API key in source for production.
    // Use secure storage, environment variables or native build-time variables.
    _geminiService = GeminiService(apiKey: 'AIzaSyBHaPa5KHVpklOP9d_I6B1q4W-4d09FfsQ');

    // ✅ Read navigation args after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['ingredients'] != null) {
        setState(() {
          selectedIngredients = List<String>.from(args['ingredients']);
        });

        _fetchRecipesFromGemini(); // fetch only once we have ingredients
      }
    });
  }

  List<Map<String, dynamic>> get filteredRecipes {
    List<Map<String, dynamic>> filtered = allRecipes.where((recipe) {
      final dietaryTags = (recipe['dietaryTags'] as List).cast<String>();
      return selectedFilter == 'All' || dietaryTags.contains(selectedFilter);
    }).toList();

    // Sort recipes
    switch (selectedSort) {
      case 'match':
        filtered.sort((a, b) =>
            (b['matchPercentage'] as num).compareTo(a['matchPercentage'] as num));
        break;
      case 'time':
        filtered.sort((a, b) =>
            (a['cookingTime'] as num).compareTo(b['cookingTime'] as num));
        break;
      case 'difficulty':
        final difficultyOrder = {'Easy': 1, 'Medium': 2, 'Hard': 3};
        filtered.sort((a, b) => (difficultyOrder[a['difficulty']] ?? 2)
            .compareTo(difficultyOrder[b['difficulty']] ?? 2));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Recipe Suggestions',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Theme.of(context).appBarTheme.iconTheme?.color ?? Colors.black,
            size: 6.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'sort',
              color: Theme.of(context).appBarTheme.iconTheme?.color ??
                  Colors.black,
              size: 6.w,
            ),
            onPressed: _showSortBottomSheet,
          ),
        ],
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        bottom: isLoading
            ? PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(
                  minHeight: 3,
                ),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshSuggestions,
        child: Column(
          children: [
            _buildIngredientsSection(),
            _buildFiltersSection(),
            Expanded(
              child: filteredRecipes.isEmpty && !isLoading
                  ? EmptyStateWidget(onClearFilters: _clearFilters)
                  : _buildRecipesList(),
            ),
          ],
        ),
      ),
      floatingActionButton: isLoading
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildIngredientsSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selected Ingredients',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Edit Ingredients',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SizedBox(
            height: 5.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: selectedIngredients.length,
              itemBuilder: (context, index) {
                return IngredientChipWidget(
                  ingredient: selectedIngredients[index],
                  onRemove: () => _removeIngredient(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    final filters = ['All', 'Vegetarian', 'Keto'];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: SizedBox(
        height: 5.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            return FilterChipWidget(
              label: filter,
              isSelected: selectedFilter == filter,
              onTap: () => _selectFilter(filter),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecipesList() {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 2.h),
      itemCount: filteredRecipes.length,
      itemBuilder: (context, index) {
        final recipe = filteredRecipes[index];
        return RecipeCardWidget(
          recipe: recipe,
          onTap: () => _navigateToRecipeDetail(recipe),
          onLongPress: () => _showQuickActions(recipe),
        );
      },
    );
  }

  void _removeIngredient(int index) {
    setState(() {
      selectedIngredients.removeAt(index);
    });
    HapticFeedback.lightImpact();

    // Refresh suggestions (optional). Comment out if you prefer manual refresh.
    _fetchRecipesFromGemini();
  }

  void _selectFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    HapticFeedback.selectionClick();
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SortBottomSheetWidget(
        selectedSort: selectedSort,
        onSortSelected: (sort) {
          setState(() {
            selectedSort = sort;
          });
          HapticFeedback.selectionClick();
        },
      ),
    );
  }

  Future<void> _refreshSuggestions() async {
    await _fetchRecipesFromGemini();
  }

  void _clearFilters() {
    setState(() {
      selectedFilter = 'All';
      selectedSort = 'match';
    });
    HapticFeedback.lightImpact();

    // optionally refresh
    _fetchRecipesFromGemini();
  }

  void _navigateToRecipeDetail(Map<String, dynamic> recipe) {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/recipe-detail-screen', arguments: recipe);
  }

  void _showQuickActions(Map<String, dynamic> recipe) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => QuickActionsDialogWidget(
        recipe: recipe,
        onSave: () => _saveRecipe(recipe),
        onShare: () => _shareRecipe(recipe),
        onSimilar: () => _findSimilarRecipes(recipe),
      ),
    );
  }

  void _saveRecipe(Map<String, dynamic> recipe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recipe "${recipe['title']}" saved successfully!'),
        backgroundColor: AppTheme.successLight,
      ),
    );
    HapticFeedback.lightImpact();
  }

  void _shareRecipe(Map<String, dynamic> recipe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${recipe['title']}"...'),
      ),
    );
    HapticFeedback.lightImpact();
  }

  void _findSimilarRecipes(Map<String, dynamic> recipe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Finding recipes similar to "${recipe['title']}"...'),
      ),
    );
    HapticFeedback.lightImpact();
  }

  // ----------------- Gemini fetch / normalization -----------------

  Future<void> _fetchRecipesFromGemini() async {
    setState(() {
      isLoading = true;
    });

    try {
      final raw = await _geminiService.generateRecipesFromIngredients(
        selectedIngredients,
        maxRecipes: 8,
      );

      // Normalize & compute match metrics
      int idCounter = 1;
      final normalized = raw.map<Map<String, dynamic>>((r) {
        final recipeIngredients = _normalizeIngredientList(r['ingredients']);
        final availableIngredients = recipeIngredients.where((ing) =>
            selectedIngredients.any((s) => s.toLowerCase() == ing.toLowerCase())).length;
        final totalIngredients = recipeIngredients.isEmpty ? 1 : recipeIngredients.length;
        final matchPercentage = ((availableIngredients / totalIngredients) * 100).round();

        return {
          "id": idCounter++,
          "title": r['title'] ?? 'Untitled Recipe',
          "image": r.containsKey('image') ? r['image'] : null,
          "cookingTime": (r['cookingTime'] is num)
              ? r['cookingTime']
              : ((r['cooking_time'] is num) ? r['cooking_time'] : 0),
          "difficulty": r['difficulty'] ?? 'Easy',
          "matchPercentage": matchPercentage,
          "availableIngredients": availableIngredients,
          "totalIngredients": totalIngredients,
          "dietaryTags": (r['dietaryTags'] as List?)?.cast<String>() ?? ['All'],
          "ingredients": recipeIngredients,
          "nutrition": (r['nutrition'] is Map) ? r['nutrition'] : {},
          "instructions": r['instructions'] ?? [],
        };
      }).toList();

      setState(() {
        allRecipes
          ..clear()
          ..addAll(normalized);
      });
    } catch (e, st) {
      // Show user-friendly error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch recipes: ${e.toString()}')),
      );
      // optionally log stacktrace to console for debugging
      // debugPrint(st.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
      HapticFeedback.lightImpact();
    }
  }

  List<String> _normalizeIngredientList(dynamic raw) {
    try {
      if (raw == null) return [];
      if (raw is List) {
        return raw.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
      }
      if (raw is String) {
        // if model returns a single comma-separated string
        return raw
            .split(RegExp(r',|\n|;'))
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}