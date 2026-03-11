import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/parent_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';

class LinkStudentScreen extends StatefulWidget {
  const LinkStudentScreen({super.key});

  @override
  State<LinkStudentScreen> createState() => _LinkStudentScreenState();
}

class _LinkStudentScreenState extends State<LinkStudentScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _linkStudent() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final parent = context.read<ParentController>();
    final success = await parent.linkStudent(
      _codeController.text.trim(),
      parentId: context.read<AuthController>().user?.id,
    );

    if (mounted && success) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: isDark ? AppColors.successBright : AppColors.success, size: 48),
            ),
            const SizedBox(height: 16),
            Text('Student Linked!',
                style: GoogleFonts.sora(
                    fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'You can now view their test results and career reports.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                  fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Done',
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parent = context.watch<ParentController>();

    return GlassScaffold(
      appBar: GlassAppBar(
        title: AppStrings.linkStudent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              GradientCard(
                glassmorphism: true,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.link_rounded,
                          color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Enter the unique student code provided by the student or counselor.',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text('Student Code',
                  style: GoogleFonts.sora(
                      fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _codeController,
                hint: AppStrings.enterStudentCode,
                prefixIcon: Icons.badge_outlined,
                validator: Validators.studentCode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _linkStudent(),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Link Student',
                icon: Icons.link_rounded,
                isLoading: parent.state == ParentLoadState.loading,
                onPressed: parent.state == ParentLoadState.loading
                    ? null
                    : _linkStudent,
              ),
              if (parent.errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: isDark ? AppColors.errorBright : AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          parent.errorMessage!,
                          style: GoogleFonts.dmSans(
                              color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // QR code option
              Center(
                child: Column(
                  children: [
                    Text('Or',
                        style: GoogleFonts.dmSans(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Scan QR Code',
                      isOutlined: true,
                      icon: Icons.qr_code_scanner_rounded,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: Row(
                              children: [
                                Icon(Icons.qr_code_scanner_rounded,
                                    color: isDark
                                        ? AppColors.primaryBright
                                        : AppColors.primary),
                                const SizedBox(width: 10),
                                Text('QR Scanner',
                                    style: GoogleFonts.sora(
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            content: Text(
                              'QR scanning requires camera access. For now, please enter the student code manually using the field above.',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, height: 1.4),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text('Got it',
                                    style: GoogleFonts.dmSans(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
