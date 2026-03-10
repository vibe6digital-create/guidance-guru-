import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/scale_fade_in.dart';
import '../../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  late AnimationController _bgController;
  bool _otpNavigated = false;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    if (_formKey.currentState?.validate() ?? false) {
      _otpNavigated = false;
      final phone = _phoneController.text.trim();
      context.read<AuthController>().sendOtp('+91$phone');
    }
  }

  String _roleLabel(UserRole? role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
      case UserRole.counselor:
        return 'Counselor';
      default:
        return '';
    }
  }

  IconData _roleIcon(UserRole? role) {
    switch (role) {
      case UserRole.student:
        return Icons.school_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
      case UserRole.counselor:
        return Icons.psychology_rounded;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: Consumer<AuthController>(
        builder: (context, auth, _) {
          if (auth.state == AuthState.otpSent && !_otpNavigated) {
            _otpNavigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushNamed(context, '/otp');
            });
          }

          final isDark = Theme.of(context).brightness == Brightness.dark;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Back button
                  FadeInWidget(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.surfaceDark
                              : Colors.white.withValues(alpha: 0.7),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Logo
                  ScaleFadeIn(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const AppLogo(
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  FadeInWidget(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      AppStrings.appName,
                      style: GoogleFonts.sora(
                        fontSize: 28,
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
                    delay: const Duration(milliseconds: 250),
                    child: Text(
                      AppStrings.appTagline,
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Role badge
                  if (auth.selectedRole != null)
                    FadeInWidget(
                      delay: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_roleIcon(auth.selectedRole),
                                size: 18,
                                color: isDark
                                    ? AppColors.primaryBright
                                    : AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Logging in as ${_roleLabel(auth.selectedRole)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.primaryBright
                                    : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  // Form card
                  AnimatedListItem(
                    index: 0,
                    delay: const Duration(milliseconds: 400),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter your phone number',
                              style: GoogleFonts.sora(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'We\'ll send you a verification code',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 56,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceDark
                                        : AppColors.backgroundLight,
                                    borderRadius: BorderRadius.circular(
                                        AppSizes.radiusMd),
                                    border: Border.all(
                                        color: isDark
                                            ? AppColors.dividerDark
                                            : AppColors.divider),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '+91',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: _phoneController,
                                    hint: AppStrings.phoneHint,
                                    prefixIcon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    validator: Validators.phone,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => _onSendOtp(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (auth.errorMessage != null) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.error.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: isDark
                                            ? AppColors.errorBright
                                            : AppColors.error,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        auth.errorMessage!,
                                        style: GoogleFonts.dmSans(
                                          color: AppColors.error,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            CustomButton(
                              text: AppStrings.sendOtp,
                              onPressed: auth.state == AuthState.loading
                                  ? null
                                  : _onSendOtp,
                              isLoading: auth.state == AuthState.loading,
                              icon: Icons.arrow_forward_rounded,
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  final role =
                                      auth.selectedRole ?? UserRole.student;
                                  auth.setMockUser(role);
                                  final route = switch (role) {
                                    UserRole.student => '/student-dashboard',
                                    UserRole.parent => '/parent-dashboard',
                                    UserRole.counselor =>
                                      '/counselor-dashboard',
                                  };
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, route, (_) => false);
                                },
                                child: Text(
                                  'Skip Login (Demo)',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.primaryBright
                                        : AppColors.primary,
                                  ),
                                ),
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
    );
  }
}
