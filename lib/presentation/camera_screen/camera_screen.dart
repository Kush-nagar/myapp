// lib/screens/camera/camera_screen.dart
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/camera_controls_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/camera_top_bar_widget.dart';
import './widgets/manual_entry_dialog_widget.dart';
import './widgets/permission_dialog_widget.dart';

// replace VisionService import with GeminiService
import '../../services/gemini_service.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  // Camera related variables
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  FlashMode _currentFlashMode = FlashMode.auto;
  int _selectedCameraIndex = 0;

  // Gemini service
  late GeminiService _geminiService;

  // UI state variables
  Offset? _focusPoint;
  XFile? _recentPhoto;
  XFile? _capturedImage;

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // load API key (if you use flutter_dotenv load it in main() before runApp)
    final apiKey =
        "AIzaSyA2h7qv0IodTx2tiaavH3wD56qMCMSjDr4"; // replace or use dotenv

    _geminiService = GeminiService(apiKey: apiKey, maxDimension: 1024);

    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) {
        _showPermissionDialog();
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showErrorSnackBar('No cameras available on this device');
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first,
            )
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first,
            );

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to initialize camera: ${e.toString()}');
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(_currentFlashMode);
      }
    } catch (e) {
      // Silently handle unsupported features
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialogWidget(
        title: 'Camera Permission Required',
        message:
            'Chefify needs camera access to recognize ingredients from photos. Please grant camera permission to continue.',
        onOpenSettings: () async {
          Navigator.of(context).pop();
          await openAppSettings();
        },
        onCancel: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
        _recentPhoto = photo;
      });

      // Call Gemini service
      final rawResults = await _geminiService.detectFoods(photo.path);

      // Map to your UI format
      final results = rawResults.map((r) {
        final name = (r['name'] ?? '') as String;
        return {
          'id': DateTime.now().millisecondsSinceEpoch ^ name.hashCode,
          'name': name,
          'confidence': (r['confidence'] as num?)?.toDouble() ?? 0.0,
          'category': 'detected',
          'boundingBox': r['boundingBox'],
        };
      }).toList();

      _cameraController?.dispose();
      Navigator.pushNamed(
        context,
        '/recognition-results-screen',
        arguments: {
          'imagePath': photo.path,
          'imageSource': 'camera',
          'detectedIngredients': results,
        },
      );
    } catch (e) {
      _showErrorSnackBar('Recognition failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _recentPhoto = image;
        });

        final rawResults = await _geminiService.detectFoods(image.path);

        final results = rawResults.map((r) {
          final name = (r['name'] ?? '') as String;
          return {
            'id': DateTime.now().millisecondsSinceEpoch ^ name.hashCode,
            'name': name,
            'confidence': (r['confidence'] as num?)?.toDouble() ?? 0.0,
            'category': 'detected',
            'boundingBox': r['boundingBox'],
          };
        }).toList();

        _cameraController?.dispose();
        Navigator.pushNamed(
          context,
          '/recognition-results-screen',
          arguments: {
            'imagePath': image.path,
            'imageSource': 'gallery',
            'detectedIngredients': results,
          },
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select image: $e');
    }
  }

  void _toggleFlash() {
    if (kIsWeb) return; // Flash not supported on web

    setState(() {
      switch (_currentFlashMode) {
        case FlashMode.off:
          _currentFlashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _currentFlashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _currentFlashMode = FlashMode.off;
          break;
        case FlashMode.torch:
          _currentFlashMode = FlashMode.off;
          break;
      }
    });

    _cameraController?.setFlashMode(_currentFlashMode);
  }

  void _flipCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
      _isCameraInitialized = false;
    });

    await _cameraController?.dispose();

    _cameraController = CameraController(
      _cameras[_selectedCameraIndex],
      kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to switch camera');
    }
  }

  void _onTapToFocus() {
    // Focus animation feedback
    setState(() {
      _focusPoint = Offset(50.w, 50.h);
    });

    // Remove focus indicator after animation
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _focusPoint = null;
        });
      }
    });
  }

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => ManualEntryDialogWidget(
        onIngredientsEntered: (ingredients) {
          // Navigate to recognition results with manual ingredients
          _cameraController?.dispose();
          Navigator.pushNamed(
            context,
            '/recognition-results-screen',
            arguments: {
              'manualIngredients': ingredients,
              'imageSource': 'manual',
            },
          );
        },
      ),
    );
  }

  void _navigateToSettings() {
    // Navigate to settings screen (placeholder for now)
    _showErrorSnackBar('Settings screen coming soon!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          CameraPreviewWidget(
            cameraController: _cameraController,
            isInitialized: _isCameraInitialized,
            onTapToFocus: _onTapToFocus,
            focusPoint: _focusPoint,
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CameraTopBarWidget(
              onSettingsPressed: _navigateToSettings,
              showBackButton: false,
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CameraControlsWidget(
              onCapturePhoto: _capturePhoto,
              onGalleryTap: _selectFromGallery,
              onFlashToggle: _toggleFlash,
              onCameraFlip: _flipCamera,
              onManualEntry: _showManualEntryDialog,
              currentFlashMode: _currentFlashMode,
              recentPhoto: _recentPhoto,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
