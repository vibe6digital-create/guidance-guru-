import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../core/widgets/scale_fade_in.dart';
import '../../models/user_model.dart';

/// Standalone profile page (pushed via Navigator)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: GlassAppBar(
        title: AppStrings.profile,
      ),
      body: const ProfileContent(),
    );
  }
}

/// Reusable profile body — used both as a standalone page and
/// inline inside the dashboard Profile tab.
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
      case UserRole.counselor:
        return 'Counselor';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final themeCtrl = context.watch<ThemeController>();
    final user = auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(AppSizes.md),
      children: [
        // Profile header — frosted glass card
        ScaleFadeIn(
          child: _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Hero(
                      tag: 'profile-avatar',
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isDark
                              ? AppColors.buttonGradientDark
                              : AppColors.buttonGradient,
                          boxShadow: [
                            BoxShadow(
                              color: (isDark
                                      ? AppColors.primaryBright
                                      : AppColors.primary)
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0]
                                : '?',
                            style: GoogleFonts.sora(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.accentBright
                              : AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? AppColors.buttonGradientDark
                        : AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user != null ? _roleLabel(user.role) : '',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.phone ?? '',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                if (user?.studentCode != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.badge_outlined,
                                size: 16,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Code: ${user!.studentCode}',
                              style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Settings — glass sections
        AnimatedListItem(
          index: 0,
          child: _GlassSettingsSection(
            title: 'Account',
            items: [
              _SettingItem(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                onTap: () => Navigator.pushNamed(context, '/edit-profile'),
              ),
              _SettingItem(
                icon: Icons.notifications_outlined,
                label: AppStrings.notifications,
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
              _SettingItem(
                icon: Icons.tune_rounded,
                label: 'Notification Settings',
                onTap: () =>
                    Navigator.pushNamed(context, '/notification-settings'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AnimatedListItem(
          index: 1,
          child: _GlassSettingsSection(
            title: 'Preferences',
            items: [
              _SettingItem(
                icon: Icons.dark_mode_outlined,
                label: AppStrings.darkMode,
                trailing: Builder(
                  builder: (context) {
                    final dark =
                        Theme.of(context).brightness == Brightness.dark;
                    return Switch(
                      value: themeCtrl.isDark,
                      onChanged: (_) => themeCtrl.toggleTheme(),
                      activeTrackColor:
                          dark ? AppColors.primaryBright : AppColors.primary,
                      activeThumbColor: Colors.white,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AnimatedListItem(
          index: 2,
          child: _GlassSettingsSection(
            title: 'About',
            items: [
              _SettingItem(
                icon: Icons.info_outline_rounded,
                label: '${AppStrings.appVersion}: 1.0.0',
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Logout
        FadeInWidget(
          delay: const Duration(milliseconds: 300),
          child: CustomButton(
            text: AppStrings.logout,
            isOutlined: true,
            icon: Icons.logout_rounded,
            onPressed: () async {
              final confirm = await Helpers.showConfirmDialog(
                context,
                title: AppStrings.logout,
                message: AppStrings.logoutConfirm,
                confirmText: AppStrings.logout,
              );
              if (confirm && context.mounted) {
                auth.logout();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/role-selection', (_) => false);
              }
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Frosted glass card with blur + translucent background
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSizes.cardPadding),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppSizes.glassBlurSigma,
          sigmaY: AppSizes.glassBlurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.5),
              width: AppSizes.glassBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Top glass shine
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppSizes.cardRadius)),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.15 : 0.6),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glass settings section with frosted background
class _GlassSettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingItem> items;

  const _GlassSettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.sora(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppSizes.glassBlurSigma,
              sigmaY: AppSizes.glassBlurSigma,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.5),
                  width: AppSizes.glassBorderWidth,
                ),
              ),
              child: Column(
                children: items
                    .asMap()
                    .entries
                    .map((entry) => Column(
                          children: [
                            entry.value,
                            if (entry.key < items.length - 1)
                              Divider(
                                height: 1,
                                indent: 52,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.white.withValues(alpha: 0.3),
                              ),
                          ],
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.primaryBright : AppColors.primary)
                    .withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color:
                      isDark ? AppColors.primaryBright : AppColors.primary,
                  size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
              ),
            ),
            trailing ??
                Icon(Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    size: 20),
          ],
        ),
      ),
    );
  }
}
