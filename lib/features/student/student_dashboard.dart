import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/student_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/animated_counter.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/scale_fade_in.dart';
import '../profile/profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentController>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _HomeTab(),
          _TestTab(),
          _ReportsTab(),
          _NotificationsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.quiz_rounded), label: 'Test'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment_rounded), label: 'Reports'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final student = context.watch<StudentController>();

    return SafeArea(
      child: student.dashboardState == LoadState.loading
          ? const LoadingWidget()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => student.loadDashboard(),
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  const SizedBox(height: 8),
                  // Welcome card
                  AnimatedListItem(
                    index: 0,
                    child: GradientCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Helpers.greetingMessage(),
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            auth.user?.name ?? 'Student',
                            style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 1.0, end: 1.2),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeInOut,
                                builder: (context, scale, child) {
                                  return Transform.scale(
                                      scale: scale, child: child);
                                },
                                child: const Icon(
                                    Icons.local_fire_department,
                                    color: AppColors.warning,
                                    size: 18),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${student.streak} day streak',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Progress card
                  AnimatedListItem(
                    index: 1,
                    child: SurfaceCard(
                      onTap: () => Navigator.pushNamed(context, '/academic-form'),
                      child: Row(
                        children: [
                          CircularPercentIndicator(
                            radius: 36,
                            lineWidth: 6,
                            percent: student.completionPercentage / 100,
                            center: Text(
                              '${student.completionPercentage.toInt()}%',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.primaryBright
                                    : AppColors.primary,
                              ),
                            ),
                            progressColor: AppColors.primary,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Progress',
                                  style: GoogleFonts.sora(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Complete tests to unlock AI insights',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // CTA Button
                  AnimatedListItem(
                    index: 2,
                    child: CustomButton(
                      text: AppStrings.startCareerTest,
                      icon: Icons.play_arrow_rounded,
                      onPressed: () {
                        Navigator.pushNamed(context, '/academic-form');
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats Row
                  AnimatedListItem(
                    index: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: AppStrings.testsTaken,
                            value: student.testsTaken,
                            icon: Icons.quiz_rounded,
                            color: isDark
                                ? AppColors.primaryBright
                                : AppColors.primary,
                            onTap: () => Navigator.pushNamed(context, '/result'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: AppStrings.reports,
                            value: student.reportsGenerated,
                            icon: Icons.assessment_rounded,
                            color: isDark
                                ? AppColors.successBright
                                : AppColors.success,
                            onTap: () => Navigator.pushNamed(context, '/ai-report'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SurfaceCard(
                            onTap: () => Navigator.pushNamed(context, '/ai-report'),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                Icon(Icons.star_rounded,
                                    color: isDark
                                        ? AppColors.warningBright
                                        : AppColors.warning,
                                    size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  'Good',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.warningBright
                                        : AppColors.warning,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.scoreBand,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Recent Activity
                  AnimatedListItem(
                    index: 4,
                    child: Text(
                      AppStrings.recentActivity,
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...student.recentActivity.asMap().entries.map((entry) {
                    final i = entry.key;
                    final activity = entry.value;
                    return AnimatedListItem(
                      index: 5 + i,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SurfaceCard(
                          onTap: () => Navigator.pushNamed(
                            context,
                            _activityRoute(activity['icon'] as String),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                      alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _activityIcon(
                                      activity['icon'] as String),
                                  color: isDark
                                      ? AppColors.primaryBright
                                      : AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity['title'] as String,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      activity['time'] as String,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  String _activityRoute(String type) {
    switch (type) {
      case 'test':
        return '/result';
      case 'report':
        return '/ai-report';
      case 'academic':
        return '/academic-form';
      case 'remark':
        return '/ai-report';
      default:
        return '/student-dashboard';
    }
  }

  IconData _activityIcon(String type) {
    switch (type) {
      case 'test':
        return Icons.quiz_rounded;
      case 'report':
        return Icons.assessment_rounded;
      case 'academic':
        return Icons.school_rounded;
      case 'remark':
        return Icons.comment_rounded;
      default:
        return Icons.circle;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          AnimatedCounter(
            targetValue: value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Placeholder tabs with empty state animations
class _TestTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleFadeIn(
              delay: const Duration(milliseconds: 100),
              child: Icon(Icons.quiz_rounded,
                  size: 64,
                  color: (isDark
                          ? AppColors.primaryBright
                          : AppColors.primary)
                      .withValues(alpha: isDark ? 0.7 : 0.5)),
            ),
            const SizedBox(height: 16),
            FadeInWidget(
              delay: const Duration(milliseconds: 300),
              child: Text('Career Test',
                  style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
            ),
            const SizedBox(height: 8),
            FadeInWidget(
              delay: const Duration(milliseconds: 400),
              child: Text('Take a test to discover your career path',
                  style: GoogleFonts.dmSans(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)),
            ),
            const SizedBox(height: 24),
            FadeInWidget(
              delay: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: CustomButton(
                  text: 'Start Test',
                  onPressed: () => Navigator.pushNamed(context, '/test'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleFadeIn(
              delay: const Duration(milliseconds: 100),
              child: Icon(Icons.assessment_rounded,
                  size: 64,
                  color: (isDark
                          ? AppColors.primaryBright
                          : AppColors.primary)
                      .withValues(alpha: isDark ? 0.7 : 0.5)),
            ),
            const SizedBox(height: 16),
            FadeInWidget(
              delay: const Duration(milliseconds: 300),
              child: Text('Reports',
                  style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
            ),
            const SizedBox(height: 8),
            FadeInWidget(
              delay: const Duration(milliseconds: 400),
              child: Text(
                  'Your AI-generated career reports will appear here',
                  style: GoogleFonts.dmSans(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)),
            ),
            const SizedBox(height: 24),
            FadeInWidget(
              delay: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: CustomButton(
                  text: 'View Sample Report',
                  onPressed: () =>
                      Navigator.pushNamed(context, '/ai-report'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            FadeInWidget(
              child: Text('Notifications',
                  style: GoogleFonts.sora(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleFadeIn(
                      delay: const Duration(milliseconds: 100),
                      child: Icon(Icons.notifications_none_rounded,
                          size: 64,
                          color: (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary)
                              .withValues(alpha: 0.4)),
                    ),
                    const SizedBox(height: 16),
                    FadeInWidget(
                      delay: const Duration(milliseconds: 300),
                      child: Text('No notifications yet',
                          style: GoogleFonts.dmSans(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: ProfileContent());
  }
}
