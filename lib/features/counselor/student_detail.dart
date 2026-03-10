import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../controllers/counselor_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/loading_widget.dart';

class StudentDetailScreen extends StatelessWidget {
  const StudentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counselor = context.watch<CounselorController>();
    final student = counselor.selectedStudent;
    final report = counselor.selectedStudentReport;

    if (student == null) {
      return const GlassScaffold(body: LoadingWidget());
    }

    return GlassScaffold(
      appBar: GlassAppBar(
        title: student['name'] as String,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add-remark'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: Text('Add Remark',
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Student profile header
          SurfaceCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  child: Text(
                    (student['name'] as String)[0],
                    style: GoogleFonts.sora(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student['name'] as String,
                          style: GoogleFonts.sora(
                              fontSize: 18, fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      Text(student['grade'] as String,
                          style: GoogleFonts.dmSans(
                              fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Helpers.performanceBandColor(
                                      Helpers.getPerformanceBand(
                                          student['score'] as double))
                                  .withValues(alpha: isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(student['score'] as double).toInt()}% - ${Helpers.getPerformanceBand(student['score'] as double)}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Helpers.performanceBandColor(
                                    Helpers.getPerformanceBand(
                                        student['score'] as double)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${student['testsTaken']} tests',
                            style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Performance graph
          if (report != null) ...[
            Text('Category Performance',
                style: GoogleFonts.sora(
                    fontSize: 18, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 12),
            SurfaceCard(
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
                            if (value.toInt() <
                                report.categoryScores.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  report.categoryScores[value.toInt()].category,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      report.categoryScores.length,
                      (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: report.categoryScores[i].score,
                            gradient: isDark ? AppColors.buttonGradientDark : AppColors.buttonGradient,
                            width: 28,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // AI Report summary
            Text('AI Report Summary',
                style: GoogleFonts.sora(
                    fontSize: 18, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...report.recommendations.take(3).map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '${rec.matchPercentage.toInt()}%',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rec.careerName,
                                  style: GoogleFonts.sora(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                              Text(
                                rec.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 16),
          // Previous remarks
          if (report != null && report.remarks.isNotEmpty) ...[
            Text('Previous Remarks',
                style: GoogleFonts.sora(
                    fontSize: 18, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...report.remarks.map((remark) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.comment_rounded,
                                size: 16, color: isDark ? AppColors.primaryBright : AppColors.primary),
                            const SizedBox(width: 6),
                            Text(Helpers.formatDate(remark.createdAt),
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(remark.message,
                            style: GoogleFonts.dmSans(
                                fontSize: 14, height: 1.4,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      ],
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }
}
