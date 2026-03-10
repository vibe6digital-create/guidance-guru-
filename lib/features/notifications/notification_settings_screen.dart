import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _testReminders = true;
  bool _reportReady = true;
  bool _counselorRemarks = true;
  bool _parentUpdates = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _testReminders = prefs.getBool('notif_test_reminders') ?? true;
      _reportReady = prefs.getBool('notif_report_ready') ?? true;
      _counselorRemarks = prefs.getBool('notif_counselor_remarks') ?? true;
      _parentUpdates = prefs.getBool('notif_parent_updates') ?? true;
      _loaded = true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: 'Notification Settings',
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSizes.md),
              children: [
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications_active_outlined,
                              color: isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary,
                              size: 22),
                          const SizedBox(width: 10),
                          Text('Push Notifications',
                              style: GoogleFonts.sora(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose which notifications you want to receive',
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
                const SizedBox(height: 16),
                SurfaceCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _NotifToggle(
                        icon: Icons.quiz_rounded,
                        color: isDark
                            ? AppColors.warningBright
                            : AppColors.warning,
                        label: 'Test Reminders',
                        description:
                            'Get reminded about pending career tests',
                        value: _testReminders,
                        onChanged: (v) {
                          setState(() => _testReminders = v);
                          _saveSetting('notif_test_reminders', v);
                        },
                      ),
                      Divider(
                          height: 1,
                          indent: 52,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : null),
                      _NotifToggle(
                        icon: Icons.assessment_rounded,
                        color: isDark
                            ? AppColors.successBright
                            : AppColors.success,
                        label: 'Report Ready',
                        description:
                            'Notified when your AI report is generated',
                        value: _reportReady,
                        onChanged: (v) {
                          setState(() => _reportReady = v);
                          _saveSetting('notif_report_ready', v);
                        },
                      ),
                      Divider(
                          height: 1,
                          indent: 52,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : null),
                      _NotifToggle(
                        icon: Icons.comment_rounded,
                        color: isDark
                            ? AppColors.primaryBright
                            : AppColors.primary,
                        label: 'Counselor Remarks',
                        description:
                            'Get notified about new counselor feedback',
                        value: _counselorRemarks,
                        onChanged: (v) {
                          setState(() => _counselorRemarks = v);
                          _saveSetting('notif_counselor_remarks', v);
                        },
                      ),
                      Divider(
                          height: 1,
                          indent: 52,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : null),
                      _NotifToggle(
                        icon: Icons.family_restroom_rounded,
                        color: AppColors.primary,
                        label: 'Parent Updates',
                        description:
                            'Updates when a parent links to your account',
                        value: _parentUpdates,
                        onChanged: (v) {
                          setState(() => _parentUpdates = v);
                          _saveSetting('notif_parent_updates', v);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    required this.icon,
    required this.color,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)),
                Text(description,
                    style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
            activeThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
