import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/counselor_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../models/report_model.dart';

class AddRemarkScreen extends StatefulWidget {
  const AddRemarkScreen({super.key});

  @override
  State<AddRemarkScreen> createState() => _AddRemarkScreenState();
}

class _AddRemarkScreenState extends State<AddRemarkScreen> {
  final _messageController = TextEditingController();
  final _actionItemController = TextEditingController();
  RemarkType _selectedType = RemarkType.general;
  final List<String> _actionItems = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _messageController.dispose();
    _actionItemController.dispose();
    super.dispose();
  }

  void _addActionItem() {
    final text = _actionItemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _actionItems.add(text);
        _actionItemController.clear();
      });
    }
  }

  void _removeActionItem(int index) {
    setState(() => _actionItems.removeAt(index));
  }

  void _submitRemark() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final counselor = context.read<CounselorController>();
    final student = counselor.selectedStudent;
    if (student == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Submit Remark?',
            style: GoogleFonts.sora(fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        content: Text(
          'This remark will be visible to the student and their parent.',
          style: GoogleFonts.dmSans(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Submit',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final auth = context.read<AuthController>();
    final success = await counselor.addRemark(
      studentId: student['id'] as String,
      message: _messageController.text.trim(),
      type: _selectedType,
      actionItems: _actionItems,
      counselorId: auth.user?.id,
      counselorName: auth.user?.name,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remark added successfully')),
      );
      Navigator.pop(context);
    }
  }

  final _remarkTypes = [
    {'type': RemarkType.general, 'label': 'General', 'icon': Icons.chat_bubble_outline_rounded, 'color': AppColors.primary},
    {'type': RemarkType.academic, 'label': 'Academic', 'icon': Icons.school_rounded, 'color': AppColors.success},
    {'type': RemarkType.career, 'label': 'Career', 'icon': Icons.work_outline_rounded, 'color': AppColors.primary},
    {'type': RemarkType.urgent, 'label': 'Urgent', 'icon': Icons.priority_high_rounded, 'color': AppColors.error},
  ];

  @override
  Widget build(BuildContext context) {
    final counselor = context.watch<CounselorController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: 'Add Remark',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.md),
          children: [
            // Remark type selector
            Text('Remark Type',
                style: GoogleFonts.sora(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 12),
            Row(
              children: _remarkTypes.map((rt) {
                final isSelected = _selectedType == rt['type'];
                final color = rt['color'] as Color;
                final iconColor = isDark
                    ? (color == AppColors.primary ? AppColors.primaryBright
                        : color == AppColors.success ? AppColors.successBright
                        : color == AppColors.error ? AppColors.errorBright
                        : color)
                    : color;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedType = rt['type'] as RemarkType),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: isDark ? 0.2 : 0.1)
                              : isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : isDark ? AppColors.dividerDark : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(rt['icon'] as IconData,
                                color: isSelected
                                    ? iconColor
                                    : isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                size: 22),
                            const SizedBox(height: 4),
                            Text(
                              rt['label'] as String,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? color
                                    : isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Message
            Text('Remark Message',
                style: GoogleFonts.sora(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _messageController,
              hint: 'Write your detailed remark here...',
              maxLines: 6,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Message is required' : null,
            ),
            const SizedBox(height: 24),
            // Action items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Action Items',
                    style: GoogleFonts.sora(
                        fontSize: 16, fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                Text('(Optional)',
                    style: GoogleFonts.dmSans(
                        fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _actionItemController,
                    hint: 'Add an action item',
                    prefixIcon: Icons.add_task_rounded,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addActionItem(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addActionItem,
                  icon: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._actionItems.asMap().entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline_rounded,
                            color: isDark ? AppColors.primaryBright : AppColors.primary, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(entry.value,
                              style: GoogleFonts.dmSans(fontSize: 14,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded,
                              size: 18, color: isDark ? AppColors.errorBright : AppColors.error),
                          onPressed: () => _removeActionItem(entry.key),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 32),
            // Submit
            CustomButton(
              text: 'Submit Remark',
              icon: Icons.send_rounded,
              isLoading: counselor.state == CounselorLoadState.loading,
              onPressed: counselor.state == CounselorLoadState.loading
                  ? null
                  : _submitRemark,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
