import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/scale_fade_in.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo
              ScaleFadeIn(
                delay: const Duration(milliseconds: 100),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const AppLogo(
                    size: 52,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // App name
              FadeInWidget(
                delay: const Duration(milliseconds: 200),
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
              const SizedBox(height: 12),
              // Tagline
              FadeInWidget(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  AppStrings.appTagline,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(flex: 3),
              // Sign Up button
              FadeInWidget(
                delay: const Duration(milliseconds: 400),
                child: CustomButton(
                  text: AppStrings.signUp,
                  onPressed: () {
                    Navigator.pushNamed(context, '/role-selection');
                  },
                  icon: Icons.person_add_rounded,
                ),
              ),
              const SizedBox(height: 14),
              // Login button
              FadeInWidget(
                delay: const Duration(milliseconds: 500),
                child: CustomButton(
                  text: AppStrings.login,
                  isOutlined: true,
                  onPressed: () {
                    Navigator.pushNamed(context, '/role-selection',
                        arguments: {'nextRoute': '/login'});
                  },
                  icon: Icons.login_rounded,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
