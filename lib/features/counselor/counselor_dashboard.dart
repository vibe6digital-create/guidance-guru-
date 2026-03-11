import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/counselor_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/animated_counter.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../controllers/student_controller.dart';
import '../../controllers/parent_controller.dart';
import '../profile/profile_screen.dart';
import 'chat_screen.dart';

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
      final auth = context.read<AuthController>();
      final isNew = auth.isNewUser;
      final cid = auth.user?.id;
      final ctrl = context.read<CounselorController>();
      ctrl.loadDashboard(counselorId: cid, isNewSignup: isNew);
      ctrl.loadStudents(counselorId: cid, isNewSignup: isNew);
      ctrl.loadSessions(counselorId: cid, isNewSignup: isNew);
      ctrl.loadProposals(counselorId: cid, isNewSignup: isNew);
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
                final cid = context.read<AuthController>().user?.id;
                await counselor.loadDashboard(counselorId: cid);
                await counselor.loadStudents(counselorId: cid);
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
                  const SizedBox(height: 12),
                  // Proposals card
                  AnimatedListItem(
                    index: 2,
                    child: SurfaceCard(
                      onTap: () => Navigator.pushNamed(context, '/counselling-proposals'),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.accentBright : AppColors.accent)
                                  .withValues(alpha: isDark ? 0.2 : 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.description_rounded,
                                color: isDark ? AppColors.accentBright : AppColors.accent, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Counselling Proposals',
                                    style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                                const SizedBox(height: 2),
                                Text(
                                  counselor.proposals.where((p) => p.status.name == 'pending').isEmpty
                                      ? 'No pending proposals'
                                      : '${counselor.proposals.where((p) => p.status.name == 'pending').length} pending proposal(s)',
                                  style: GoogleFonts.dmSans(fontSize: 13,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (counselor.proposals.where((p) => p.status.name == 'pending').isNotEmpty)
                            Container(
                              width: 24, height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${counselor.proposals.where((p) => p.status.name == 'pending').length}',
                                  style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                  // Build Your Profile card (new signup)
                  if (counselor.totalStudents == 0) ...[
                    const SizedBox(height: 20),
                    AnimatedListItem(
                      index: 2,
                      child: SurfaceCard(
                        onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                        child: Row(
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.person_add_rounded,
                                  color: isDark ? AppColors.primaryBright : AppColors.primary, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppStrings.buildYourProfile,
                                      style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                                  const SizedBox(height: 2),
                                  Text('Complete your profile to attract students',
                                      style: GoogleFonts.dmSans(fontSize: 13,
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

class _StudentsTab extends StatelessWidget {
  Color _scoreColor(double score) {
    if (score >= 85) return AppColors.success;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return AppColors.warning;
    return AppColors.error;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'High Priority':
        return AppColors.error;
      case 'Pending':
        return AppColors.warning;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counselor = context.watch<CounselorController>();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          const SizedBox(height: 8),
          AnimatedListItem(
            index: 0,
            child: Text(
              'My Students',
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
              '${counselor.totalStudents} students assigned',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (counselor.students.isEmpty)
            AnimatedListItem(
              index: 2,
              child: SurfaceCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No students found',
                    style: GoogleFonts.dmSans(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            )
          else
            ...counselor.students.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              final score = (s['score'] as num).toDouble();
              final sColor = _scoreColor(score);
              final stColor = _statusColor(s['status'] as String);

              return AnimatedListItem(
                index: 2 + i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary
                                  .withValues(alpha: isDark ? 0.2 : 0.1),
                              child: Text(
                                (s['name'] as String)[0],
                                style: GoogleFonts.sora(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.primaryBright
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['name'] as String,
                                    style: GoogleFonts.sora(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    s['grade'] as String,
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: stColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                s['status'] as String,
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: stColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Score + tests row
                        Row(
                          children: [
                            Icon(Icons.assessment_rounded,
                                size: 14, color: sColor),
                            const SizedBox(width: 4),
                            Text(
                              '${score.toInt()}%',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: sColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.quiz_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${s['testsTaken']} tests',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.family_restroom_rounded,
                                size: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                s['parentName'] as String,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Action buttons row
                        Row(
                          children: [
                            _ActionChip(
                              icon: Icons.chat_rounded,
                              label: 'Chat Student',
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary,
                              isDark: isDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CounselorChatScreen(
                                      studentName: s['name'] as String,
                                      studentId: s['id'] as String,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            _ActionChip(
                              icon: Icons.call_rounded,
                              label: 'Call Parent',
                              color: isDark
                                  ? AppColors.successBright
                                  : AppColors.success,
                              isDark: isDark,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Call ${s['parentName']} at ${s['parentPhone']}')),
                                );
                              },
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                counselor
                                    .selectStudent(s['id'] as String)
                                    .then((_) {
                                  if (context.mounted) {
                                    Navigator.pushNamed(
                                        context, '/student-detail');
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: isDark
                                      ? AppColors.buttonGradientDark
                                      : AppColors.buttonGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'View',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
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

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionsTab extends StatefulWidget {
  @override
  State<_SessionsTab> createState() => _SessionsTabState();
}

class _SessionsTabState extends State<_SessionsTab> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CounselorController>().loadSessions(
        counselorId: context.read<AuthController>().user?.id,
      );
      if (mounted) setState(() => _loading = false);
    });
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  void _showScheduleDialog() {
    final counselor = context.read<CounselorController>();
    final students = counselor.students;
    if (students.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Schedule New Session',
                style: GoogleFonts.sora(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a student to schedule a session with',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ...students.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SurfaceCard(
                      onTap: () {
                        Navigator.pop(ctx);
                        _showDateTimePicker(
                          studentId: s['id'] as String,
                          studentName: s['name'] as String,
                        );
                      },
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary
                                .withValues(alpha: isDark ? 0.2 : 0.1),
                            child: Text(
                              (s['name'] as String)[0],
                              style: GoogleFonts.sora(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.primaryBright
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s['name'] as String,
                                  style: GoogleFonts.sora(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  s['grade'] as String,
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
                          Icon(Icons.add_circle_outline_rounded,
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary),
                        ],
                      ),
                    ),
                  )),
              SizedBox(
                  height: MediaQuery.of(ctx).viewInsets.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDateTimePicker({
    required String studentId,
    required String studentName,
  }) async {
    // Pick date
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      helpText: 'Select session date',
    );
    if (date == null || !mounted) return;

    // Pick time
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
      helpText: 'Select session time',
    );
    if (time == null || !mounted) return;

    final dateTime = DateTime(
      date.year, date.month, date.day,
      time.hour, time.minute,
    );

    // Show topic input dialog
    final topicController = TextEditingController(text: 'Counselling session');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final platforms = ['Google Meet', 'Zoom', 'Teams', 'In-person', 'Call'];

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String selectedPlatform = 'Google Meet';
        bool notifyParent = false;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session with $studentName',
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}/${date.month}/${date.year} at ${time.format(ctx)}',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: topicController,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Session Topic',
                      labelStyle: GoogleFonts.dmSans(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Platform selection
                  Text(AppStrings.meetingPlatform,
                      style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: platforms.map((p) {
                      final isSelected = selectedPlatform == p;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedPlatform = p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? (isDark ? AppColors.buttonGradientDark : AppColors.buttonGradient)
                                : null,
                            color: isSelected ? null
                                : (isDark ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.grey.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(p,
                              style: GoogleFonts.dmSans(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white
                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  // Notify parent checkbox
                  GestureDetector(
                    onTap: () => setSheetState(() => notifyParent = !notifyParent),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24, height: 24,
                          child: Checkbox(
                            value: notifyParent,
                            onChanged: (v) => setSheetState(() => notifyParent = v ?? false),
                            activeColor: isDark ? AppColors.primaryBright : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('Also notify parent',
                            style: GoogleFonts.dmSans(fontSize: 14,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx, {
                          'topic': topicController.text.trim().isEmpty
                              ? 'Counselling session'
                              : topicController.text.trim(),
                          'platform': selectedPlatform,
                          'notifyParent': notifyParent,
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? AppColors.buttonGradientDark
                              : AppColors.buttonGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Confirm Session',
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result == null || !mounted) return;

    final topic = result['topic'] as String;
    final platform = result['platform'] as String;
    final notifyParent = result['notifyParent'] as bool;
    final counselorName = context.read<AuthController>().user?.name ?? 'Counselor';

    context.read<CounselorController>().scheduleSession(
          studentId: studentId,
          studentName: studentName,
          topic: topic,
          dateTime: dateTime,
          platform: platform,
          notifyParent: notifyParent,
        );

    // Format date/time string for invite
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dtStr = '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year} at ${dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
    final inviteId = 'inv_${DateTime.now().millisecondsSinceEpoch}';

    // Send invite to student
    final studentCtrl = context.read<StudentController>();
    studentCtrl.addSessionInvite({
      'id': inviteId,
      'counselorName': counselorName,
      'topic': topic,
      'dateTime': dtStr,
      'platform': platform,
      'status': 'pending',
    });

    // Optionally send invite to parent
    if (notifyParent) {
      final parentCtrl = context.read<ParentController>();
      parentCtrl.addSessionInvite({
        'id': '${inviteId}_p',
        'counselorName': counselorName,
        'topic': topic,
        'dateTime': dtStr,
        'platform': platform,
        'status': 'pending',
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session scheduled with $studentName via $platform')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counselor = context.watch<CounselorController>();

    if (_loading) {
      return const SafeArea(child: LoadingWidget());
    }

    final upcoming = counselor.sessions
        .where((s) => s['status'] == 'upcoming')
        .toList();
    final completed = counselor.sessions
        .where((s) => s['status'] == 'completed')
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          const SizedBox(height: 8),
          AnimatedListItem(
            index: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sessions',
                  style: GoogleFonts.sora(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: _showScheduleDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppColors.buttonGradientDark
                          : AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          'Schedule',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
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
          const SizedBox(height: 24),

          // Upcoming sessions
          if (upcoming.isNotEmpty) ...[
            AnimatedListItem(
              index: 1,
              child: Text(
                'Upcoming',
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
            ...upcoming.asMap().entries.map((entry) {
              final i = entry.key;
              final session = entry.value;
              final dt = session['dateTime'] as DateTime;
              return AnimatedListItem(
                index: 2 + i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${dt.day}',
                                style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.primaryBright
                                      : AppColors.primary,
                                ),
                              ),
                              Text(
                                [
                                  'Jan', 'Feb', 'Mar', 'Apr', 'May',
                                  'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
                                  'Nov', 'Dec'
                                ][dt.month - 1],
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.primaryBright
                                      : AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                session['studentName'] as String,
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                session['topic'] as String,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 12,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_formatTime(dt)} - ${session['duration']} min',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: isDark ? 0.15 : 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Upcoming',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.primaryBright
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            if (session['platform'] != null) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  session['platform'] as String,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.accentBright
                                        : AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Completed sessions
          if (completed.isNotEmpty) ...[
            AnimatedListItem(
              index: 5,
              child: Text(
                'Past Sessions',
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
            ...completed.asMap().entries.map((entry) {
              final i = entry.key;
              final session = entry.value;
              final dt = session['dateTime'] as DateTime;
              return AnimatedListItem(
                index: 6 + i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${dt.day}',
                                style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                [
                                  'Jan', 'Feb', 'Mar', 'Apr', 'May',
                                  'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
                                  'Nov', 'Dec'
                                ][dt.month - 1],
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                session['studentName'] as String,
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                session['topic'] as String,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(dt),
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success
                                .withValues(alpha: isDark ? 0.15 : 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Done',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.successBright
                                  : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],

          if (upcoming.isEmpty && completed.isEmpty)
            AnimatedListItem(
              index: 1,
              child: SurfaceCard(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_note_rounded,
                          size: 48,
                          color: (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary)
                              .withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text(
                        'No sessions scheduled',
                        style: GoogleFonts.dmSans(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap "Schedule" to create one',
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
            ),
        ],
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
