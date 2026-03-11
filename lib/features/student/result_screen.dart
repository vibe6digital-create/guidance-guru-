import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/student_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/helpers.dart';
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
                  ...student.categoryScores.map((cat) {
                    final catColor = Helpers.performanceBandColor(
                        Helpers.getPerformanceBand(cat.score));
                    final catBand = Helpers.getPerformanceBand(cat.score);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                cat.category,
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${cat.score.toInt()}%',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: catColor,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: catColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      catBand,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: catColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: cat.score / 100,
                              backgroundColor:
                                  catColor.withValues(alpha: 0.1),
                              valueColor:
                                  AlwaysStoppedAnimation(catColor),
                              minHeight: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${cat.correctAnswers} of ${cat.totalQuestions} questions correct',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            ),
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

