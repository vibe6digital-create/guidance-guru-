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
import 'chat_counselor_screen.dart';

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
      final auth = context.read<AuthController>();
      final isNew = auth.isNewUser;
      context.read<StudentController>().loadDashboard(
        studentId: auth.user?.id,
        isNewSignup: isNew,
      );
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
              onRefresh: () => student.loadDashboard(
                studentId: context.read<AuthController>().user?.id,
              ),
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
                            onTap: () => Navigator.pushNamed(context, '/test-history'),
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
                            onTap: () => Navigator.pushNamed(context, '/reports-list'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SurfaceCard(
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
                                  student.averageScoreBand,
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
                  // Your Connections
                  if (auth.user?.counselorName != null ||
                      auth.user?.parentName != null) ...[
                    AnimatedListItem(
                      index: 4,
                      child: Text(
                        AppStrings.yourConnections,
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
                    if (auth.user?.counselorName != null)
                      AnimatedListItem(
                        index: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SurfaceCard(
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
                                    Icons.psychology_rounded,
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
                                        AppStrings.counsellor,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        auth.user!.counselorName!,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      if (auth.user!.counselorPhone != null)
                                        Text(
                                          auth.user!.counselorPhone!,
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
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatCounselorScreen(
                                          counselorName: auth.user!.counselorName!,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: isDark
                                          ? AppColors.buttonGradientDark
                                          : AppColors.buttonGradient,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.chat_rounded,
                                            color: Colors.white, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Chat',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (auth.user?.parentName != null)
                      AnimatedListItem(
                        index: 6,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SurfaceCard(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(
                                        alpha: isDark ? 0.2 : 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.family_restroom_rounded,
                                    color: isDark
                                        ? AppColors.successBright
                                        : AppColors.success,
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
                                        AppStrings.parentGuardian,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        auth.user!.parentName!,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                      if (auth.user!.parentPhone != null)
                                        Text(
                                          auth.user!.parentPhone!,
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                  // Encouragement Section (for new signups)
                  if (student.recentActivity.isEmpty) ...[
                    AnimatedListItem(
                      index: 7,
                      child: Text(
                        'Start Your Journey',
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
                    AnimatedListItem(
                      index: 8,
                      child: SurfaceCard(
                        onTap: () => Navigator.pushNamed(context, '/academic-form'),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.rocket_launch_rounded,
                                  color: isDark ? AppColors.primaryBright : AppColors.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Start Your Journey',
                                      style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                                  Text('Fill in your academic details to begin',
                                      style: GoogleFonts.dmSans(fontSize: 12,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedListItem(
                      index: 9,
                      child: SurfaceCard(
                        onTap: () => Navigator.pushNamed(context, '/academic-form'),
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.quiz_rounded,
                                  color: isDark ? AppColors.successBright : AppColors.success, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Take Your First Test',
                                      style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                                  Text('Discover your career aptitude',
                                      style: GoogleFonts.dmSans(fontSize: 12,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedListItem(
                      index: 10,
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.assessment_rounded,
                                  color: isDark ? AppColors.warningBright : AppColors.warning, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Get AI Report',
                                      style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                                  Text('Personalised career guidance powered by AI',
                                      style: GoogleFonts.dmSans(fontSize: 12,
                                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ],
                  // Recent Activity
                  if (student.recentActivity.isNotEmpty) ...[
                  AnimatedListItem(
                    index: 7,
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
                    final subtitle = activity['subtitle'] as String?;
                    final counselorName = activity['counselorName'] as String?;
                    final isRemark = activity['icon'] == 'remark';
                    return AnimatedListItem(
                      index: 8 + i,
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
                                    if (isRemark && counselorName != null)
                                      Text(
                                        counselorName,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? AppColors.primaryBright
                                              : AppColors.primary,
                                        ),
                                      ),
                                    if (subtitle != null)
                                      Text(
                                        subtitle,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
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
        return '/remarks';
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

class _TestTab extends StatefulWidget {
  @override
  State<_TestTab> createState() => _TestTabState();
}

class _TestTabState extends State<_TestTab> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthController>();
      final isNew = auth.isNewUser;
      await context.read<StudentController>().loadTestHistory(
        studentId: auth.user?.id,
        isNewSignup: isNew,
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

    if (_loading) {
      return const SafeArea(child: LoadingWidget());
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          const SizedBox(height: 8),
          // Title
          AnimatedListItem(
            index: 0,
            child: Text(
              'Career Tests',
              style: GoogleFonts.sora(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Recommended Tests section
          AnimatedListItem(
            index: 1,
            child: Text(
              'Recommended for You',
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
          ...student.recommendedTests.asMap().entries.map((entry) {
            final i = entry.key;
            final rec = entry.value;
            return AnimatedListItem(
              index: 2 + i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SurfaceCard(
                  onTap: () => Navigator.pushNamed(context, '/test'),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary
                              .withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.play_arrow_rounded,
                            color: isDark
                                ? AppColors.primaryBright
                                : AppColors.primary,
                            size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec['title'] as String,
                              style: GoogleFonts.sora(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              rec['description'] as String,
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.timer_rounded,
                                    size: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                                const SizedBox(width: 3),
                                Text(
                                  '${rec['duration']} min',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(Icons.help_outline_rounded,
                                    size: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary),
                                const SizedBox(width: 3),
                                Text(
                                  '${rec['questions']} Qs',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (rec['difficulty'] == 'Hard'
                                            ? AppColors.error
                                            : rec['difficulty'] == 'Medium'
                                                ? AppColors.warning
                                                : AppColors.success)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    rec['difficulty'] as String,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: rec['difficulty'] == 'Hard'
                                          ? AppColors.error
                                          : rec['difficulty'] == 'Medium'
                                              ? AppColors.warning
                                              : AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
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

          const SizedBox(height: 24),

          // Test History section
          AnimatedListItem(
            index: 5,
            child: Text(
              AppStrings.testHistory,
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
          if (student.testHistory.isEmpty)
            AnimatedListItem(
              index: 6,
              child: SurfaceCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.quiz_outlined,
                          size: 40,
                          color: (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary)
                              .withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      Text(
                        'No tests taken yet',
                        style: GoogleFonts.dmSans(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...student.testHistory.asMap().entries.map((entry) {
              final i = entry.key;
              final test = entry.value;
              final score = test.score ?? 0;
              final color = _bandColor(score);
              final band = _bandLabel(score);

              return AnimatedListItem(
                index: 6 + i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                test.title,
                                style: GoogleFonts.sora(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${score.toInt()}% - $band',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          test.description,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(test.completedAt),
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.timer_rounded,
                                size: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${test.durationMinutes} min',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/test'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: isDark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.replay_rounded,
                                        size: 13,
                                        color: isDark
                                            ? AppColors.primaryBright
                                            : AppColors.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Retake',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.primaryBright
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _ReportsTab extends StatefulWidget {
  @override
  State<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<_ReportsTab> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthController>();
      final isNew = auth.isNewUser;
      await context.read<StudentController>().loadReportsList(
        studentId: auth.user?.id,
        isNewSignup: isNew,
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

    if (_loading) {
      return const SafeArea(child: LoadingWidget());
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          const SizedBox(height: 8),
          AnimatedListItem(
            index: 0,
            child: Text(
              'Reports',
              style: GoogleFonts.sora(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedListItem(
            index: 1,
            child: Text(
              'Tap a report to view full details',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (student.reportsList.isEmpty)
            AnimatedListItem(
              index: 2,
              child: SurfaceCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.assessment_outlined,
                          size: 40,
                          color: (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary)
                              .withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      Text(
                        'No reports generated yet',
                        style: GoogleFonts.dmSans(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete a test to get your AI career report',
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
              ),
            )
          else
            ...student.reportsList.asMap().entries.map((entry) {
              final i = entry.key;
              final report = entry.value;
              final bandColor = _bandColor(report.performanceBand);

              return AnimatedListItem(
                index: 2 + i,
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Report #${i + 1}',
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
                        if (report.remarks.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                      report.remarks.first.counselorName,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.primaryBright
                                            : AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      report.remarks.first.message.length >
                                              80
                                          ? '${report.remarks.first.message.substring(0, 80)}...'
                                          : report.remarks.first.message,
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
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
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
            }),
        ],
      ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final student = context.watch<StudentController>();
    final invites = student.sessionInvites;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            FadeInWidget(
              child: Text('Alerts',
                  style: GoogleFonts.sora(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
            ),
            const SizedBox(height: 16),
            if (invites.isEmpty)
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
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: invites.length,
                  itemBuilder: (context, index) {
                    final invite = invites[index];
                    final status = invite['status'] as String? ?? 'pending';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AnimatedListItem(
                        index: index,
                        child: SurfaceCard(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.event_rounded,
                                        color: isDark ? AppColors.primaryBright : AppColors.primary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(AppStrings.sessionInvite,
                                            style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600,
                                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                                        Text(invite['counselorName'] as String? ?? '',
                                            style: GoogleFonts.dmSans(fontSize: 12,
                                                color: isDark ? AppColors.primaryBright : AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                  if (invite['platform'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.accent.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(invite['platform'] as String,
                                          style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600,
                                              color: isDark ? AppColors.accentBright : AppColors.accent)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(invite['topic'] as String? ?? 'Counselling session',
                                  style: GoogleFonts.dmSans(fontSize: 13,
                                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text(invite['dateTime'] as String? ?? '',
                                  style: GoogleFonts.dmSans(fontSize: 12,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                              if (status == 'pending') ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => student.respondToSessionInvite(invite['id'] as String, true),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            gradient: isDark ? AppColors.buttonGradientDark : AppColors.buttonGradient,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Center(child: Text(AppStrings.accept,
                                              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => student.respondToSessionInvite(invite['id'] as String, false),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                            ),
                                          ),
                                          child: Center(child: Text(AppStrings.decline,
                                              style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600,
                                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary))),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (status == 'accepted' ? AppColors.success : AppColors.error)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status == 'accepted' ? 'Accepted' : 'Declined',
                                      style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600,
                                          color: status == 'accepted' ? AppColors.success : AppColors.error),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
