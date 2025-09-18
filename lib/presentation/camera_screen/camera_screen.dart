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
import '../../services/gemini_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isLoading = false;
  FlashMode _currentFlashMode = FlashMode.auto;
  int _selectedCameraIndex = 0; 

  late GeminiService _geminiService;

  Offset? _focusPoint;
  XFile? _recentPhoto;
  // ignore: unused_field
  XFile? _capturedImage;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final apiKey =
        "AIzaSyA2h7qv0IodTx2tiaavH3wD56qMCMSjDr4"; // 🔑 replace with dotenv if needed
    _geminiService = GeminiService(
      apiKey: apiKey,
      maxDimension: 1024,
      //unsplashKey: '98KP7IyvCWdYX0TLN8rTiKWBux0SW70ohmnTxmyb_o8',
    );

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
    } catch (_) {}
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialogWidget(
        title: 'Camera Permission Required',
        message:
            'Chefify needs camera access to recognize ingredients from photos.',
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
    setState(() => _isLoading = true);

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
        _recentPhoto = photo;
      });

      final rawResults = await _geminiService.detectFoods(photo.path);
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

      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['existingIngredients'] != null) {
        // Return new detections to RecognitionResultsScreen
        Navigator.pop(context, results);
      } else {
        // First-time flow
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
      }
    } catch (e) {
      _showErrorSnackBar('Recognition failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() => _recentPhoto = image);

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

      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null && args['existingIngredients'] != null) {
        Navigator.pop(context, results);
      } else {
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
    if (kIsWeb) return;
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
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      _showErrorSnackBar('Failed to switch camera');
    }
  }

  void _onTapToFocus() {
    setState(() => _focusPoint = Offset(50.w, 50.h));
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) setState(() => _focusPoint = null);
    });
  }

  void _showManualEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => ManualEntryDialogWidget(
        onIngredientsEntered: (ingredients) {
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
    _showErrorSnackBar('Settings screen coming soon!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreviewWidget(
            cameraController: _cameraController,
            isInitialized: _isCameraInitialized,
            onTapToFocus: _onTapToFocus,
            focusPoint: _focusPoint,
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CameraTopBarWidget(
              onSettingsPressed: _navigateToSettings,
              showBackButton: false,
            ),
          ),
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
