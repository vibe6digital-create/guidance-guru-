import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/counselor_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/animated_counter.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/scale_fade_in.dart';
import '../profile/profile_screen.dart';

class CounselorDashboard extends StatefulWidget {
  const CounselorDashboard({super.key});

  @override
  State<CounselorDashboard> createState() => _CounselorDashboardState();
}

class _CounselorDashboardState extends State<CounselorDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CounselorController>().loadDashboard();
      context.read<CounselorController>().loadStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardTab(),
          _StudentsTab(),
          _SessionsTab(),
          _ProfileTab(),
        ],
      ),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded), label: 'Students'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note_rounded), label: 'Sessions'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final counselor = context.watch<CounselorController>();

    return SafeArea(
      child: counselor.state == CounselorLoadState.loading &&
              counselor.totalStudents == 0
          ? const LoadingWidget()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await counselor.loadDashboard();
                await counselor.loadStudents();
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.md),
                children: [
                  const SizedBox(height: 8),
                  // Welcome
                  AnimatedListItem(
                    index: 0,
                    child: GradientCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Helpers.greetingMessage(),
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text(
                            auth.user?.name ?? 'Counselor',
                            style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                              'Guide students towards their ideal careers',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Stats with AnimatedCounter
                  AnimatedListItem(
                    index: 1,
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Total Students',
                            value: counselor.totalStudents,
                            icon: Icons.people_rounded,
                            color: isDark
                                ? AppColors.primaryBright
                                : AppColors.primary,
                            onTap: () => Navigator.pushNamed(context, '/student-list'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Pending',
                            value: counselor.pendingReviews,
                            icon: Icons.pending_actions_rounded,
                            color: isDark
                                ? AppColors.warningBright
                                : AppColors.warning,
                            onTap: () => Navigator.pushNamed(context, '/student-list'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Completed',
                            value: counselor.completedReviews,
                            icon: Icons.check_circle_rounded,
                            color: isDark
                                ? AppColors.successBright
                                : AppColors.success,
                            onTap: () => Navigator.pushNamed(context, '/student-list'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Urgent attention
                  AnimatedListItem(
                    index: 2,
                    child: Text('Needs Attention',
                        style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary)),
                  ),
                  const SizedBox(height: 12),
                  ...counselor.students
                      .where((s) =>
                          s['status'] == 'Pending' ||
                          s['status'] == 'High Priority')
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) => AnimatedListItem(
                            index: entry.key + 3,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _UrgentStudentCard(
                                student: entry.value,
                                onTap: () {
                                  counselor
                                      .selectStudent(
                                          entry.value['id'] as String)
                                      .then((_) {
                                    if (context.mounted) {
                                      Navigator.pushNamed(
                                          context, '/student-detail');
                                    }
                                  });
                                },
                              ),
                            ),
                          )),
                  if (counselor.students
                      .where((s) =>
                          s['status'] == 'Pending' ||
                          s['status'] == 'High Priority')
                      .isEmpty)
                    AnimatedListItem(
                      index: 3,
                      child: SurfaceCard(
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 40,
                                  color: isDark
                                      ? AppColors.successBright
                                      : AppColors.success),
                              const SizedBox(height: 8),
                              Text('All caught up!',
                                  style: GoogleFonts.dmSans(
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
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
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _UrgentStudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onTap;

  const _UrgentStudentCard({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighPriority = student['status'] == 'High Priority';
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                (isHighPriority ? AppColors.error : AppColors.warning)
                    .withValues(alpha: isDark ? 0.2 : 0.1),
            child: Text(
              (student['name'] as String)[0],
              style: GoogleFonts.sora(
                fontWeight: FontWeight.w600,
                color:
                    isHighPriority ? AppColors.error : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['name'] as String,
                    style: GoogleFonts.sora(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)),
                Text(student['grade'] as String,
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  (isHighPriority ? AppColors.error : AppColors.warning)
                      .withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              student['status'] as String,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isHighPriority
                    ? AppColors.error
                    : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder tabs with empty state animations
class _StudentsTab extends StatelessWidget {
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
              child: Icon(Icons.people_rounded,
                  size: 64,
                  color: (isDark
                          ? AppColors.primaryBright
                          : AppColors.primary)
                      .withValues(alpha: isDark ? 0.7 : 0.5)),
            ),
            const SizedBox(height: 16),
            FadeInWidget(
              delay: const Duration(milliseconds: 300),
              child: Text('Student List',
                  style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary)),
            ),
            const SizedBox(height: 24),
            FadeInWidget(
              delay: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: CustomButton(
                  text: 'View All Students',
                  onPressed: () =>
                      Navigator.pushNamed(context, '/student-list'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionsTab extends StatelessWidget {
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
              child: Icon(Icons.event_note_rounded,
                  size: 64,
                  color: (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)
                      .withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 16),
            FadeInWidget(
              delay: const Duration(milliseconds: 300),
              child: Text('Sessions',
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
              child: Text('Session management coming soon',
                  style: GoogleFonts.dmSans(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary)),
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
