import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/student_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/loading_widget.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<StudentController>().loadTestHistory(
        studentId: context.read<AuthController>().user?.id,
      );
      if (mounted) setState(() => _loading = false);
    });
  }

  Color _bandColor(double score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String _bandLabel(double score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Average';
    return 'Below Average';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final d = date;
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = context.watch<StudentController>();

    return GlassScaffold(
      appBar: const GlassAppBar(title: AppStrings.testHistory),
      body: SafeArea(
        child: _loading
            ? const LoadingWidget()
            : student.testHistory.isEmpty
                ? Center(
                    child: Text(
                      'No tests taken yet',
                      style: GoogleFonts.dmSans(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: student.testHistory.length,
                    itemBuilder: (context, index) {
                      final test = student.testHistory[index];
                      final score = test.score ?? 0;
                      final color = _bandColor(score);
                      final band = _bandLabel(score);

                      return AnimatedListItem(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SurfaceCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        test.title,
                                        style: GoogleFonts.sora(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${score.toInt()}% - $band',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  test.description,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded,
                                        size: 14,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(test.completedAt),
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.timer_rounded,
                                        size: 14,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${test.durationMinutes} min',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
