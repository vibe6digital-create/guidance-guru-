import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/parent_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
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
      context.read<ParentController>().loadDashboard();
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
              onRefresh: () => parent.loadDashboard(),
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

// Placeholder tabs with empty state animations
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
              child: Text('Student Reports',
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
              child: Text('Select a linked student to view their reports',
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

class _NotificationsTab extends StatelessWidget {
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
    );
  }
}

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: ProfileContent());
  }
}
