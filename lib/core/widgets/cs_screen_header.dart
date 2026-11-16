import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/strings.dart';
import '../theme/app_colors.dart';
import '../theme/theme_x.dart';
import '../theme/app_theme.dart';

/// Screen header matching Figma designs:
/// 1. Mountain logo + "CampSense" brand row
/// 2. Uppercase spaced overtitle (e.g. "COMPTE")
/// 3. Bold screen title (32px)
class CsScreenHeader extends StatelessWidget {
  final String overtitle;
  final String title;
  final Widget? trailing;
  final bool showBrand;

  const CsScreenHeader({
    super.key,
    required this.overtitle,
    required this.title,
    this.trailing,
    this.showBrand = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showBrand) ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkTile : AppColors.lightTile,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.terrain_rounded,
                  size: 20,
                  color: primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.appName,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 20),
        ],
        Text(
          overtitle.toUpperCase(),
          style: AppTheme.overtitleStyle.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: AppTheme.screenTitleStyle.copyWith(
            color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
          ),
        ),
      ],
    );
  }
}

/// Decorative hero image header with fallback green gradient and tent icon
/// if `assets/images/hero.jpg` is missing.
class CsHeroBanner extends StatelessWidget {
  final double height;

  const CsHeroBanner({
    super.key,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.asset(
          'assets/images/hero.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Elegant green camping fallback banner
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [context.colors.card, context.colors.background]
                      : [context.colors.primary, context.colors.title],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 20,
                    bottom: 15,
                    child: Icon(
                      Icons.cabin_rounded,
                      size: 80,
                      color: Colors.white.withAlpha(35),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.appName,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.appTagline,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
