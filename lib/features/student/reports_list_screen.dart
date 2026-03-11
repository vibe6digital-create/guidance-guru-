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

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<StudentController>().loadReportsList(
        studentId: context.read<AuthController>().user?.id,
      );
      if (mounted) setState(() => _loading = false);
    });
  }

  Color _bandColor(String band) {
    switch (band.toLowerCase()) {
      case 'excellent':
        return AppColors.success;
      case 'good':
        return Colors.blue;
      case 'average':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = context.watch<StudentController>();

    return GlassScaffold(
      appBar: const GlassAppBar(title: AppStrings.reportsList),
      body: SafeArea(
        child: _loading
            ? const LoadingWidget()
            : student.reportsList.isEmpty
                ? Center(
                    child: Text(
                      'No reports generated yet',
                      style: GoogleFonts.dmSans(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: student.reportsList.length,
                    itemBuilder: (context, index) {
                      final report = student.reportsList[index];
                      final bandColor = _bandColor(report.performanceBand);

                      return AnimatedListItem(
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SurfaceCard(
                            onTap: () {
                              context
                                  .read<StudentController>()
                                  .setCurrentReport(report);
                              Navigator.pushNamed(context, '/ai-report');
                            },
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title row with score badge
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Report #${index + 1}',
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
                                        color: bandColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${report.overallScore.toInt()}% - ${report.performanceBand}',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: bandColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Date
                                Text(
                                  _formatDate(report.generatedAt),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Category scores
                                ...report.categoryScores.map((cs) {
                                  final scoreColor = cs.score >= 85
                                      ? AppColors.success
                                      : cs.score >= 70
                                          ? Colors.blue
                                          : cs.score >= 50
                                              ? AppColors.warning
                                              : AppColors.error;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Text(
                                            cs.category,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: cs.score / 100,
                                              backgroundColor: scoreColor
                                                  .withValues(alpha: 0.12),
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      scoreColor),
                                              minHeight: 8,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: 36,
                                          child: Text(
                                            '${cs.score.toInt()}%',
                                            textAlign: TextAlign.right,
                                            style: GoogleFonts.jetBrainsMono(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: scoreColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                // Counsellor remark summary
                                if (report.remarks.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.comment_rounded,
                                          size: 14,
                                          color: isDark
                                              ? AppColors.primaryBright
                                              : AppColors.primary),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              report.remarks.first
                                                  .counselorName,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? AppColors.primaryBright
                                                    : AppColors.primary,
                                              ),
                                            ),
                                            Text(
                                              report.remarks.first.message
                                                          .length >
                                                      80
                                                  ? '${report.remarks.first.message.substring(0, 80)}...'
                                                  : report
                                                      .remarks.first.message,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 12,
                                                color: isDark
                                                    ? AppColors
                                                        .textSecondaryDark
                                                    : AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                // Tap indicator
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'View Full Report',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.primaryBright
                                            : AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward_rounded,
                                        size: 14,
                                        color: isDark
                                            ? AppColors.primaryBright
                                            : AppColors.primary),
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
