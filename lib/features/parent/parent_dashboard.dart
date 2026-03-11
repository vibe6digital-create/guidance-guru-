import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/parent_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/scale_fade_in.dart';
import '../profile/profile_screen.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final isNew = auth.isNewUser;
      context.read<ParentController>().loadDashboard(
        parentId: auth.user?.id,
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
          _DashboardTab(),
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
              icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
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

class _DashboardTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final parent = context.watch<ParentController>();

    return SafeArea(
      child: parent.state == ParentLoadState.loading
          ? const LoadingWidget()
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => parent.loadDashboard(parentId: auth.user?.id),
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
                            auth.user?.name ?? 'Parent',
                            style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Monitor your child\'s career journey',
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Linked students
                  AnimatedListItem(
                    index: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Linked Students',
                            style: GoogleFonts.sora(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary)),
                        TextButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/link-student'),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text('Link New',
                              style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (parent.linkedStudents.isEmpty)
                    AnimatedListItem(
                      index: 2,
                      child: SurfaceCard(
                        child: Column(
                          children: [
                            ScaleFadeIn(
                              child: Icon(Icons.person_add_rounded,
                                  size: 48,
                                  color: (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary)
                                      .withValues(alpha: 0.4)),
                            ),
                            const SizedBox(height: 12),
                            Text('No students linked yet',
                                style: GoogleFonts.dmSans(
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary)),
                            const SizedBox(height: 12),
                            CustomButton(
                              text: 'Link Student',
                              icon: Icons.add_rounded,
                              width: 180,
                              height: 44,
                              onPressed: () => Navigator.pushNamed(
                                  context, '/link-student'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...parent.linkedStudents.asMap().entries.map((entry) =>
                        AnimatedListItem(
                          index: entry.key + 2,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StudentCard(student: entry.value),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;

  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SurfaceCard(
      onTap: () => Navigator.pushNamed(context, '/parent-report'),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                child: Text(
                  (student['name'] as String).isNotEmpty
                      ? (student['name'] as String)[0]
                      : '?',
                  style: GoogleFonts.sora(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name'] as String,
                      style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                    ),
                    Text(
                      student['grade'] as String,
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Helpers.performanceBandColor(
                          student['performanceBand'] as String)
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  student['performanceBand'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Helpers.performanceBandColor(
                        student['performanceBand'] as String),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _InfoChip(
                icon: Icons.quiz_rounded,
                label: '${student['testsTaken']} Tests',
              ),
              _InfoChip(
                icon: Icons.person_rounded,
                label: student['counselorName'] as String,
              ),
              Icon(Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ReportsTab extends StatelessWidget {
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _remarkTypeLabel(dynamic type) {
    switch (type.toString()) {
      case 'RemarkType.academic':
        return 'Academic';
      case 'RemarkType.career':
        return 'Career';
      case 'RemarkType.urgent':
        return 'Urgent';
      default:
        return 'General';
    }
  }

  Color _remarkTypeColor(dynamic type) {
    switch (type.toString()) {
      case 'RemarkType.academic':
        return Colors.blue;
      case 'RemarkType.career':
        return AppColors.success;
      case 'RemarkType.urgent':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parent = context.watch<ParentController>();
    final student = parent.linkedStudents.isNotEmpty
        ? parent.linkedStudents.first
        : null;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          const SizedBox(height: 8),
          AnimatedListItem(
            index: 0,
            child: Text(
              'Student Overview',
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

          // Counsellor Contact Card
          if (student != null) ...[
            AnimatedListItem(
              index: 1,
              child: Text(
                'Counsellor',
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
              index: 2,
              child: SurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary
                            .withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.psychology_rounded,
                          color: isDark
                              ? AppColors.primaryBright
                              : AppColors.primary,
                          size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student['counselorName'] as String,
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            student['counselorPhone'] as String? ?? '',
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
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Call ${student['counselorName']} at ${student['counselorPhone']}',
                            ),
                          ),
                        );
                      },
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
                            const Icon(Icons.call_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Talk',
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
            ),
            const SizedBox(height: 24),
          ],

          // Counsellor Remarks
          AnimatedListItem(
            index: 3,
            child: Text(
              'Counsellor Remarks',
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
          if (parent.studentRemarks.isEmpty)
            AnimatedListItem(
              index: 4,
              child: SurfaceCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No remarks yet',
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
            ...parent.studentRemarks.asMap().entries.map((entry) {
              final i = entry.key;
              final remark = entry.value;
              final typeColor = _remarkTypeColor(remark.type);

              return AnimatedListItem(
                index: 4 + i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.comment_rounded,
                                size: 16,
                                color: isDark
                                    ? AppColors.primaryBright
                                    : AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                remark.counselorName,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.primaryBright
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: typeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _remarkTypeLabel(remark.type),
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: typeColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          remark.message,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        if (remark.actionItems.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...remark.actionItems.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded,
                                        size: 14,
                                        color: isDark
                                            ? AppColors.successBright
                                            : AppColors.success),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          _formatDate(remark.createdAt),
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
                ),
              );
            }),

          const SizedBox(height: 24),

          // Student Test History
          AnimatedListItem(
            index: 7,
            child: Text(
              'Tests Completed',
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
          if (parent.studentTestHistory.isEmpty)
            AnimatedListItem(
              index: 8,
              child: SurfaceCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No tests completed yet',
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
            ...parent.studentTestHistory.asMap().entries.map((entry) {
              final i = entry.key;
              final test = entry.value;
              final score = test.score ?? 0;
              final color = _bandColor(score);
              final band = _bandLabel(score);

              return AnimatedListItem(
                index: 8 + i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SurfaceCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.quiz_rounded,
                              color: color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.title,
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
                                test.description,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                test.completedAt != null
                                    ? _formatDate(test.completedAt!)
                                    : '',
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
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${score.toInt()}%\n$band',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color,
                              height: 1.3,
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
      ),
    );
  }
}

class _NotificationsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parent = context.watch<ParentController>();
    final invites = parent.sessionInvites;

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
                                        onTap: () => parent.respondToSessionInvite(invite['id'] as String, true),
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
                                        onTap: () => parent.respondToSessionInvite(invite['id'] as String, false),
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
