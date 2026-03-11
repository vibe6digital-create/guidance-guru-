import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/parent_controller.dart';
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
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';
import '../student/chat_counselor_screen.dart';

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

  void _pickProfileImage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Change Profile Photo',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded,
                    color: isDark ? AppColors.primaryBright : AppColors.primary),
                title: Text('Take Photo',
                    style: GoogleFonts.dmSans(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded,
                    color: isDark ? AppColors.primaryBright : AppColors.primary),
                title: Text('Choose from Gallery',
                    style: GoogleFonts.dmSans(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
              if (context.read<AuthController>().user?.profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error),
                  title: Text('Remove Photo',
                      style: GoogleFonts.dmSans(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    final auth = context.read<AuthController>();
                    final user = auth.user;
                    if (user != null) {
                      auth.updateUser(UserModel(
                        id: user.id,
                        name: user.name,
                        phone: user.phone,
                        email: user.email,
                        role: user.role,
                        profileImage: null,
                        createdAt: user.createdAt,
                        studentCode: user.studentCode,
                        counselorName: user.counselorName,
                        counselorPhone: user.counselorPhone,
                        parentName: user.parentName,
                        parentPhone: user.parentPhone,
                      ));
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null && context.mounted) {
      final auth = context.read<AuthController>();
      final user = auth.user;
      if (user == null) return;

      final useMock = dotenv.get('USE_MOCK', fallback: 'false') == 'true';
      if (useMock) {
        auth.updateUser(user.copyWith(profileImage: picked.path));
      } else {
        try {
          final url = await StorageService().uploadProfileImage(
            user.id,
            File(picked.path),
          );
          auth.updateUser(user.copyWith(profileImage: url));
          await FirestoreService().updateDocument(
            FirestoreService().users,
            user.id,
            {'profileImage': url},
          );
        } catch (_) {
          auth.updateUser(user.copyWith(profileImage: picked.path));
        }
      }
    }
  }

  void _showQrDialog(BuildContext context, String studentCode, String name, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My QR Code',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Share this with your parent to link accounts',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: studentCode,
                  version: QrVersions.auto,
                  size: 200,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0F172A),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  studentCode,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.primaryBright
                        : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Close',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.primaryBright
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
                          gradient: user?.profileImage == null
                              ? (isDark
                                  ? AppColors.buttonGradientDark
                                  : AppColors.buttonGradient)
                              : null,
                          image: user?.profileImage != null
                              ? DecorationImage(
                                  image: user!.profileImage!.startsWith('http')
                                      ? NetworkImage(user.profileImage!)
                                      : FileImage(File(user.profileImage!)),
                                  fit: BoxFit.cover,
                                )
                              : null,
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
                        child: user?.profileImage == null
                            ? Center(
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
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _pickProfileImage(context),
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
                  Container(
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
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _showQrDialog(context, user!.studentCode!, user.name, isDark),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? AppColors.buttonGradientDark
                            : AppColors.buttonGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.qr_code_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Show QR Code',
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
            ],
          ),
        ),
        // Academic Details — student only
        if (user?.role == UserRole.student) ...[
          const SizedBox(height: 12),
          AnimatedListItem(
            index: 1,
            child: _GlassSettingsSection(
              title: AppStrings.academicDetails,
              items: [
                _SettingItem(
                  icon: Icons.school_outlined,
                  label: AppStrings.academicDetails,
                  onTap: () => Navigator.pushNamed(context, '/academic-form'),
                ),
              ],
            ),
          ),
        ],
        // Chat with Counsellor — student only (shown when counselor is assigned)
        if (user?.role == UserRole.student &&
            user?.counselorName != null) ...[
          const SizedBox(height: 12),
          AnimatedListItem(
            index: 1,
            child: _GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Counsellor',
                    style: GoogleFonts.sora(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark
                                  ? AppColors.primaryBright
                                  : AppColors.primary)
                              .withValues(alpha: isDark ? 0.2 : 0.1),
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: isDark
                              ? AppColors.primaryBright
                              : AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user!.counselorName!,
                              style: GoogleFonts.sora(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (user.counselorPhone != null)
                              Text(
                                user.counselorPhone!,
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
                    ],
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatCounselorScreen(
                            counselorName: user.counselorName!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isDark
                            ? AppColors.buttonGradientDark
                            : AppColors.buttonGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Chat with Counsellor',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
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
        ],
        // Your Counsellor — parent only
        if (user?.role == UserRole.parent) ...[
          const SizedBox(height: 12),
          AnimatedListItem(
            index: 1,
            child: _ParentCounselorSection(isDark: isDark),
          ),
        ],
        const SizedBox(height: 12),
        AnimatedListItem(
          index: user?.role == UserRole.student
              ? 2
              : user?.role == UserRole.parent
                  ? 2
                  : 1,
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
          index: user?.role == UserRole.student
              ? 3
              : user?.role == UserRole.parent
                  ? 3
                  : 2,
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
                    context, '/welcome', (_) => false);
              }
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Card with translucent background (no blur)
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

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.5),
          width: AppSizes.glassBorderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Settings section with translucent background
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
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.65),
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
      ],
    );
  }
}

class _ParentCounselorSection extends StatelessWidget {
  final bool isDark;

  const _ParentCounselorSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final parentCtrl = context.watch<ParentController>();
    final linkedStudents = parentCtrl.linkedStudents;
    final counselorName = linkedStudents.isNotEmpty
        ? linkedStudents[0]['counselorName'] as String?
        : null;
    final counselorPhone = linkedStudents.isNotEmpty
        ? linkedStudents[0]['counselorPhone'] as String?
        : null;
    final hasAssigned =
        counselorName != null && counselorName != 'Not assigned';

    return _GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Counsellor',
            style: GoogleFonts.sora(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          if (hasAssigned) ...[
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isDark
                            ? AppColors.primaryBright
                            : AppColors.primary)
                        .withValues(alpha: isDark ? 0.2 : 0.1),
                  ),
                  child: Icon(
                    Icons.school_rounded,
                    color:
                        isDark ? AppColors.primaryBright : AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        counselorName,
                        style: GoogleFonts.sora(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (counselorPhone != null)
                        Text(
                          counselorPhone,
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
              ],
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, '/select-counselor'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.primaryBright
                        : AppColors.primary,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    AppStrings.changeCounselor,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.primaryBright
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ] else ...[
            Text(
              AppStrings.noCounselorSelected,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, '/select-counselor'),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.buttonGradientDark
                      : AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    AppStrings.selectCounselor,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
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
