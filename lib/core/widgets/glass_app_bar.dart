import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class GlassAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Widget? titleWidget;

  const GlassAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.titleWidget,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.appBarHeight);

  @override
  State<GlassAppBar> createState() => _GlassAppBarState();
}

class _GlassAppBarState extends State<GlassAppBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;
    final foreground = isDark ? Colors.white : AppColors.textPrimary;

    Widget? titleContent = widget.titleWidget ??
        (widget.title != null
            ? Text(
                widget.title!,
                style: GoogleFonts.sora(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              )
            : null);

    // Wrap title in animation
    if (titleContent != null) {
      titleContent = FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: titleContent,
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppSizes.glassBlurSigma,
            sigmaY: AppSizes.glassBlurSigma,
          ),
          child: Container(
            padding: EdgeInsets.only(top: topPadding),
            decoration: BoxDecoration(
              color: AppColors.glassSurface(isDark),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.glassBorder(isDark),
                  width: AppSizes.glassBorderWidth,
                ),
              ),
            ),
            child: SizedBox(
              height: AppSizes.appBarHeight,
              child: NavigationToolbar(
                leading: widget.leading ??
                    (widget.automaticallyImplyLeading &&
                            Navigator.canPop(context)
                        ? IconButton(
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: foreground,
                            ),
                            onPressed: () => Navigator.pop(context),
                          )
                        : null),
                middle: titleContent,
                trailing: widget.actions != null
                    ? IconTheme(
                        data: IconThemeData(color: foreground),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.actions!,
                        ),
                      )
                    : null,
                centerMiddle: true,
                middleSpacing: NavigationToolbar.kMiddleSpacing,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
