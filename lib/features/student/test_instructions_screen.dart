import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/gradient_card.dart';

class TestInstructionsScreen extends StatelessWidget {
  const TestInstructionsScreen({super.key});

  static const _instructions = [
    {
      'number': '1',
      'title': 'Time Limit',
      'description': 'You will have 30 minutes to complete the test. A timer will be visible throughout.',
      'icon': Icons.timer_rounded,
    },
    {
      'number': '2',
      'title': 'Questions',
      'description': 'The test contains 25 multiple-choice questions covering aptitude, reasoning, and interests.',
      'icon': Icons.quiz_rounded,
    },
    {
      'number': '3',
      'title': 'Navigation',
      'description': 'You can move between questions freely using Next/Previous buttons or the question navigator.',
      'icon': Icons.swap_horiz_rounded,
    },
    {
      'number': '4',
      'title': 'No Penalty',
      'description': 'There is no negative marking. Attempt all questions for the best results.',
      'icon': Icons.check_circle_outline_rounded,
    },
    {
      'number': '5',
      'title': 'Auto Submit',
      'description': 'The test will be automatically submitted when the timer runs out.',
      'icon': Icons.upload_rounded,
    },
    {
      'number': '6',
      'title': 'AI Report',
      'description': 'After submission, an AI-powered career report will be generated based on your responses.',
      'icon': Icons.auto_awesome_rounded,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      appBar: GlassAppBar(title: AppStrings.testInstructions),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                // Hero card
                AnimatedListItem(
                  index: 0,
                  child: GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_rounded,
                                color: Colors.white, size: 24),
                            const SizedBox(width: 10),
                            Text(
                              AppStrings.beforeYouBegin,
                              style: GoogleFonts.sora(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Please read the following instructions carefully before starting your career aptitude test.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Instruction cards
                ..._instructions.asMap().entries.map((entry) {
                  final i = entry.key;
                  final inst = entry.value;
                  return AnimatedListItem(
                    index: i + 1,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  inst['number'] as String,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.primaryBright
                                        : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(inst['icon'] as IconData,
                                          size: 16,
                                          color: isDark
                                              ? AppColors.primaryBright
                                              : AppColors.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        inst['title'] as String,
                                        style: GoogleFonts.sora(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    inst['description'] as String,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                      height: 1.4,
                                    ),
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
              ],
            ),
          ),
          // Bottom button
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: CustomButton(
              text: 'Start Test',
              icon: Icons.play_arrow_rounded,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/test');
              },
            ),
          ),
        ],
      ),
    );
  }
}
