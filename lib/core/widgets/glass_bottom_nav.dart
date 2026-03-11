import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.primaryBright : AppColors.primary;
    final inactiveColor = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : AppColors.textSecondary;

    return Container(
      margin: const EdgeInsets.all(AppSizes.md),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0F0F1A).withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(
            color: AppColors.glassBorder(isDark),
            width: AppSizes.glassBorderWidth,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / items.length;
            return Stack(
              children: [
                // Sliding indicator pill
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  left: itemWidth * currentIndex +
                      (itemWidth - 20) / 2,
                  bottom: 6,
                  child: Container(
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      color: activeColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Nav items
                Row(
                  children: List.generate(items.length, (i) {
                    final isSelected = i == currentIndex;
                    final item = items[i];
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTap(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconTheme(
                              data: IconThemeData(
                                color: isSelected
                                    ? activeColor
                                    : inactiveColor,
                                size: 24,
                              ),
                              child: item.icon,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? activeColor
                                    : inactiveColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
