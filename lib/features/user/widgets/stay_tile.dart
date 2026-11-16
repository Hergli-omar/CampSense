import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_x.dart';
import '../../../core/widgets/cs_chip.dart';
import '../models/stay.dart';

/// Card item displaying a past or upcoming camping stay.
/// Displays place, dates formatted in French, notes, and a status chip.
class StayTile extends StatelessWidget {
  final Stay stay;
  final VoidCallback? onDelete;

  const StayTile({
    super.key,
    required this.stay,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUpcoming = stay.isUpcoming;

    final content = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stay.placeName,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                  ),
                ),
              ),
              CsChip(
                label: isUpcoming ? AppStrings.stayUpcoming : AppStrings.stayFinished,
                icon: isUpcoming ? Icons.calendar_today_rounded : Icons.check_circle_outline_rounded,
                customBackgroundColor: isUpcoming
                    ? context.colors.tile
                    : context.colors.cardBorder,
                customTextColor: isUpcoming
                    ? context.colors.primary
                    : context.colors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.date_range_outlined,
                size: 15,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                stay.dateRangeFr,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          if (stay.notes != null && stay.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              stay.notes!,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    if (onDelete != null) {
      return Dismissible(
        key: Key('stay_${stay.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkDanger : AppColors.lightDanger,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
        ),
        onDismissed: (_) => onDelete!(),
        child: content,
      );
    }

    return content;
  }
}
