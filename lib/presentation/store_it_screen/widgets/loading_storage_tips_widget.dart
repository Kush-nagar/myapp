// lib/presentation/store_it_screen/widgets/loading_storage_tips_widget.dart
// Modern, production-ready loading component for Storage Tips
// Aligned with app theme: Contemporary Culinary Minimalism
// Optimized for performance, accessibility, and professional deployment

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// A professional loading widget that displays animated storage tips
/// while content is being generated. Implements shimmer effects,
/// skeleton loaders, and smooth animations aligned with app theme.
class LoadingStorageTipsWidget extends StatefulWidget {
  const LoadingStorageTipsWidget({super.key});

  @override
  State<LoadingStorageTipsWidget> createState() =>
      _LoadingStorageTipsWidgetState();
}

class _LoadingStorageTipsWidgetState extends State<LoadingStorageTipsWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _shimmerAnimation;

  // Professional tip messages aligned with app functionality
  static const List<String> _storageTips = [
    'Analyzing ingredient freshness patterns...',
    'Calculating optimal storage temperatures...',
    'Processing shelf life recommendations...',
    'Reviewing nutritional preservation data...',
  ];

  int _currentTipIndex = 0;

  @override
  void initState() {
    super.initState();

    // Single unified animation controller for optimal performance
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat();

    // Smooth pulse effect for the icon
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    // Continuous rotation for loading indicator
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    // Shimmer effect for skeleton loaders
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
    );

    // Cycle through tips
    _controller.addListener(_updateTip);
  }

  void _updateTip() {
    final newIndex =
        (_controller.value * _storageTips.length).floor() % _storageTips.length;
    if (newIndex != _currentTipIndex) {
      setState(() => _currentTipIndex = newIndex);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateTip);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 700;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final t = _controller.value;
              final angle = t * math.pi * 2;

              // Animated begin/end alignment to slowly rotate the gradient direction.
              final begin = Alignment(math.cos(angle) * -0.8, math.sin(angle) * -0.6);
              final end = Alignment(math.cos(angle + math.pi) * 0.8, math.sin(angle + math.pi) * 0.6);

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: begin,
                    end: end,
                    colors: [
                      // subtle desaturated primary at the edge
                      colorScheme.primary.withOpacity(0.12),
                      // slightly warmer mid tone
                      colorScheme.primaryContainer.withOpacity(0.08),
                      // neutral canvas
                      colorScheme.surface,
                      // soft secondary wash near the opposite edge
                      colorScheme.secondary.withOpacity(0.04),
                    ],
                    stops: const [0.0, 0.25, 0.7, 1.0],
                  ),
                ),
                // layered overlays for depth without introducing heavy repaints
                child: Stack(
                  children: [
                    // Soft radial vignette to focus attention toward center
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.0, -0.18),
                            radius: 1.2,
                            colors: [
                              Colors.transparent,
                              colorScheme.primary.withOpacity(0.02),
                            ],
                            stops: const [0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Very subtle glossy highlight — rotated and animated slightly
                    Positioned(
                      top: -220,
                      left: -120,
                      child: Transform.rotate(
                        angle: -0.38 + (t - 0.5) * 0.12,
                        child: Container(
                          width: 720,
                          height: 720,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.02),
                                Colors.white.withOpacity(0.00),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Radial gradient overlay for depth
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Colors.transparent,
                    colorScheme.primary.withOpacity(0.02),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: isCompact ? 3.h : 5.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated loading icon with brand colors
                      _buildLoadingIcon(theme, colorScheme),

                      SizedBox(height: isCompact ? 4.h : 6.h),

                      // Title and subtitle
                      _buildHeaderSection(theme, colorScheme),

                      SizedBox(height: isCompact ? 3.h : 4.h),

                      // Progress indicator
                      _buildProgressIndicator(colorScheme),

                      SizedBox(height: isCompact ? 4.h : 5.h),

                      // Rotating tip messages
                      _buildTipCard(theme, colorScheme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the animated loading icon with brand gradient
  Widget _buildLoadingIcon(ThemeData theme, ColorScheme colorScheme) {
    return Semantics(
      label: 'Loading storage tips',
      liveRegion: true,
      child: SizedBox(
        width: 32.w,
        height: 32.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing outer glow
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.15),
                      colorScheme.primary.withOpacity(0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Rotating progress ring
            RotationTransition(
              turns: _rotateAnimation,
              child: Container(
                width: 26.w,
                height: 26.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.transparent,
                      colorScheme.primary.withOpacity(0.3),
                      colorScheme.secondary.withOpacity(0.5),
                      colorScheme.secondary.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),

            // Central icon with gradient background
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: Colors.white,
                size: 9.w,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header section with title and description
  Widget _buildHeaderSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Text(
          'Generating Storage Tips',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Text(
            'Our AI is analyzing your ingredients to provide personalized storage recommendations for optimal freshness.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// Builds the progress indicator with animated dots
  Widget _buildProgressIndicator(ColorScheme colorScheme) {
    return Column(
      children: [
        // Animated loading dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.2;
                final value = (_controller.value + delay) % 1.0;
                final scale =
                    0.5 + (math.sin(value * 2 * math.pi) * 0.5 + 0.5) * 0.5;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                    width: 2.5.w,
                    height: 2.5.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              },
            );
          }),
        ),

        SizedBox(height: 3.h),

        // Linear progress bar
        Container(
          width: 60.w,
          height: 6,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(3),
          ),
          child: AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Base progress
                  FractionallySizedBox(
                    widthFactor: 0.65,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.3),
                            colorScheme.secondary.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  // Shimmer overlay
                  Positioned(
                    left: (_shimmerAnimation.value * 60.w * 0.5).clamp(
                      0.0,
                      60.w,
                    ),
                    child: Container(
                      width: 15.w,
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.4),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the rotating tip card
  Widget _buildTipCard(ThemeData theme, ColorScheme colorScheme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(_currentTipIndex),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.tips_and_updates_outlined,
              color: colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                _storageTips[_currentTipIndex],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
