import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/strings.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/cs_card.dart';
import '../core/widgets/cs_chip.dart';
import '../core/widgets/cs_icon_tile.dart';

/// Temporary placeholder screen for other CampSense modules under development.
/// Displays module name, icon, and the specific physical sensor assigned to that module.
class ModulePlaceholderScreen extends StatelessWidget {
  final String moduleName;
  final IconData moduleIcon;
  final String associatedSensor;
  final IconData sensorIcon;

  const ModulePlaceholderScreen({
    super.key,
    required this.moduleName,
    required this.moduleIcon,
    required this.associatedSensor,
    required this.sensorIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Center(
                child: CsCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CsIconTile(
                        icon: moduleIcon,
                        size: 64,
                        iconSize: 32,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        moduleName,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Module ${AppStrings.moduleInProgress}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Divider(
                        color: isDark
                            ? AppColors.darkCardBorder
                            : AppColors.lightCardBorder,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.moduleSensorLabel,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      CsChip(
                        label: associatedSensor,
                        icon: sensorIcon,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
