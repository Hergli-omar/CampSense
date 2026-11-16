import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cs_button_primary.dart';
import '../../../../core/widgets/cs_button_secondary.dart';
import '../../../../core/widgets/cs_card.dart';
import '../../../../core/widgets/cs_dropdown.dart';
import '../../../../core/widgets/cs_icon_tile.dart';
import '../../../../core/widgets/cs_screen_header.dart';
import '../../../../core/widgets/cs_text_field.dart';

/// Graphical mockup detail screen for reports.
/// Shows report metadata and dummy response fields.
/// All actions show a "Bientôt disponible" notice.
class AdminReportDetailScreen extends StatefulWidget {
  final Map<String, dynamic> report;

  const AdminReportDetailScreen({
    super.key,
    required this.report,
  });

  @override
  State<AdminReportDetailScreen> createState() =>
      _AdminReportDetailScreenState();
}

class _AdminReportDetailScreenState extends State<AdminReportDetailScreen> {
  final _responseController = TextEditingController();
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.report['status'] as String? ?? 'open';
  }

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.featureComingSoon),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = widget.report;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CsScreenHeader(
                overtitle: AppStrings.overtitleAdmin,
                title: AppStrings.reportDetailTitle,
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Retour',
                ),
              ),
              const SizedBox(height: 20),

              // 1. Report Overview Card
              CsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CsIconTile(
                          icon: r['icon'] as IconData? ?? Icons.flag_rounded,
                          variant: r['status'] == 'open'
                              ? CsTileVariant.amber
                              : CsTileVariant.standard,
                          size: 44,
                          iconSize: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r['title'] as String? ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTitle,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${r['targetType']} · ${r['date']}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoItem(
                      label: AppStrings.reportAuthorLabel,
                      value: r['author'] as String? ?? '',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoItem(
                      label: AppStrings.reportReasonLabel,
                      value: r['reason'] as String? ?? '',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 10),
                    _buildInfoItem(
                      label: AppStrings.reportDescriptionLabel,
                      value: r['description'] as String? ?? '',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Status & Moderation Card
              CsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.reportStatusLabel,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTitle,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CsDropdown<String>(
                      label: AppStrings.reportStatusLabel,
                      initialValue: _status,
                      items: const [
                        DropdownMenuItem(
                          value: 'open',
                          child: Text(AppStrings.reportsCountOpen),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text(AppStrings.reportsCountInProgress),
                        ),
                        DropdownMenuItem(
                          value: 'resolved',
                          child: Text(AppStrings.reportsCountResolved),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _status = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CsTextField(
                      controller: _responseController,
                      label: AppStrings.reportResponseLabel,
                      hint: AppStrings.reportResponseHint,
                      prefixIcon: Icons.reply_rounded,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Action Buttons (All show "Bientôt disponible" toast)
              CsButtonPrimary(
                label: AppStrings.reportSaveResponse,
                icon: Icons.send_rounded,
                onPressed: _showComingSoon,
              ),
              const SizedBox(height: 12),
              CsButtonSecondary(
                label: AppStrings.reportViewContent,
                icon: Icons.open_in_new_rounded,
                onPressed: _showComingSoon,
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.darkDanger
                        : AppColors.lightDanger,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkDanger
                          : AppColors.lightDanger,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _showComingSoon,
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  label: Text(
                    AppStrings.reportDeleteContent,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTitle,
          ),
        ),
      ],
    );
  }
}
