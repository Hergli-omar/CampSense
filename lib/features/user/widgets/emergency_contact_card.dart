import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/cs_card.dart';
import '../../../core/widgets/cs_confirm_dialog.dart';
import '../../../core/widgets/cs_icon_tile.dart';
import '../../../core/widgets/cs_text_field.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

/// Card displaying emergency contact details with masked phone security.
/// Clicking "Afficher le numéro" triggers identity password verification.
class EmergencyContactCard extends StatelessWidget {
  final User user;

  const EmergencyContactCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasContact = user.emergencyContactName != null &&
        user.emergencyContactName!.isNotEmpty;

    final isRevealed = userProvider.isEmergencyPhoneRevealed;
    final maskedPhone = Validators.maskPhoneNumber(user.emergencyContactPhone);
    final displayedPhone =
        isRevealed ? (user.emergencyContactPhone ?? '') : maskedPhone;

    return CsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CsIconTile(
                icon: Icons.contact_emergency_rounded,
                variant: CsTileVariant.standard,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.overtitleSecurity,
                      style: AppTheme.overtitleStyle.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.emergencyContactTitle,
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
          const SizedBox(height: 16),
          if (!hasContact) ...[
            Text(
              AppStrings.noEmergencyContact,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ] else ...[
            // Contact Name
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  user.emergencyContactName!,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Contact Phone
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  displayedPhone,
                  style: isRevealed
                      ? GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        )
                      : AppTheme.monoNumberStyle.copyWith(
                          fontSize: 15,
                          letterSpacing: 2.0,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    if (isRevealed) {
                      userProvider.hideEmergencyPhone();
                    } else {
                      _showPasswordPrompt(context);
                    }
                  },
                  icon: Icon(
                    isRevealed
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 16,
                    color: isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                  ),
                  label: Text(
                    isRevealed
                        ? AppStrings.hidePhoneButton
                        : AppStrings.revealPhoneButton,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (!isRevealed) ...[
              const SizedBox(height: 6),
              Text(
                AppStrings.emergencyContactHiddenNotice,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showPasswordPrompt(BuildContext context) {
    final passwordController = TextEditingController();
    var hasError = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setState) => CsConfirmDialog(
          icon: Icons.lock_outline_rounded,
          tileVariant: CsTileVariant.standard,
          title: AppStrings.verifyIdentityDialogTitle,
          message: AppStrings.verifyIdentityDialogDesc,
          confirmLabel: AppStrings.verifyButton,
          cancelLabel: AppStrings.cancelButton,
          extraContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CsTextField(
                controller: passwordController,
                labelText: AppStrings.passwordLabel,
                hintText: AppStrings.passwordHint,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _performVerify(
                  dialogCtx,
                  passwordController.text,
                  setState,
                  (err) => hasError = err,
                ),
              ),
              if (hasError) ...[
                const SizedBox(height: 8),
                Text(
                  AppStrings.incorrectPassword,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.lightDanger,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          onConfirm: () => _performVerify(
            dialogCtx,
            passwordController.text,
            setState,
            (err) => hasError = err,
          ),
        ),
      ),
    );
  }

  Future<void> _performVerify(
    BuildContext dialogCtx,
    String password,
    void Function(void Function()) setState,
    void Function(bool) setHasError,
  ) async {
    final authProvider = dialogCtx.read<AuthProvider>();
    final userProvider = dialogCtx.read<UserProvider>();

    final isValid = await authProvider.verifyCurrentPassword(password);
    if (isValid) {
      userProvider.revealEmergencyPhone();
      if (dialogCtx.mounted) {
        Navigator.of(dialogCtx).pop();
      }
    } else {
      setState(() {
        setHasError(true);
      });
    }
  }
}
