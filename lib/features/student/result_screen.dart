import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../controllers/student_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/scale_fade_in.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    final student = context.read<StudentController>();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: student.testScore).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = context.watch<StudentController>();
    final band = Helpers.getPerformanceBand(student.testScore);
    final bandColor = Helpers.performanceBandColor(band);
    final bandIcon = Helpers.performanceBandIcon(band);

    return GlassScaffold(
      appBar: GlassAppBar(
        title: 'Test Results',
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          children: [
            // Score card
            ScaleFadeIn(
              child: GradientCard(
              child: Column(
                children: [
                  Text('Your Score',
                      style: GoogleFonts.dmSans(
                          fontSize: 14, color: Colors.white70)),
                  const SizedBox(height: 12),
                  AnimatedValueBuilder(
                    listenable: _scoreAnimation,
                    builder: (context, _) => Text(
                      '${_scoreAnimation.value.toInt()}%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 56,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Performance badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(bandIcon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          band,
                          style: GoogleFonts.sora(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ),
            const SizedBox(height: 24),
            // Category breakdown
            FadeInWidget(
              delay: const Duration(milliseconds: 800),
              child: SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category-wise Performance',
                      style: GoogleFonts.sora(
                          fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 100,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final categories = student.categoryScores;
                              if (groupIndex < categories.length) {
                                return BarTooltipItem(
                                  '${categories[groupIndex].category}\n${rod.toY.toInt()}%',
                                  GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final categories = student.categoryScores;
                                if (value.toInt() < categories.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      categories[value.toInt()].category,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) => Text(
                                '${value.toInt()}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: isDark ? AppColors.dividerDark : AppColors.divider,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          student.categoryScores.length,
                          (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: student.categoryScores[i].score,
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
                ],
              ),
            ),
            ),
            const SizedBox(height: 16),
            // Category details
            ...student.categoryScores.asMap().entries.map((entry) {
              final cat = entry.value;
              return AnimatedListItem(
                index: entry.key,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Helpers.performanceBandColor(
                                    Helpers.getPerformanceBand(cat.score))
                                .withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${cat.score.toInt()}%',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Helpers.performanceBandColor(
                                    Helpers.getPerformanceBand(cat.score)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat.category,
                                  style: GoogleFonts.sora(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                              Text(
                                '${cat.correctAnswers}/${cat.totalQuestions} correct',
                                style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            // Action buttons
            CustomButton(
              text: 'View Detailed Report',
              icon: Icons.assessment_rounded,
              onPressed: () => Navigator.pushNamed(context, '/ai-report'),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Retake Test',
              isOutlined: true,
              icon: Icons.refresh_rounded,
              onPressed: () => Navigator.pushReplacementNamed(context, '/test'),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Back to Dashboard',
              isOutlined: true,
              icon: Icons.home_rounded,
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/student-dashboard', (_) => false),
            ),
          ],
        ),
      ),
    );
  }
}

