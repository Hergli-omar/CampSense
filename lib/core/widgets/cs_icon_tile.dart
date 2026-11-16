import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CsTileVariant {
  standard,
  danger,
  amber,
}

/// 48px square icon tile with 14px border radius.
class CsIconTile extends StatelessWidget {
  final IconData icon;
  final CsTileVariant variant;
  final double size;
  final double iconSize;

  const CsIconTile({
    super.key,
    required this.icon,
    this.variant = CsTileVariant.standard,
    this.size = 48,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color iconColor;

    switch (variant) {
      case CsTileVariant.danger:
        bg = isDark ? AppColors.darkDangerTile : AppColors.lightDangerTile;
        iconColor = isDark ? AppColors.darkDanger : AppColors.lightDanger;
      case CsTileVariant.amber:
        bg = isDark ? AppColors.darkAmberBackground : AppColors.lightAmberBackground;
        iconColor = isDark ? AppColors.darkAmberText : AppColors.lightAmberText;
      case CsTileVariant.standard:
        bg = isDark ? AppColors.darkTile : AppColors.lightTile;
        iconColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ),
    );
  }
}
