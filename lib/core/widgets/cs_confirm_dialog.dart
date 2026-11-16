import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/strings.dart';
import '../theme/app_colors.dart';
import 'cs_button_primary.dart';
import 'cs_button_secondary.dart';
import 'cs_icon_tile.dart';

/// Modal confirmation dialog with Figma styling:
/// - Rounded card (24px)
/// - Colored icon tile
/// - Clear title and body
/// - Confirm & cancel actions
class CsConfirmDialog extends StatelessWidget {
  final IconData icon;
  final CsTileVariant tileVariant;
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDanger;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Widget? extraContent;

  const CsConfirmDialog({
    super.key,
    required this.icon,
    this.tileVariant = CsTileVariant.standard,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = AppStrings.cancelButton,
    this.isDanger = false,
    required this.onConfirm,
    this.onCancel,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: borderColor, width: 1),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CsIconTile(
              icon: icon,
              variant: tileVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
            if (extraContent != null) ...[
              const SizedBox(height: 16),
              extraContent!,
            ],
            const SizedBox(height: 24),
            CsButtonPrimary(
              label: confirmLabel,
              isDanger: isDanger,
              onPressed: onConfirm,
            ),
            const SizedBox(height: 12),
            CsButtonSecondary(
              label: cancelLabel,
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
