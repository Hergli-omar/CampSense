import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cs_button_secondary.dart';
import '../../../../core/widgets/cs_card.dart';
import '../../../../core/widgets/cs_chip.dart';
import '../../../../core/widgets/cs_confirm_dialog.dart';
import '../../../../core/widgets/cs_screen_header.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ambient_light_card.dart';

/// Administrator profile tab displaying:
/// - Identity summary (Name, Email, Administrator chip)
/// - Ambient light sensor & appearance controls
/// - Logout button with confirmation
/// (Excludes stays history, emergency contact, and account deletion)
class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => CsConfirmDialog(
        icon: Icons.logout_rounded,
        title: AppStrings.logoutConfirmTitle,
        message: AppStrings.logoutConfirmMessage,
        confirmLabel: AppStrings.logoutButton,
        cancelLabel: AppStrings.cancelButton,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final avatarBg = isDark ? AppColors.darkTile : AppColors.lightTile;
    final avatarFg = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CsScreenHeader(
                overtitle: AppStrings.overtitleAdmin,
                title: AppStrings.adminTabProfile,
              ),
              const SizedBox(height: 20),

              // 1. Admin Identity Card
              CsCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: avatarBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            user?.initials ?? 'AD',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: avatarFg,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.fullName ?? 'Omar (Administrateur)',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTitle,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'omar@campsense.com',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const CsChip(
                          label: AppStrings.roleAdmin,
                          icon: Icons.shield_rounded,
                          isSelected: true,
                        ),
                        const SizedBox(width: 8),
                        CsChip(
                          label: user?.experienceLevelLabelFr ??
                              AppStrings.experienceAdvanced,
                          isSelected: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Ambient Light / Appearance Card
              const AmbientLightCard(),
              const SizedBox(height: 28),

              // 3. Logout Button
              CsButtonSecondary(
                label: AppStrings.logoutButton,
                icon: Icons.logout_rounded,
                onPressed: () => _handleLogout(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
