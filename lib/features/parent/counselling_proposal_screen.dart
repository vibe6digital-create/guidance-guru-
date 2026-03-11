import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/parent_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../models/counselor_model.dart';

class CounsellingProposalScreen extends StatefulWidget {
  const CounsellingProposalScreen({super.key});

  @override
  State<CounsellingProposalScreen> createState() =>
      _CounsellingProposalScreenState();
}

class _CounsellingProposalScreenState extends State<CounsellingProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _sessionsController = TextEditingController();
  final _outcomesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _sessionsController.dispose();
    _outcomesController.dispose();
    super.dispose();
  }

  Future<void> _submitProposal(CounselorModel counselor) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final auth = context.read<AuthController>();
    final parentCtrl = context.read<ParentController>();
    await parentCtrl.sendCounsellingProposal(
      counselor: counselor,
      reason: _reasonController.text.trim(),
      numberOfSessions: int.parse(_sessionsController.text.trim()),
      expectedOutcomes: _outcomesController.text.trim(),
      parentId: auth.user?.id,
      parentName: auth.user?.name,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    Helpers.showSnackBar(context, AppStrings.proposalSentSuccess);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counselor = ModalRoute.of(context)!.settings.arguments as CounselorModel;

    return GlassScaffold(
      appBar: const GlassAppBar(title: AppStrings.sendProposal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Counselor info summary
              _CounselorSummary(counselor: counselor),
              const SizedBox(height: 24),

              // Reason field
              Text(
                AppStrings.proposalReasonLabel,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _reasonController,
                hint: AppStrings.proposalReasonHint,
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please explain why you need this counsellor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Number of sessions
              Text(
                AppStrings.numberOfSessions,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _sessionsController,
                hint: AppStrings.numberOfSessionsHint,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v.trim());
                  if (n == null || n < 1 || n > 20) {
                    return 'Enter a number between 1 and 20';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Expected outcomes
              Text(
                AppStrings.expectedOutcomes,
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _outcomesController,
                hint: AppStrings.expectedOutcomesHint,
                maxLines: 4,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please describe the expected outcomes';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit button
              CustomButton(
                text: AppStrings.sendProposal,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : () => _submitProposal(counselor),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounselorSummary extends StatelessWidget {
  final CounselorModel counselor;

  const _CounselorSummary({required this.counselor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.5),
          width: AppSizes.glassBorderWidth,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isDark
                  ? AppColors.buttonGradientDark
                  : AppColors.buttonGradient,
            ),
            child: Center(
              child: Text(
                counselor.name[0],
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  counselor.name,
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${counselor.specialization}  •  \u20B9${counselor.pricePerSession.toInt()}/session',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
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
