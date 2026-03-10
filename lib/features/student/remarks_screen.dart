import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/student_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../models/report_model.dart';
import '../../services/report_service.dart';

class RemarksScreen extends StatelessWidget {
  const RemarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<StudentController>();
    final report = controller.currentReport ?? ReportService.getMockReport();
    final remarks = report.remarks;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: 'Counselor Remarks',
      ),
      body: remarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.comment_outlined,
                      size: 64,
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No remarks yet',
                      style: GoogleFonts.dmSans(
                          fontSize: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.md),
              itemCount: remarks.length,
              itemBuilder: (context, index) {
                return _RemarkTimelineItem(
                  remark: remarks[index],
                  isFirst: index == 0,
                  isLast: index == remarks.length - 1,
                );
              },
            ),
    );
  }
}

class _RemarkTimelineItem extends StatelessWidget {
  final CounselorRemark remark;
  final bool isFirst;
  final bool isLast;

  const _RemarkTimelineItem({
    required this.remark,
    required this.isFirst,
    required this.isLast,
  });

  Color _typeColor(bool isDark) {
    switch (remark.type) {
      case RemarkType.general:
        return isDark ? AppColors.primaryBright : AppColors.primary;
      case RemarkType.academic:
        return isDark ? AppColors.successBright : AppColors.success;
      case RemarkType.career:
        return AppColors.primary;
      case RemarkType.urgent:
        return isDark ? AppColors.errorBright : AppColors.error;
    }
  }

  IconData get _typeIcon {
    switch (remark.type) {
      case RemarkType.general:
        return Icons.chat_bubble_outline_rounded;
      case RemarkType.academic:
        return Icons.school_rounded;
      case RemarkType.career:
        return Icons.work_outline_rounded;
      case RemarkType.urgent:
        return Icons.priority_high_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (!isFirst)
                  Container(width: 2, height: 16, color: isDark ? AppColors.dividerDark : AppColors.divider),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _typeColor(isDark),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: isDark ? AppColors.dividerDark : AppColors.divider),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _typeColor(isDark).withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_typeIcon, color: _typeColor(isDark), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                remark.counselorName,
                                style: GoogleFonts.sora(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                Helpers.formatDate(remark.createdAt),
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _typeColor(isDark).withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            remark.type.name.substring(0, 1).toUpperCase() +
                                remark.type.name.substring(1),
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _typeColor(isDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      remark.message,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    if (remark.actionItems.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Action Items',
                          style: GoogleFonts.sora(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      ...remark.actionItems.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 16, color: _typeColor(isDark)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
