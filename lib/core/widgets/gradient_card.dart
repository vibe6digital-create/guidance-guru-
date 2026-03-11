import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class GradientCard extends StatefulWidget {
  final Widget child;
  final Gradient? gradient;
  final double borderRadius;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool glassmorphism;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.borderRadius = AppSizes.cardRadius,
    this.padding = const EdgeInsets.all(AppSizes.cardPadding),
    this.onTap,
    this.glassmorphism = false,
  });

  @override
  State<GradientCard> createState() => _GradientCardState();
}

class _GradientCardState extends State<GradientCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTap = widget.onTap != null;

    Widget card;

    if (widget.glassmorphism) {
      card = Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.5),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      );
    } else {
      card = Container(
        decoration: BoxDecoration(
          gradient: widget.gradient ??
              (isDark ? AppColors.cardGradientDark : AppColors.cardGradient),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            children: [
              // Glass light reflection at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius),
                  child: Padding(
                      padding: widget.padding, child: widget.child),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasTap) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: card,
        ),
      );
    }

    return card;
  }
}

class SurfaceCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool glassmorphism;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.cardPadding),
    this.onTap,
    this.borderRadius = AppSizes.cardRadius,
    this.glassmorphism = false,
  });

  @override
  State<SurfaceCard> createState() => _SurfaceCardState();
}

class _SurfaceCardState extends State<SurfaceCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasTap = widget.onTap != null;

    final card = Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
              : AppColors.divider.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Stack(
          children: [
            // Subtle top highlight
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.08 : 0.3),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: Padding(padding: widget.padding, child: widget.child),
              ),
            ),
          ],
        ),
      ),
    );

    if (hasTap) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: card,
        ),
      );
    }

    return card;
  }
}
