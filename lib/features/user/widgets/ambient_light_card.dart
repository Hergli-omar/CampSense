import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cs_card.dart';
import '../../../core/widgets/cs_icon_tile.dart';
import '../providers/theme_provider.dart';

/// Ambient light sensor card displaying:
/// - Sun/Moon icon tile
/// - Live JetBrains Mono lux reading
/// - Category (Plein soleil, Lumineux, Ombre, Faible lumière, Obscurité)
/// - Segmented control: Auto / Clair / Sombre
/// - Debug simulation slider (kDebugMode only)
class AmbientLightCard extends StatelessWidget {
  const AmbientLightCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lux = themeProvider.currentLux;

    return CsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              CsIconTile(
                icon: isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                variant: CsTileVariant.standard,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.overtitleAppearance,
                      style: AppTheme.overtitleStyle.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.appearanceTitle,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Sensor status & live reading
          if (!themeProvider.isSensorAvailable && !themeProvider.isSimulationEnabled) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkAmberBackground
                    : AppColors.lightAmberBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: isDark
                        ? AppColors.darkAmberText
                        : AppColors.lightAmberText,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.sensorUnavailable,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkAmberText
                                : AppColors.lightAmberText,
                          ),
                        ),
                        Text(
                          AppStrings.sensorFallbackManual,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkAmberText
                                : AppColors.lightAmberText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkTile : AppColors.lightTile,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${lux.toStringAsFixed(0)} lx',
                        style: AppTheme.monoNumberStyle.copyWith(
                          fontSize: 24,
                          color: isDark
                              ? AppColors.darkTitle
                              : AppColors.lightPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        themeProvider.luxCategory,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkCard
                          : AppColors.lightCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkCardBorder
                            : AppColors.lightCardBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          themeProvider.preference == ThemePreference.auto
                              ? Icons.sensors_rounded
                              : (isDark
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined),
                          size: 16,
                          color: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          themeProvider.preference == ThemePreference.auto
                              ? 'Capteur actif'
                              : (isDark ? 'Mode Nuit' : 'Mode Jour'),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Segmented Theme Selector (Auto / Clair / Sombre)
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkTile : AppColors.lightTile,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _buildSegmentButton(
                  context: context,
                  label: AppStrings.themeModeAuto,
                  icon: Icons.brightness_auto_rounded,
                  isSelected:
                      themeProvider.preference == ThemePreference.auto,
                  onTap: () =>
                      themeProvider.setPreference(ThemePreference.auto),
                ),
                _buildSegmentButton(
                  context: context,
                  label: AppStrings.themeModeLight,
                  icon: Icons.light_mode_rounded,
                  isSelected:
                      themeProvider.preference == ThemePreference.light,
                  onTap: () =>
                      themeProvider.setPreference(ThemePreference.light),
                ),
                _buildSegmentButton(
                  context: context,
                  label: AppStrings.themeModeDark,
                  icon: Icons.dark_mode_rounded,
                  isSelected:
                      themeProvider.preference == ThemePreference.dark,
                  onTap: () =>
                      themeProvider.setPreference(ThemePreference.dark),
                ),
              ],
            ),
          ),

          // Debug simulation slider (kDebugMode only)
          if (kDebugMode) ...[
            const SizedBox(height: 18),
            Divider(
              color: isDark
                  ? AppColors.darkCardBorder
                  : AppColors.lightCardBorder,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.debugSimulation,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightAccent,
                  ),
                ),
                Switch.adaptive(
                  value: themeProvider.isSimulationEnabled,
                  activeTrackColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.lightPrimary,
                  onChanged: (val) => themeProvider.toggleSimulation(val),
                ),
              ],
            ),
            if (themeProvider.isSimulationEnabled) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${AppStrings.simulatedLux} ${themeProvider.simulatedLux.toStringAsFixed(0)} lx',
                    style: AppTheme.monoNumberStyle.copyWith(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    themeProvider.simulatedLux < 40
                        ? '(< 40 lx -> Sombre)'
                        : (themeProvider.simulatedLux > 120
                            ? '(> 120 lx -> Clair)'
                            : '(40–120 lx -> Hystérésis)'),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: themeProvider.simulatedLux,
                min: 0,
                max: 10000,
                divisions: 100,
                activeColor: isDark
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
                label: '${themeProvider.simulatedLux.toStringAsFixed(0)} lx',
                onChanged: (val) => themeProvider.setSimulatedLux(val),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? (isDark ? AppColors.darkPrimaryText : Colors.white)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimaryText : Colors.white)
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
