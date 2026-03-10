import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class GlassScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  const GlassScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  State<GlassScaffold> createState() => _GlassScaffoldState();
}

class _GlassScaffoldState extends State<GlassScaffold>
    with TickerProviderStateMixin {
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;
  late AnimationController _blob3Controller;

  late Animation<double> _blob1X;
  late Animation<double> _blob1Y;
  late Animation<double> _blob1Scale;

  late Animation<double> _blob2X;
  late Animation<double> _blob2Y;
  late Animation<double> _blob2Scale;

  late Animation<double> _blob3X;
  late Animation<double> _blob3Y;
  late Animation<double> _blob3Scale;

  @override
  void initState() {
    super.initState();

    _blob1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _blob2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _blob3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    final curve1 = CurvedAnimation(parent: _blob1Controller, curve: Curves.easeInOut);
    _blob1X = Tween<double>(begin: -20, end: 20).animate(curve1);
    _blob1Y = Tween<double>(begin: -15, end: 15).animate(curve1);
    _blob1Scale = Tween<double>(begin: 0.95, end: 1.05).animate(curve1);

    final curve2 = CurvedAnimation(parent: _blob2Controller, curve: Curves.easeInOut);
    _blob2X = Tween<double>(begin: 15, end: -15).animate(curve2);
    _blob2Y = Tween<double>(begin: -20, end: 20).animate(curve2);
    _blob2Scale = Tween<double>(begin: 1.05, end: 0.95).animate(curve2);

    final curve3 = CurvedAnimation(parent: _blob3Controller, curve: Curves.easeInOut);
    _blob3X = Tween<double>(begin: -10, end: 20).animate(curve3);
    _blob3Y = Tween<double>(begin: 10, end: -15).animate(curve3);
    _blob3Scale = Tween<double>(begin: 0.97, end: 1.03).animate(curve3);
  }

  @override
  void dispose() {
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    _blob3Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blobs = isDark ? AppColors.blobColorsDark : AppColors.blobColorsLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      body: Stack(
        children: [
          // Gradient background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.glassBackgroundGradient(isDark),
            ),
          ),
          // Animated decorative blobs
          AnimatedBuilder(
            listenable: _blob1Controller,
            builder: (context, child) => Positioned(
              top: -60 + _blob1Y.value,
              right: -40 + _blob1X.value,
              child: Transform.scale(
                scale: _blob1Scale.value,
                child: _Blob(
                  size: 200,
                  color: blobs[0].withValues(alpha: isDark ? 0.15 : 0.35),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            listenable: _blob2Controller,
            builder: (context, child) => Positioned(
              bottom: 120 + _blob2Y.value,
              left: -60 + _blob2X.value,
              child: Transform.scale(
                scale: _blob2Scale.value,
                child: _Blob(
                  size: 160,
                  color: blobs[1].withValues(alpha: isDark ? 0.12 : 0.3),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            listenable: _blob3Controller,
            builder: (context, child) => Positioned(
              top: MediaQuery.of(context).size.height * 0.4 + _blob3Y.value,
              right: -30 + _blob3X.value,
              child: Transform.scale(
                scale: _blob3Scale.value,
                child: _Blob(
                  size: 120,
                  color: blobs[2].withValues(alpha: isDark ? 0.1 : 0.3),
                ),
              ),
            ),
          ),
          // Actual content
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
            appBar: widget.appBar,
            body: widget.body,
            bottomNavigationBar: widget.bottomNavigationBar,
            floatingActionButton: widget.floatingActionButton,
          ),
        ],
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: AppSizes.glassBlurSigma * 3,
        sigmaY: AppSizes.glassBlurSigma * 3,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
