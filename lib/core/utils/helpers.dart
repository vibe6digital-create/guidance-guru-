import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';

class Helpers {
  Helpers._();

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatTime(Duration duration) {
    final minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static String formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static Color timerColor(int secondsRemaining, int totalSeconds) {
    final ratio = secondsRemaining / totalSeconds;
    if (ratio > 0.5) return AppColors.success;
    if (ratio > 0.2) return AppColors.warning;
    return AppColors.error;
  }

  static String getPerformanceBand(double percentage) {
    if (percentage >= 85) return 'Excellent';
    if (percentage >= 70) return 'Good';
    if (percentage >= 50) return 'Average';
    return 'Below Average';
  }

  static Color performanceBandColor(String band) {
    switch (band) {
      case 'Excellent':
        return AppColors.success;
      case 'Good':
        return AppColors.primary;
      case 'Average':
        return AppColors.warning;
      default:
        return AppColors.error;
    }
  }

  static IconData performanceBandIcon(String band) {
    switch (band) {
      case 'Excellent':
        return Icons.emoji_events;
      case 'Good':
        return Icons.thumb_up;
      case 'Average':
        return Icons.trending_flat;
      default:
        return Icons.trending_down;
    }
  }

  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final color = isError ? AppColors.error : AppColors.success;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: Text(title,
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              )),
          content: Text(message,
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              )),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmText,
                  style: const TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  static String greetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return DateFormat('dd MMM').format(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
