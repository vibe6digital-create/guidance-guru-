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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _otpNavigated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
      case UserRole.counselor:
        return 'Counselor';
    }
  }

  IconData _roleIcon(UserRole role) {
    switch (role) {
      case UserRole.student:
        return Icons.school_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
      case UserRole.counselor:
        return Icons.psychology_rounded;
    }
  }

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.student:
        return AppColors.primary;
      case UserRole.parent:
        return AppColors.accent;
      case UserRole.counselor:
        return AppColors.warning;
    }
  }

  String _roleSubtitle(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Set up your student profile to take career tests and get AI-powered guidance';
      case UserRole.parent:
        return 'Create your account to monitor your child\'s progress and career path';
      case UserRole.counselor:
        return 'Register to guide students with insights, remarks, and career advice';
    }
  }

  void _onSignUp() {
    final auth = context.read<AuthController>();
    final role = auth.selectedRole;
    if (role == null) {
      Navigator.pop(context);
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      _otpNavigated = false;
      final phone = '+91${_phoneController.text.trim()}';
      auth.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: phone,
        role: role,
      );
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
          final role = auth.selectedRole ?? UserRole.student;
          final roleColor = _roleColor(role);

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
                  // Role icon
                  ScaleFadeIn(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: roleColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _roleIcon(role),
                        size: 40,
                        color: roleColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Role badge
                  FadeInWidget(
                    delay: const Duration(milliseconds: 150),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: roleColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_roleIcon(role), size: 18, color: roleColor),
                          const SizedBox(width: 8),
                          Text(
                            'Signing up as ${_roleLabel(role)}',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: roleColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  FadeInWidget(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      AppStrings.createAccount,
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
                  // Personalized subtitle
                  FadeInWidget(
                    delay: const Duration(milliseconds: 250),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _roleSubtitle(role),
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Form card
                  AnimatedListItem(
                    index: 0,
                    delay: const Duration(milliseconds: 350),
                    child: SurfaceCard(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Details',
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
                              'We\'ll use this to create your account',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Full Name
                            CustomTextField(
                              controller: _nameController,
                              hint: AppStrings.fullName,
                              prefixIcon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.name,
                              validator: Validators.name,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            // Email
                            CustomTextField(
                              controller: _emailController,
                              hint: 'Email address',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validators.email,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            // Phone
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
                                    onSubmitted: (_) => _onSignUp(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Error message
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
                            // Sign Up button
                            CustomButton(
                              text: AppStrings.signUp,
                              onPressed: auth.state == AuthState.loading
                                  ? null
                                  : _onSignUp,
                              isLoading: auth.state == AuthState.loading,
                              icon: Icons.arrow_forward_rounded,
                            ),
                            const SizedBox(height: 16),
                            // Skip Sign Up (Demo)
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  auth.setMockUser(role, isNewSignup: true);
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
                                  'Skip Sign Up (Demo)',
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
                  const SizedBox(height: 24),
                  // Already have an account? Login
                  FadeInWidget(
                    delay: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            AppStrings.login,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
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
