import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/counselor_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/loading_widget.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final counselor = context.watch<CounselorController>();

    return GlassScaffold(
      appBar: GlassAppBar(
        title: 'Students',
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSizes.md, 0, AppSizes.md, AppSizes.sm),
            child: CustomTextField(
              hint: 'Search students...',
              prefixIcon: Icons.search_rounded,
              onChanged: (query) => counselor.search(query),
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Row(
              children: ['All', 'Pending', 'Reviewed', 'High Priority']
                  .map((status) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(status),
                          selected: counselor.filterStatus == status,
                          onSelected: (_) => counselor.setFilter(status),
                          selectedColor: AppColors.primary.withValues(alpha: 0.15),
                          checkmarkColor: AppColors.primary,
                          labelStyle: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: counselor.filterStatus == status
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: counselor.filterStatus == status
                                ? AppColors.primary
                                : isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Student list
          Expanded(
            child: counselor.state == CounselorLoadState.loading
                ? const LoadingWidget()
                : counselor.students.isEmpty
                    ? Center(
                        child: Text('No students found',
                            style: GoogleFonts.dmSans(
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.md),
                        itemCount: counselor.students.length,
                        separatorBuilder: (_, _a) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final student = counselor.students[index];
                          return _StudentListCard(
                            student: student,
                            onTap: () {
                              counselor
                                  .selectStudent(student['id'] as String)
                                  .then((_) {
                                if (context.mounted) {
                                  Navigator.pushNamed(
                                      context, '/student-detail');
                                }
                              });
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _StudentListCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback onTap;

  const _StudentListCard({required this.student, required this.onTap});

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return AppColors.warning;
      case 'Reviewed':
        return AppColors.success;
      case 'High Priority':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = student['status'] as String;
    final score = student['score'] as double;

    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            child: Text(
              (student['name'] as String)[0],
              style: GoogleFonts.sora(
                fontSize: 16,
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
                Text(student['name'] as String,
                    style: GoogleFonts.sora(
                        fontSize: 15, fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(student['grade'] as String,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${score.toInt()}%',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Helpers.performanceBandColor(
                      Helpers.getPerformanceBand(score)),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
