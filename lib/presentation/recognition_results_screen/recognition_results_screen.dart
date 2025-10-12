import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_ingredient_modal_widget.dart';
import './widgets/captured_image_header_widget.dart';
import './widgets/empty_recognition_widget.dart';
import './widgets/ingredient_chip_widget.dart';
import './widgets/loading_skeleton_widget.dart';

class RecognitionResultsScreen extends StatefulWidget {
  const RecognitionResultsScreen({Key? key}) : super(key: key);

  @override
  State<RecognitionResultsScreen> createState() =>
      _RecognitionResultsScreenState();
}

class _RecognitionResultsScreenState extends State<RecognitionResultsScreen> {
  bool _isLoading = true;
  String? _capturedImagePath;
  List<Map<String, dynamic>> _recognizedIngredients = [];

  /// Minimum confidence threshold to keep a detected label (adjustable)
  final double _minConfidence = 0.35;

  @override
  void initState() {
    super.initState();
    _initializeRecognition();
  }

  String _normalizeName(String raw) {
    final lower = raw.trim().toLowerCase();
    // basic plural -> singular naive handling
    if (lower.endsWith('es')) return lower.substring(0, lower.length - 2);
    if (lower.endsWith('s')) return lower.substring(0, lower.length - 1);
    return lower;
  }

  Map<String, dynamic> _makeIngredientObject({
    required String name,
    double confidence = 1.0,
    String category = 'detected',
    dynamic boundingBox,
  }) {
    final normalized = _normalizeName(name);
    return {
      'id': DateTime.now().millisecondsSinceEpoch ^ normalized.hashCode,
      'name': normalized[0].toUpperCase() + normalized.substring(1),
      'confidence': (confidence).clamp(0.0, 1.0),
      'category': category,
      'boundingBox': boundingBox,
    };
  }

  Future<void> _initializeRecognition() async {
    // Read navigation args once the widget is laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // Defaults
      List<Map<String, dynamic>> items = [];

      if (args != null) {
        // Image path (optional)
        _capturedImagePath = args['imagePath'] as String?;

        // Manual ingredients (from manual entry)
        if (args['manualIngredients'] != null) {
          final List<dynamic> manual =
              args['manualIngredients'] as List<dynamic>;
          for (var m in manual) {
            if (m is String && m.trim().isNotEmpty) {
              items.add(
                _makeIngredientObject(
                  name: m,
                  confidence: 1.0,
                  category: 'manual',
                ),
              );
            }
          }
        }

        // Detected ingredients (from VisionService or backend)
        if (args['detectedIngredients'] != null) {
          final List<dynamic> detected = List<dynamic>.from(
            args['detectedIngredients'] as List<dynamic>,
          );
          for (var d in detected) {
            // Expect each d to be a Map with at least a 'name' and optional 'confidence'
            try {
              final rawName = (d['name'] ?? d['label'] ?? '').toString();
              final conf = (d['confidence'] ?? d['score'] ?? 0.0) as num;
              final box = d['boundingBox'] ?? d['boundingPoly'] ?? null;

              if (rawName.trim().isEmpty) continue;

              // ignore: unnecessary_cast
              if ((conf as num).toDouble() < _minConfidence) {
                // skip low-confidence detections
                continue;
              }

              items.add(
                _makeIngredientObject(
                  name: rawName,
                  // ignore: unnecessary_cast
                  confidence: (conf as num).toDouble(),
                  category: 'detected',
                  boundingBox: box,
                ),
              );
            } catch (_) {
              // ignore malformed entries
              continue;
            }
          }
        }
      }

      // Remove duplicates by name (keep highest confidence)
      final Map<String, Map<String, dynamic>> dedup = {};
      for (var it in items) {
        final key = (it['name'] as String).toLowerCase();
        if (!dedup.containsKey(key) ||
            (it['confidence'] as double) >
                (dedup[key]!['confidence'] as double)) {
          dedup[key] = it;
        }
      }

      setState(() {
        _recognizedIngredients = dedup.values.toList();
        _isLoading = false;
      });
    });
  }

  void _removeIngredient(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _recognizedIngredients.removeAt(index);
    });
  }

  void _addIngredient(String ingredientName) {
    final newIngredient = _makeIngredientObject(
      name: ingredientName,
      confidence: 1.0, // Manual additions assumed high confidence
      category: 'manual',
    );

    setState(() {
      _recognizedIngredients.add(newIngredient);
    });

    HapticFeedback.lightImpact();
  }

  void _showAddIngredientModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddIngredientModalWidget(onAddIngredient: _addIngredient),
    );
  }

  void _editIngredientName(int index, String currentName) {
    final TextEditingController controller = TextEditingController(
      text: currentName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Ingredient',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Ingredient name',
            hintText: 'Enter ingredient name',
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  // Replace name but preserve id/confidence/category
                  _recognizedIngredients[index]['name'] =
                      newName[0].toUpperCase() + newName.substring(1);
                });
              }
              Navigator.of(context).pop();
            },
            child: Text(
              'Save',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _retakePhoto() {
    Navigator.of(context).pop();
  }

  void _tryAgainRecognition() {
    setState(() {
      _isLoading = true;
      _recognizedIngredients.clear();
    });
    _initializeRecognition();
  }

  void _findRecipes() {
    if (_recognizedIngredients.isNotEmpty) {
      final ingredientNames = _recognizedIngredients
          .map((ingredient) => ingredient['name'] as String)
          .toList();

      Navigator.pushNamed(
        context,
        '/recipe-suggestions-screen',
        arguments: {
          'ingredients': ingredientNames,
          'imagePath': _capturedImagePath,
        },
      );
    }
  }

  void _donateItems() {
    if (_recognizedIngredients.isEmpty) return;

    // Gather ingredient names (lowercase normalized) to send to HomeScreen
    final ingredientNames = _recognizedIngredients
        .map((i) => (i['name'] as String).toLowerCase())
        .toList();

    // Navigate to home screen and replace stack (so Home shows filtered results).
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-screen',
      (route) => false,
      arguments: {
        'donationIngredients': ingredientNames,
      },
    );
  }

  void _storeItems() {
    if (_recognizedIngredients.isEmpty) return;

    // Example local-store flow: show a bottom sheet to pick storage options
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Store Items',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'Choose where to store this list for later:',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to My Lists')),
                      );
                    },
                    child: Text('My Lists'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to Pantry')),
                      );
                    },
                    child: Text('Pantry'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_recognizedIngredients.isNotEmpty) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Discard Changes?',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'You have selected ingredients. Are you sure you want to go back?',
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
                'Discard',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          centerTitle: true,
          title: Text(
            'Recognition Results',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          leading: IconButton(
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          actions: [
            if (!_isLoading && _recognizedIngredients.isNotEmpty)
              IconButton(
                onPressed: _tryAgainRecognition,
                icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            _tryAgainRecognition();
          },
          child: Column(
            children: [
              // Header with captured image
              CapturedImageHeaderWidget(
                imagePath: _capturedImagePath,
                onRetake: _retakePhoto,
              ),

              // Main content
              Expanded(
                child: _isLoading
                    ? const LoadingSkeletonWidget()
                    : _recognizedIngredients.isEmpty
                        ? EmptyRecognitionWidget(
                            onTryAgain: _tryAgainRecognition,
                            onAddManually: _showAddIngredientModal,
                          )
                        : SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Recognized Ingredients',
                                          style: AppTheme
                                              .lightTheme
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        SizedBox(height: 0.5.h),
                                        Text(
                                          '${_recognizedIngredients.length} items detected',
                                          style: AppTheme
                                              .lightTheme
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: _showAddIngredientModal,
                                      icon: CustomIconWidget(
                                        iconName: 'add',
                                        color:
                                            AppTheme.lightTheme.colorScheme.primary,
                                        size: 5.w,
                                      ),
                                      label: Text(
                                        'Add',
                                        style: AppTheme
                                            .lightTheme
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                              color: AppTheme
                                                  .lightTheme
                                                  .colorScheme
                                                  .primary,
                                            ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 2.h),

                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                  color: AppTheme.lightTheme.colorScheme.surface,
                                  child: Padding(
                                    padding: EdgeInsets.all(3.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Wrap(
                                          spacing: 2.w,
                                          runSpacing: 1.5.h,
                                          children: _recognizedIngredients
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final ingredient = entry.value;

                                            return Dismissible(
                                              key: Key(
                                                'ingredient_${ingredient['id']}',
                                              ),
                                              direction:
                                                  DismissDirection.endToStart,
                                              onDismissed: (_) =>
                                                  _removeIngredient(index),
                                              background: Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                padding: EdgeInsets.only(
                                                  right: 4.w,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .error,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: CustomIconWidget(
                                                  iconName: 'delete',
                                                  color: Colors.white,
                                                  size: 6.w,
                                                ),
                                              ),
                                              child: IngredientChipWidget(
                                                ingredientName:
                                                    ingredient['name']
                                                        as String,
                                                confidence:
                                                    (ingredient['confidence']
                                                            as num)
                                                        .toDouble(),
                                                onRemove: () =>
                                                    _removeIngredient(index),
                                                onLongPress: () =>
                                                    _editIngredientName(
                                                      index,
                                                      ingredient['name']
                                                          as String,
                                                    ),
                                              ),
                                            );
                                          })
                                              .toList(),
                                        ),

                                        SizedBox(height: 2.h),

                                        // Confidence legend (fixed overflow by using Wrap + constrained chips)
                                        Container(
                                          padding: EdgeInsets.all(3.w),
                                          decoration: BoxDecoration(
                                            color: AppTheme
                                                .lightTheme
                                                .colorScheme
                                                .surfaceVariant,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Wrap(
                                            spacing: 3.w,
                                            runSpacing: 1.2.h,
                                            children: [
                                              _buildConfidenceLegend(
                                                color: AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .tertiary,
                                                label: 'High (80%+)',
                                              ),
                                              _buildConfidenceLegend(
                                                color: AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .secondary,
                                                label: 'Medium (50-80%)',
                                              ),
                                              _buildConfidenceLegend(
                                                color: AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .error,
                                                label: 'Low (<50%)',
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: 2.h),

                                        // Subtle helper text
                                        Text(
                                          'Tip: Long-press an item to edit its name. Swipe left to remove.',
                                          style: AppTheme
                                              .lightTheme
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppTheme
                                                    .lightTheme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),

                                        SizedBox(height: 1.h),

                                        // Quick actions inside the card (icons added and spacing tightened)
                                        Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton.icon(
                                                onPressed: _findRecipes,
                                                icon: CustomIconWidget(
                                                  iconName: 'restaurant_menu',
                                                  color: Colors.white,
                                                  size: 5.w,
                                                ),
                                                label: Text(
                                                  'Find Recipes',
                                                  style: AppTheme
                                                      .lightTheme
                                                      .textTheme
                                                      .labelLarge
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                      ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 1.6.h,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 3.w),
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: _donateItems,
                                                icon: CustomIconWidget(
                                                  iconName: 'favorite',
                                                  color: AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .primary,
                                                  size: 5.w,
                                                ),
                                                label: Text(
                                                  'Donate It',
                                                  style: AppTheme
                                                      .lightTheme
                                                      .textTheme
                                                      .labelLarge,
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 1.6.h,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 2.h),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton.icon(
                                                onPressed: _storeItems,
                                                icon: CustomIconWidget(
                                                  iconName: 'inventory',
                                                  color: AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .onSurface,
                                                  size: 5.w,
                                                ),
                                                label: Text(
                                                  'Store It',
                                                  style: AppTheme
                                                      .lightTheme
                                                      .textTheme
                                                      .labelLarge,
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 1.6.h,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 3.w),
                                            SizedBox(
                                              width: 36.w,
                                              child: ElevatedButton.icon(
                                                onPressed: () async {
                                                  // Push camera again but keep current ingredients
                                                  final newIngredients =
                                                      await Navigator.pushNamed(
                                                    context,
                                                    '/camera-screen',
                                                    arguments: {
                                                      'existingIngredients':
                                                          _recognizedIngredients,
                                                    },
                                                  );

                                                  if (newIngredients != null &&
                                                      newIngredients
                                                          is List<
                                                              Map<String,
                                                                  dynamic>>) {
                                                    setState(() {
                                                      // Merge old + new
                                                      _recognizedIngredients.addAll(
                                                        newIngredients,
                                                      );
                                                      // Deduplicate by name
                                                      final dedup =
                                                          <String,
                                                              Map<String,
                                                                  dynamic>>{};
                                                      for (var it
                                                          in _recognizedIngredients) {
                                                        final key =
                                                            (it['name']
                                                                    as String)
                                                                .toLowerCase();
                                                        if (!dedup.containsKey(
                                                              key,
                                                            ) ||
                                                            (it['confidence']
                                                                    as double) >
                                                                (dedup[key]![
                                                                        'confidence']
                                                                    as double)) {
                                                          dedup[key] = it;
                                                        }
                                                      }
                                                      _recognizedIngredients =
                                                          dedup.values.toList();
                                                    });
                                                  }
                                                },
                                                icon: CustomIconWidget(
                                                  iconName: 'add_a_photo',
                                                  color: Colors.white,
                                                  size: 5.w,
                                                ),
                                                label: Text(
                                                  'Add Photo',
                                                  style: AppTheme
                                                      .lightTheme
                                                      .textTheme
                                                      .labelLarge
                                                      ?.copyWith(
                                                        color: Colors.white,
                                                      ),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 1.6.h,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                  backgroundColor: AppTheme
                                                      .lightTheme
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 1.h),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: 6.h), // Space for bottom area
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

  Widget _buildConfidenceLegend({required Color color, required String label}) {
    return Container(
      constraints: BoxConstraints(maxWidth: 40.w),
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.background.withOpacity(0.02),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 2.w),
          Flexible(
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}