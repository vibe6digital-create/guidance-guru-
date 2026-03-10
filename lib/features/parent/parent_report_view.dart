import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../services/report_service.dart';

class ParentReportView extends StatelessWidget {
  const ParentReportView({super.key});

  void _showCounselorContactSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 32,
              backgroundColor:
                  AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              child: Text('PS',
                  style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary)),
            ),
            const SizedBox(height: 12),
            Text('Dr. Priya Sharma',
                style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text('Career Counselor',
                style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary)),
            const SizedBox(height: 20),
            _ContactInfoRow(
              icon: Icons.email_outlined,
              text: 'counselor@guidanceguru.ai',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ContactInfoRow(
              icon: Icons.phone_outlined,
              text: '+91 98765 12345',
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _ContactInfoRow(
              icon: Icons.access_time_rounded,
              text: 'Available Mon-Fri, 9 AM - 5 PM',
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final report = ReportService.getMockReport();

    return GlassScaffold(
      appBar: GlassAppBar(
        title: 'Student Report',
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          // Student info header
          SurfaceCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  child: Text('A',
                      style: GoogleFonts.sora(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Arjun Kumar',
                          style: GoogleFonts.sora(
                              fontSize: 17, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      Text('Class 12 - Science',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Helpers.performanceBandColor(report.performanceBand)
                        .withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.performanceBand,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Helpers.performanceBandColor(report.performanceBand),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Overall Score
          GradientCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall Score',
                        style: GoogleFonts.dmSans(
                            fontSize: 14, color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text('${report.overallScore.toInt()}%',
                        style: GoogleFonts.jetBrainsMono(
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Helpers.performanceBandIcon(report.performanceBand),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Category scores
          Text('Category Scores',
              style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          const SizedBox(height: 12),
          SurfaceCard(
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) {
                          final cats = report.categoryScores;
                          if (value.toInt() < cats.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(cats[value.toInt()].category,
                                  style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
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
                          width: 32,
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
          const SizedBox(height: 20),
          // Top Recommendations
          Text('Top Career Recommendations',
              style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...report.recommendations.take(3).map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SurfaceCard(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${rec.matchPercentage.toInt()}%',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
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
                                    fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text(
                              rec.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 20),
          // Counselor Remarks
          if (report.remarks.isNotEmpty) ...[
            Text('Counselor Remarks',
                style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            const SizedBox(height: 12),
            ...report.remarks.map((remark) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.psychology_rounded,
                                color: isDark ? AppColors.primaryBright : AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(remark.counselorName,
                                style: GoogleFonts.sora(
                                    fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            const Spacer(),
                            Text(Helpers.formatDate(remark.createdAt),
                                style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(remark.message,
                            style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                height: 1.4)),
                      ],
                    ),
                  ),
                )),
          ],
          const SizedBox(height: 16),
          // Contact counselor
          CustomButton(
            text: 'Contact Counselor',
            isOutlined: true,
            icon: Icons.chat_rounded,
            onPressed: () => _showCounselorContactSheet(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _ContactInfoRow({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon,
            color: isDark ? AppColors.primaryBright : AppColors.primary,
            size: 20),
        const SizedBox(width: 12),
        Text(text,
            style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary)),
      ],
    );
  }
}
