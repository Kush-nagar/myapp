import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool isInitialized;
  final VoidCallback onTapToFocus;
  final Offset? focusPoint;

  const CameraPreviewWidget({
    Key? key,
    required this.cameraController,
    required this.isInitialized,
    required this.onTapToFocus,
    this.focusPoint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || cameraController == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
      );
    }

    return GestureDetector(
      onTapUp: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        // ignore: unused_local_variable
        final Offset localPoint = box.globalToLocal(details.globalPosition);
        onTapToFocus();
      },
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(cameraController!),
          ),
          // Grid overlay
          _buildGridOverlay(),
          // Focus indicator
          if (focusPoint != null) _buildFocusIndicator(),
          // Ingredient detection hints
          _buildDetectionHints(),
        ],
      ),
    );
  }

  Widget _buildGridOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(painter: GridPainter()),
    );
  }

  Widget _buildFocusIndicator() {
    return Positioned(
      left: focusPoint!.dx - 30,
      top: focusPoint!.dy - 30,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.lightTheme.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildDetectionHints() {
    return Positioned(
      top: 20.h,
      left: 5.w,
      right: 5.w,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Point camera at ingredients for best recognition',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(2 * size.width / 3, 0),
      Offset(2 * size.width / 3, size.height),
      paint,
    );

    // Horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, 2 * size.height / 3),
      Offset(size.width, 2 * size.height / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
