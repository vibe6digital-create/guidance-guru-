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
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

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
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: isEnabled ? (_) => _scaleController.forward() : null,
      onTapUp: isEnabled ? (_) => _scaleController.reverse() : null,
      onTapCancel: isEnabled ? () => _scaleController.reverse() : null,
      child: AnimatedValueBuilder(
        listenable: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
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
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? widget.onPressed : null,
              borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isOutlined
                                ? (isDark
                                    ? AppColors.primaryBright
                                    : AppColors.primary)
                                : Colors.white,
                          ),
                        ),
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
