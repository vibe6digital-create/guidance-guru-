import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/student_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/loading_widget.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentController>().startTest();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = context.read<StudentController>();
    if (state == AppLifecycleState.paused) {
      controller.pauseTimer();
    } else if (state == AppLifecycleState.resumed) {
      controller.resumeTimer();
    }
  }

  void _showTimeWarning() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.timer_off_rounded, color: isDark ? AppColors.warningBright : AppColors.warning),
            const SizedBox(width: 8),
            Text('Time Warning', style: GoogleFonts.sora(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          ],
        ),
        content: Text(
          'Only 5 minutes remaining! Please review and submit your answers.',
          style: GoogleFonts.dmSans(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _confirmSubmit() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Submit Test?', style: GoogleFonts.sora(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        content: Consumer<StudentController>(
          builder: (_, student, __) => Text(
            'You have answered ${student.answers.length} out of ${student.totalQuestions} questions. Are you sure you want to submit?',
            style: GoogleFonts.dmSans(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<StudentController>().submitTest(
                studentId: context.read<AuthController>().user?.id,
              ).then((_) {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/result');
                }
              });
            },
            child: Text('Submit', style: TextStyle(color: isDark ? AppColors.primaryBright : AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StudentController>(
      builder: (context, student, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        if (student.testState == LoadState.loading && student.currentTest == null) {
          return const GlassScaffold(body: LoadingWidget());
        }

        final question = student.currentQuestion;
        if (question == null) {
          return const GlassScaffold(body: LoadingWidget());
        }

        final totalSeconds = (student.currentTest?.durationMinutes ?? 45) * 60;
        final remaining = student.remainingSeconds;

        // Show warning at 5 minutes
        if (remaining == 300) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _showTimeWarning());
        }

        final selectedAnswer = student.answers[question.id];

        return GlassScaffold(
          appBar: GlassAppBar(
            title: '',
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () async {
                final confirm = await Helpers.showConfirmDialog(
                  context,
                  title: 'Exit Test?',
                  message: 'Your progress will be lost. Are you sure?',
                  confirmText: 'Exit',
                );
                if (confirm && mounted) Navigator.pop(context);
              },
            ),
            titleWidget: _TimerWidget(
              remaining: remaining,
              total: totalSeconds,
            ),
            actions: [
              TextButton(
                onPressed: _confirmSubmit,
                child: Text(
                  'Submit',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryBright : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: LinearProgressIndicator(
                  value: (student.currentQuestionIndex + 1) / student.totalQuestions,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.dividerDark
                      : AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 4,
                ),
              ),
              // Question
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & difficulty chips
                      Row(
                        children: [
                          _Chip(
                            label: question.category.substring(0, 1).toUpperCase() +
                                question.category.substring(1),
                            color: isDark ? AppColors.primaryBright : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          _Chip(
                            label: question.difficulty.substring(0, 1).toUpperCase() +
                                question.difficulty.substring(1),
                            color: question.difficulty == 'hard'
                                ? (isDark ? AppColors.errorBright : AppColors.error)
                                : question.difficulty == 'medium'
                                    ? (isDark ? AppColors.warningBright : AppColors.warning)
                                    : (isDark ? AppColors.successBright : AppColors.success),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Question text
                      Text(
                        'Q${student.currentQuestionIndex + 1}. ${question.questionText}',
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: Theme.of(context).brightness == Brightness.dark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Options
                      ...List.generate(question.options.length, (i) {
                        final option = question.options[i];
                        final isSelected = selectedAnswer == option;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _OptionCard(
                            option: option,
                            index: i,
                            isSelected: isSelected,
                            onTap: () {
                              student.selectAnswer(question.id, option);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              // Bottom navigation
              Container(
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Previous',
                        isOutlined: true,
                        onPressed: student.isFirstQuestion
                            ? null
                            : () => student.previousQuestion(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Question counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${student.currentQuestionIndex + 1}/${student.totalQuestions}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.primaryBright : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: student.isLastQuestion
                          ? CustomButton(
                              text: 'Submit',
                              onPressed: _confirmSubmit,
                            )
                          : CustomButton(
                              text: 'Next',
                              onPressed: () => student.nextQuestion(),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TimerWidget extends StatelessWidget {
  final int remaining;
  final int total;

  const _TimerWidget({required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final color = Helpers.timerColor(remaining, total);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            Helpers.formatTimer(remaining),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String option;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labels = ['A', 'B', 'C', 'D'];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isSelected ? AppColors.buttonGradient : null,
        color: isSelected ? null : isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: isSelected ? null : Border.all(color: isDark ? AppColors.dividerDark : AppColors.divider),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      labels[index],
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.dmSans(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.white, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
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
