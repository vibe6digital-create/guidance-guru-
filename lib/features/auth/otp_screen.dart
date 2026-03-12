import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/scale_fade_in.dart';
import '../../models/user_model.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  int _resendCountdown = 60;
  Timer? _timer;
  late AnimationController _animController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticIn),
    );
  }

  void _startCountdown() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _navigateToDashboard(UserRole role) {
    final route = switch (role) {
      UserRole.student => '/student-dashboard',
      UserRole.parent => '/parent-dashboard',
      UserRole.counselor => '/counselor-dashboard',
    };
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  Future<void> _verifyOtp(String otp) async {
    final auth = context.read<AuthController>();
    final success = await auth.verifyOtp(otp);

    if (!mounted) return;

    if (success) {
      // If user already exists in Firestore, navigate directly
      if (auth.user != null) {
        _navigateToDashboard(auth.user!.role);
        return;
      }

      // New user from signup — register with Firestore
      final role = auth.selectedRole;
      if (role != null && auth.signupName != null) {
        final registered = await auth.registerWithRole(
          name: auth.signupName!,
          role: role,
          email: auth.signupEmail,
        );
        if (!mounted) return;
        if (registered) {
          // New accounts (student/parent) pick a counsellor first
          if (role == UserRole.student || role == UserRole.parent) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/select-counselor-signup', (_) => false);
          } else {
            _navigateToDashboard(role);
          }
        }
      } else if (role != null) {
        // Login flow — new user without signup data, go to role selection
        Navigator.pushNamedAndRemoveUntil(
            context, '/role-selection', (_) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, '/welcome', (_) => false);
      }
    } else {
      _animController.forward().then((_) => _animController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 56,
      textStyle: GoogleFonts.jetBrainsMono(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.error, width: 2),
      ),
    );

    return GlassScaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white.withValues(alpha: 0.7),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ScaleFadeIn(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 36,
                      color: isDark ? AppColors.primaryBright : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeInWidget(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Verify OTP',
                    style: GoogleFonts.sora(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeInWidget(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Enter the 6-digit code sent to\n${auth.loginIdentifier}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                FadeInWidget(
                  delay: const Duration(milliseconds: 400),
                  child: AnimatedValueBuilder(
                    listenable: _shakeAnimation,
                    builder: (context, child) => Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    ),
                    child: Pinput(
                    length: 6,
                    controller: _otpController,
                    focusNode: _focusNode,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    errorPinTheme: errorPinTheme,
                    onCompleted: _verifyOtp,
                    autofocus: true,
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                  ),
                ),
                ),
                const SizedBox(height: 24),
                if (auth.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: isDark ? AppColors.errorBright : AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          auth.errorMessage!,
                          style: GoogleFonts.dmSans(
                            color: AppColors.error,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _resendCountdown > 0
                    ? Text(
                        'Resend OTP in ${_resendCountdown}s',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          final authCtrl = context.read<AuthController>();
                          if (authCtrl.isEmailLogin) {
                            authCtrl.sendEmailOtp(authCtrl.email ?? '');
                          } else {
                            authCtrl.sendOtp(authCtrl.phone ?? '');
                          }
                          _startCountdown();
                        },
                        child: Text(
                          AppStrings.resendOtp,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.primaryBright : AppColors.primary,
                          ),
                        ),
                      ),
                const SizedBox(height: 32),
                CustomButton(
                  text: AppStrings.verifyOtp,
                  isLoading: auth.state == AuthState.loading,
                  onPressed: auth.state == AuthState.loading
                      ? null
                      : () {
                          if (_otpController.text.length == 6) {
                            _verifyOtp(_otpController.text);
                          }
                        },
                ),
              ],
            ),
          ),
      ),
    );
  }
}
