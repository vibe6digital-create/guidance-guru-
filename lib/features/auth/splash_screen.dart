import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/scale_fade_in.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../models/user_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _blob1Controller;
  late AnimationController _blob2Controller;

  late Animation<double> _blob1X, _blob1Y;
  late Animation<double> _blob2X, _blob2Y;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _blob1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _blob2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    final curve1 =
        CurvedAnimation(parent: _blob1Controller, curve: Curves.easeInOut);
    _blob1X = Tween<double>(begin: -20, end: 20).animate(curve1);
    _blob1Y = Tween<double>(begin: -15, end: 15).animate(curve1);

    final curve2 =
        CurvedAnimation(parent: _blob2Controller, curve: Curves.easeInOut);
    _blob2X = Tween<double>(begin: 15, end: -15).animate(curve2);
    _blob2Y = Tween<double>(begin: -20, end: 20).animate(curve2);

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final auth = context.read<AuthController>();
    await auth.checkAuthStatus();
    if (!mounted) return;

    if (auth.isAuthenticated && auth.user != null) {
      _navigateToDashboard(auth.user!.role);
    } else {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  void _navigateToDashboard(UserRole role) {
    switch (role) {
      case UserRole.student:
        Navigator.pushReplacementNamed(context, '/student-dashboard');
      case UserRole.parent:
        Navigator.pushReplacementNamed(context, '/parent-dashboard');
      case UserRole.counselor:
        Navigator.pushReplacementNamed(context, '/counselor-dashboard');
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _blob1Controller.dispose();
    _blob2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blobs =
        isDark ? AppColors.blobColorsDark : AppColors.blobColorsLight;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background matching GlassScaffold
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.glassBackgroundGradient(isDark),
            ),
          ),
          // Animated blobs
          AnimatedBuilder(
            listenable: _blob1Controller,
            builder: (context, _) => Positioned(
              top: -60 + _blob1Y.value,
              right: -40 + _blob1X.value,
              child: _Blob(
                size: 220,
                color: blobs[0].withValues(alpha: isDark ? 0.15 : 0.35),
              ),
            ),
          ),
          AnimatedBuilder(
            listenable: _blob2Controller,
            builder: (context, _) => Positioned(
              bottom: 100 + _blob2Y.value,
              left: -50 + _blob2X.value,
              child: _Blob(
                size: 180,
                color: blobs[1].withValues(alpha: isDark ? 0.12 : 0.3),
              ),
            ),
          ),
          // Centered content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo with glassmorphism card
                ScaleFadeIn(
                  duration: const Duration(milliseconds: 800),
                  beginScale: 0.5,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.glassSurface(isDark),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.glassBorder(isDark),
                        width: AppSizes.glassBorderWidth,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary)
                              .withValues(alpha: 0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _rotationController,
                          curve: Curves.linear,
                        ),
                      ),
                      child: AppLogo(
                        size: 52,
                        color: isDark
                            ? AppColors.primaryBright
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // App name
                FadeInWidget(
                  delay: const Duration(milliseconds: 400),
                  child: Text(
                    AppStrings.appName,
                    style: GoogleFonts.sora(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Tagline
                FadeInWidget(
                  delay: const Duration(milliseconds: 600),
                  child: Text(
                    AppStrings.appTagline,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
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
