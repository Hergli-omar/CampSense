import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Secondary action button (outlined style, 56px height, 16px radius).
class CsButtonSecondary extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isDanger;

  const CsButtonSecondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final border = isDanger
        ? (isDark ? AppColors.darkDanger : AppColors.lightDanger)
        : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder);

    final fg = isDanger
        ? (isDark ? AppColors.darkDanger : AppColors.lightDanger)
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightPrimary);

    return SizedBox(
      height: 56,
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: border, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
