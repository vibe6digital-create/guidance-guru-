import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Test Reminder',
      'message': 'You have a pending career assessment test. Take it now!',
      'type': 'test_reminder',
      'isRead': false,
      'createdAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'title': 'New Counselor Remark',
      'message': 'Dr. Priya Sharma has added a new remark on your report.',
      'type': 'new_remark',
      'isRead': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '3',
      'title': 'Report Ready',
      'message': 'Your AI career report has been generated. View it now!',
      'type': 'report_ready',
      'isRead': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'id': '4',
      'title': 'Parent Linked',
      'message': 'Rajesh Kumar has been linked to your account as a parent.',
      'type': 'parent_linked',
      'isRead': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  void _markAllRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  void _clearAll() {
    setState(() => _notifications.clear());
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'test_reminder':
        return Icons.quiz_rounded;
      case 'new_remark':
        return Icons.comment_rounded;
      case 'report_ready':
        return Icons.assessment_rounded;
      case 'parent_linked':
        return Icons.link_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String type, {bool isDark = false}) {
    switch (type) {
      case 'test_reminder':
        return isDark ? AppColors.warningBright : AppColors.warning;
      case 'new_remark':
        return isDark ? AppColors.primaryBright : AppColors.primary;
      case 'report_ready':
        return isDark ? AppColors.successBright : AppColors.success;
      case 'parent_linked':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unreadCount =
        _notifications.where((n) => !(n['isRead'] as bool)).length;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: AppStrings.notifications,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () =>
                Navigator.pushNamed(context, '/notification-settings'),
          ),
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'read') _markAllRead();
                if (value == 'clear') _clearAll();
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'read',
                  child: Row(
                    children: [
                      Icon(Icons.done_all_rounded, size: 18,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                      const SizedBox(width: 8),
                      Text(AppStrings.markAllRead,
                          style: GoogleFonts.dmSans(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all_rounded, size: 18,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                      const SizedBox(width: 8),
                      Text(AppStrings.clearAll,
                          style: GoogleFonts.dmSans(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64,
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No notifications',
                      style: GoogleFonts.dmSans(
                          fontSize: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (unreadCount > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSizes.md, AppSizes.sm, AppSizes.md, 0),
                    child: Text(
                      '$unreadCount unread',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, _a) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final notif = _notifications[index];
                      final isRead = notif['isRead'] as bool;
                      final type = notif['type'] as String;

                      return SurfaceCard(
                        onTap: () {
                          setState(() => notif['isRead'] = true);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    _typeColor(type, isDark: isDark).withValues(alpha: isDark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_typeIcon(type),
                                  color: _typeColor(type, isDark: isDark), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notif['title'] as String,
                                          style: GoogleFonts.sora(
                                            fontSize: 14,
                                            fontWeight: isRead
                                                ? FontWeight.w500
                                                : FontWeight.w600,
                                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (!isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notif['message'] as String,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    Helpers.timeAgo(
                                        notif['createdAt'] as DateTime),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
