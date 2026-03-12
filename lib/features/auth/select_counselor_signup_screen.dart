import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/parent_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/fade_in_widget.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/scale_fade_in.dart';
import '../../models/counselor_model.dart';
import '../../models/user_model.dart';

class SelectCounselorSignupScreen extends StatefulWidget {
  const SelectCounselorSignupScreen({super.key});

  @override
  State<SelectCounselorSignupScreen> createState() =>
      _SelectCounselorSignupScreenState();
}

class _SelectCounselorSignupScreenState
    extends State<SelectCounselorSignupScreen> {
  final _searchController = TextEditingController();
  CounselorModel? _selectedCounselor;

  static const _specializations = [
    'STEM',
    'Arts',
    'Commerce',
    'Medical',
    'Humanities',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParentController>().loadAvailableCounselors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToDashboard() {
    final auth = context.read<AuthController>();
    final role = auth.user?.role ?? auth.selectedRole ?? UserRole.student;
    final route = switch (role) {
      UserRole.student => '/student-dashboard',
      UserRole.parent => '/parent-dashboard',
      UserRole.counselor => '/counselor-dashboard',
    };
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
  }

  void _onCounselorSelected(CounselorModel counselor) {
    setState(() {
      _selectedCounselor = counselor;
    });
  }

  void _confirmAndProceed() {
    if (_selectedCounselor != null) {
      final auth = context.read<AuthController>();
      final user = auth.user;
      if (user != null) {
        auth.updateUser(user.copyWith(
          counselorName: _selectedCounselor!.name,
          counselorPhone: _selectedCounselor!.phone,
        ));
      }
    }
    _navigateToDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parentCtrl = context.watch<ParentController>();

    return GlassScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg, AppSizes.md, AppSizes.lg, 0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  ScaleFadeIn(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.psychology_rounded,
                        size: 32,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Choose Your Counsellor',
                      style: GoogleFonts.sora(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeInWidget(
                    delay: const Duration(milliseconds: 150),
                    child: Text(
                      'Select a counsellor to guide your career journey',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.5),
                    width: AppSizes.glassBorderWidth,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (q) => parentCtrl.searchCounselors(q),
                  style: GoogleFonts.dmSans(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search counsellors...',
                    hintStyle: GoogleFonts.dmSans(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Specialization filter chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                itemCount: _specializations.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSizes.sm),
                itemBuilder: (context, index) {
                  final spec = _specializations[index];
                  final isSelected = parentCtrl.counselorSpecFilter == spec;
                  return FilterChip(
                    label: Text(spec),
                    selected: isSelected,
                    onSelected: (_) {
                      parentCtrl
                          .setCounselorSpecFilter(isSelected ? null : spec);
                    },
                    labelStyle: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary),
                    ),
                    selectedColor:
                        isDark ? AppColors.primaryBright : AppColors.primary,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.65),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.5)),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusRound),
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
            const SizedBox(height: AppSizes.sm),

            // Counselor list
            Expanded(
              child: parentCtrl.state == ParentLoadState.loading &&
                      parentCtrl.filteredCounselors.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : parentCtrl.filteredCounselors.isEmpty
                      ? Center(
                          child: Text(
                            'No counsellors found',
                            style: GoogleFonts.dmSans(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSizes.md),
                          itemCount: parentCtrl.filteredCounselors.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSizes.md),
                          itemBuilder: (context, index) {
                            final counselor =
                                parentCtrl.filteredCounselors[index];
                            final isSelected =
                                _selectedCounselor?.id == counselor.id;
                            return AnimatedListItem(
                              index: index,
                              child: _SignupCounselorCard(
                                counselor: counselor,
                                isSelected: isSelected,
                                onSelect: counselor.isAvailable
                                    ? () => _onCounselorSelected(counselor)
                                    : null,
                              ),
                            );
                          },
                        ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedCounselor != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Selected: ${_selectedCounselor!.name}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    CustomButton(
                      text: _selectedCounselor != null
                          ? 'Continue with Counsellor'
                          : 'Select a Counsellor',
                      onPressed:
                          _selectedCounselor != null ? _confirmAndProceed : null,
                      icon: Icons.arrow_forward_rounded,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _navigateToDashboard,
                      child: Text(
                        'Skip for now',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignupCounselorCard extends StatelessWidget {
  final CounselorModel counselor;
  final bool isSelected;
  final VoidCallback? onSelect;

  const _SignupCounselorCard({
    required this.counselor,
    required this.isSelected,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.primaryBright : AppColors.primary)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.5)),
            width: isSelected ? 2 : AppSizes.glassBorderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? (isDark ? AppColors.primaryBright : AppColors.primary)
                      .withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: avatar + name + specialization + check
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isDark
                          ? AppColors.buttonGradientDark
                          : AppColors.buttonGradient,
                    ),
                    child: Center(
                      child: Text(
                        counselor.name[0],
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          counselor.name,
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
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? AppColors.primaryBright
                                    : AppColors.primary)
                                .withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            counselor.specialization,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
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
                  if (isSelected)
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.primaryBright
                            : AppColors.primary,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18),
                    )
                  else if (!counselor.isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Unavailable',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  _StatChip(
                    icon: Icons.work_outline_rounded,
                    label: '${counselor.experienceYears} yrs',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: Icons.star_rounded,
                    label: counselor.rating.toString(),
                    isDark: isDark,
                    iconColor: AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    icon: Icons.people_outline_rounded,
                    label: '${counselor.studentsGuided}',
                    isDark: isDark,
                  ),
                  const Spacer(),
                  Text(
                    '\u20B9${counselor.pricePerSession.toInt()}/session',
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bio
              Text(
                counselor.bio,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  height: 1.4,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              // Languages
              Row(
                children: [
                  Icon(Icons.language_rounded,
                      size: 15,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    counselor.languages.join(', '),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color? iconColor;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.isDark,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 15,
          color: iconColor ??
              (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
