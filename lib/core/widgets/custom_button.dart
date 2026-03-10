import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = AppSizes.buttonHeight,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  late AnimationController _shadowController;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Shimmer sheen — one-shot
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _shimmerController.forward();
    });

    // Shadow depth animation
    _shadowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _shadowAnimation = Tween<double>(begin: 16, end: 8).animate(
      CurvedAnimation(parent: _shadowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _shadowController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _scaleController.forward();
    _shadowController.forward();
  }

  void _onTapUp() {
    _scaleController.reverse();
    _shadowController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _onTapDown() : null,
      onTapUp: isEnabled ? (_) => _onTapUp() : null,
      onTapCancel: isEnabled ? () => _onTapUp() : null,
      child: AnimatedValueBuilder(
        listenable: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: AnimatedBuilder(
          listenable: Listenable.merge([_shimmerAnimation, _shadowAnimation]),
          builder: (context, child) {
            final shadowBlur =
                isEnabled && !widget.isOutlined ? _shadowAnimation.value : 0.0;
            return Container(
              width: widget.width ?? double.infinity,
              height: widget.height,
              decoration: BoxDecoration(
                gradient: widget.isOutlined
                    ? null
                    : (isEnabled
                        ? (isDark
                            ? AppColors.buttonGradientDark
                            : AppColors.buttonGradient)
                        : null),
                color: widget.isOutlined
                    ? Colors.white.withValues(alpha: isDark ? 0.06 : 0.15)
                    : (isEnabled
                        ? null
                        : isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                border: widget.isOutlined
                    ? Border.all(
                        color:
                            isDark ? AppColors.primaryBright : AppColors.primary,
                        width: 1.5,
                      )
                    : null,
                boxShadow: isEnabled && !widget.isOutlined
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: shadowBlur,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                child: Stack(
                  children: [
                    // Shimmer sheen overlay
                    if (isEnabled &&
                        !widget.isOutlined &&
                        _shimmerController.isAnimating)
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.25,
                          child: FractionallySizedBox(
                            widthFactor: 0.4,
                            alignment: Alignment(
                                _shimmerAnimation.value * 2 - 1, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0),
                                    Colors.white.withValues(alpha: 0.5),
                                    Colors.white.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Button content
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: isEnabled ? widget.onPressed : null,
                        borderRadius:
                            BorderRadius.circular(AppSizes.buttonRadius),
                        child: Center(
                          child: widget.isLoading
                              ? _PulsingSpinner(
                                  color: widget.isOutlined
                                      ? (isDark
                                          ? AppColors.primaryBright
                                          : AppColors.primary)
                                      : Colors.white,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.icon != null) ...[
                                      Icon(
                                        widget.icon,
                                        color: widget.isOutlined
                                            ? (isDark
                                                ? AppColors.primaryBright
                                                : AppColors.primary)
                                            : Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Text(
                                      widget.text,
                                      style: TextStyle(
                                        fontSize: AppSizes.fontLg,
                                        fontWeight: FontWeight.w600,
                                        color: widget.isOutlined
                                            ? (isDark
                                                ? AppColors.primaryBright
                                                : AppColors.primary)
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PulsingSpinner extends StatefulWidget {
  final Color color;
  const _PulsingSpinner({required this.color});

  @override
  State<_PulsingSpinner> createState() => _PulsingSpinnerState();
}

class _PulsingSpinnerState extends State<_PulsingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_controller),
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
        ),
      ),
    );
  }
}

class AnimatedValueBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedValueBuilder({
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
