import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import '../../controllers/auth_controller.dart';
import '../../controllers/student_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../models/report_model.dart';
import '../../services/pdf_service.dart';

class AiReportScreen extends StatefulWidget {
  const AiReportScreen({super.key});

  @override
  State<AiReportScreen> createState() => _AiReportScreenState();
}

class _AiReportScreenState extends State<AiReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<StudentController>();
      if (controller.currentReport == null) {
        controller.loadReport(
          studentId: context.read<AuthController>().user?.id,
        );
      }
    });
  }

  void _shareReport(ReportModel report) {
    final buffer = StringBuffer();
    buffer.writeln('Guidance Guru - AI Career Report');
    buffer.writeln('================================');
    buffer.writeln('Overall Score: ${report.overallScore.toInt()}% (${report.performanceBand})');
    buffer.writeln();
    if (report.aiSummary != null) {
      buffer.writeln('Summary: ${report.aiSummary}');
      buffer.writeln();
    }
    buffer.writeln('Career Recommendations:');
    for (var i = 0; i < report.recommendations.length; i++) {
      final rec = report.recommendations[i];
      buffer.writeln('${i + 1}. ${rec.careerName} (${rec.matchPercentage.toInt()}% match)');
      buffer.writeln('   ${rec.description}');
    }
    Share.share(buffer.toString());
  }

  Future<void> _downloadPdf(ReportModel report) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Generating PDF...')),
    );
    try {
      final path = await PdfService.generateReportPdf(report);
      messenger.clearSnackBars();
      if (path != null) {
        Share.shareXFiles(
          [XFile(path)],
          text: 'Guidance Guru Career Report',
        );
      }
    } catch (_) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        const SnackBar(content: Text('Failed to generate PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentController>(
      builder: (context, controller, _) {
        if (controller.reportState == LoadState.loading) {
          return GlassScaffold(
            appBar: GlassAppBar(
              title: 'AI Career Report',
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingWidget(),
                  const SizedBox(height: 16),
                  Text('Generating AI Analysis...',
                      style: GoogleFonts.dmSans(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary)),
                ],
              ),
            ),
          );
        }

        final report = controller.currentReport;
        if (report == null) {
          return GlassScaffold(
            appBar: GlassAppBar(
              title: 'AI Career Report',
            ),
            body: const Center(child: Text('No report available')),
          );
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GlassScaffold(
          appBar: GlassAppBar(
            title: 'AI Career Report',
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _shareReport(report),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // Score summary
              AnimatedListItem(
                index: 0,
                child: GradientCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overall Score',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(
                            '${report.overallScore.toInt()}%',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              report.performanceBand,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 40),
                    ),
                  ],
                ),
              ),
              ),
              // AI Summary section
              if (report.aiSummary != null) ...[
                const SizedBox(height: 16),
                AnimatedListItem(
                  index: 1,
                  child: SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: isDark ? AppColors.primaryBright : AppColors.primary,
                              size: 20),
                          const SizedBox(width: 8),
                          Text('AI Summary',
                              style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(report.aiSummary!,
                          style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                              height: 1.5)),
                    ],
                  ),
                ),
                ),
              ],
              // Strengths
              if (report.strengths != null && report.strengths!.isNotEmpty) ...[
                const SizedBox(height: 16),
                AnimatedListItem(
                  index: 2,
                  child: SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                              color: isDark ? AppColors.successBright : AppColors.success,
                              size: 20),
                          const SizedBox(width: 8),
                          Text('Strengths',
                              style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...report.strengths!.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle_rounded,
                                    color: isDark ? AppColors.successBright : AppColors.success,
                                    size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(s,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary)),
                                ),
                              ],
                            ),
                          )),
                      ],
                    ),
                  ),
                ),
              ],
              // Areas for Improvement
              if (report.areasForImprovement != null &&
                  report.areasForImprovement!.isNotEmpty) ...[
                const SizedBox(height: 16),
                AnimatedListItem(
                  index: 3,
                  child: SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up_rounded,
                              color: isDark ? AppColors.warningBright : AppColors.warning,
                              size: 20),
                          const SizedBox(width: 8),
                          Text('Areas for Improvement',
                              style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...report.areasForImprovement!.map((a) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Icon(Icons.arrow_circle_up_rounded,
                                    color: isDark ? AppColors.warningBright : AppColors.warning,
                                    size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(a,
                                      style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary)),
                                ),
                              ],
                            ),
                          )),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Career Recommendations
              Text('Career Recommendations',
                  style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Based on your test results and academic profile',
                  style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)),
              const SizedBox(height: 16),
              ...List.generate(report.recommendations.length, (i) {
                final rec = report.recommendations[i];
                return AnimatedListItem(
                  index: i + 4,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _CareerCard(
                      recommendation: rec,
                      rank: i + 1,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              // Download PDF
              CustomButton(
                text: 'Download PDF Report',
                icon: Icons.download_rounded,
                onPressed: () => _downloadPdf(report),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _CareerCard extends StatefulWidget {
  final CareerRecommendation recommendation;
  final int rank;

  const _CareerCard({required this.recommendation, required this.rank});

  @override
  State<_CareerCard> createState() => _CareerCardState();
}

class _CareerCardState extends State<_CareerCard> {
  bool _expanded = false;

  Color _rankColor(bool isDark) {
    switch (widget.rank) {
      case 1:
        return isDark ? AppColors.successBright : AppColors.success;
      case 2:
        return isDark ? AppColors.primaryBright : AppColors.primary;
      default:
        return isDark ? AppColors.warningBright : AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rec = widget.recommendation;

    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.cardPadding),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _rankColor(isDark).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '#${widget.rank}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _rankColor(isDark),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rec.careerName,
                            style: GoogleFonts.sora(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${rec.matchPercentage.toInt()}% Match',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _rankColor(isDark),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: rec.matchPercentage / 100,
                                  backgroundColor:
                                      _rankColor(isDark).withValues(alpha: 0.15),
                                  valueColor: AlwaysStoppedAnimation(
                                      _rankColor(isDark)),
                                  minHeight: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.expand_more_rounded,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(rec.description,
                      style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          height: 1.5)),
                  const SizedBox(height: 16),
                  _SectionHeader(title: 'Skills Required'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: rec.skillsRequired
                        .map((s) => _SkillChip(
                            label: s,
                            color: isDark
                                ? AppColors.primaryBright
                                : AppColors.primary))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(title: 'Skills to Develop'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: rec.skillsToDevelop
                        .map((s) => _SkillChip(
                            label: s,
                            color: isDark
                                ? AppColors.warningBright
                                : AppColors.warning))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  _SectionHeader(title: 'Education Path'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school_rounded,
                            color: isDark
                                ? AppColors.primaryBright
                                : AppColors.primary,
                            size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            rec.educationPath,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            crossFadeState:
                _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SkillChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(
            alpha:
                Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
