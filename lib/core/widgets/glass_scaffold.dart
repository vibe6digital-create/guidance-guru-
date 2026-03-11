import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GlassScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blobs = isDark ? AppColors.blobColorsDark : AppColors.blobColorsLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
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
          // Static decorative blobs (no animation, no blur)
          Positioned(
            top: -60,
            right: -40,
            child: _Blob(
              size: 200,
              color: blobs[0].withValues(alpha: isDark ? 0.12 : 0.25),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -60,
            child: _Blob(
              size: 160,
              color: blobs[1].withValues(alpha: isDark ? 0.10 : 0.22),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -30,
            child: _Blob(
              size: 120,
              color: blobs[2].withValues(alpha: isDark ? 0.08 : 0.22),
            ),
          ),
          // Actual content
          Scaffold(
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
            appBar: appBar,
            body: body,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: floatingActionButton,
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
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
