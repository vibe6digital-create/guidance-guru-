import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/parent_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../models/counselor_model.dart';

class SelectCounselorScreen extends StatefulWidget {
  const SelectCounselorScreen({super.key});

  @override
  State<SelectCounselorScreen> createState() => _SelectCounselorScreenState();
}

class _SelectCounselorScreenState extends State<SelectCounselorScreen> {
  final _searchController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parentCtrl = context.watch<ParentController>();

    return GlassScaffold(
      appBar: GlassAppBar(title: AppStrings.selectCounselor),
      body: parentCtrl.state == ParentLoadState.loading &&
              parentCtrl.filteredCounselors.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.sm),
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
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),

                // Specialization filter chips
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSizes.md),
                    itemCount: _specializations.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSizes.sm),
                    itemBuilder: (context, index) {
                      final spec = _specializations[index];
                      final isSelected =
                          parentCtrl.counselorSpecFilter == spec;
                      return FilterChip(
                        label: Text(spec),
                        selected: isSelected,
                        onSelected: (_) {
                          parentCtrl.setCounselorSpecFilter(
                              isSelected ? null : spec);
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
                        selectedColor: isDark
                            ? AppColors.primaryBright
                            : AppColors.primary,
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
                  child: parentCtrl.filteredCounselors.isEmpty
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
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSizes.md),
                          itemBuilder: (context, index) {
                            final counselor =
                                parentCtrl.filteredCounselors[index];
                            return AnimatedListItem(
                              index: index,
                              child: _CounselorCard(
                                counselor: counselor,
                                onSelect: () =>
                                    _confirmSelection(context, counselor),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  void _confirmSelection(
      BuildContext context, CounselorModel counselor) {
    Navigator.pushNamed(
      context,
      '/counselling-proposal',
      arguments: counselor,
    );
  }
}

class _CounselorCard extends StatelessWidget {
  final CounselorModel counselor;
  final VoidCallback onSelect;

  const _CounselorCard({required this.counselor, required this.onSelect});

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
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + name + specialization
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
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
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        counselor.name,
                        style: GoogleFonts.sora(
                          fontSize: 16,
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
              ],
            ),
            const SizedBox(height: 14),

            // Stats row: experience, rating, students
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
              ],
            ),
            const SizedBox(height: 12),

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
            const SizedBox(height: 12),

            // Languages + Price row
            Row(
              children: [
                Icon(Icons.language_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    counselor.languages.join(', '),
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '\u20B9${counselor.pricePerSession.toInt()}/session',
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Select button
            SizedBox(
              width: double.infinity,
              child: counselor.isAvailable
                  ? GestureDetector(
                      onTap: onSelect,
                      child: Container(
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
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          'Not Available',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
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
          size: 16,
          color: iconColor ??
              (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
