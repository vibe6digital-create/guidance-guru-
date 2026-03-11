import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../models/user_model.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole;

  final _roles = [
    {
      'role': UserRole.student,
      'title': AppStrings.student,
      'desc': AppStrings.studentDesc,
      'icon': Icons.school_rounded,
      'color': AppColors.primary,
    },
    {
      'role': UserRole.parent,
      'title': AppStrings.parent,
      'desc': AppStrings.parentDesc,
      'icon': Icons.family_restroom_rounded,
      'color': AppColors.accent,
    },
    {
      'role': UserRole.counselor,
      'title': AppStrings.counselor,
      'desc': AppStrings.counselorDesc,
      'icon': Icons.psychology_rounded,
      'color': AppColors.warning,
    },
  ];

  void _onContinue() {
    if (_selectedRole == null) return;
    context.read<AuthController>().selectRole(_selectedRole!);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final nextRoute = args?['nextRoute'] as String? ?? '/signup';
    Navigator.pushNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const AppLogo(
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Who are you?',
                  style: GoogleFonts.sora(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select your role to get a personalized experience',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                ...List.generate(_roles.length, (index) {
                  final role = _roles[index];
                  final isSelected =
                      _selectedRole == role['role'] as UserRole;
                  return AnimatedListItem(
                    index: index,
                    delay: const Duration(milliseconds: 80),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RoleCard(
                        title: role['title'] as String,
                        description: role['desc'] as String,
                        icon: role['icon'] as IconData,
                        color: role['color'] as Color,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedRole = role['role'] as UserRole;
                          });
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                FadeInWidget(
                  delay: const Duration(milliseconds: 300),
                  child: CustomButton(
                    text: AppStrings.continueText,
                    onPressed: _selectedRole != null ? _onContinue : null,
                    icon: Icons.arrow_forward_rounded,
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.2)
            : (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.65)),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: isSelected ? color : AppColors.glassBorder(isDark),
          width: isSelected ? 2 : AppSizes.glassBorderWidth,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedScale(
                      scale: isSelected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}
