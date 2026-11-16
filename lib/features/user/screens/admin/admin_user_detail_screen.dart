import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_format_fr.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/cs_button_primary.dart';
import '../../../../core/widgets/cs_card.dart';
import '../../../../core/widgets/cs_chip.dart';
import '../../../../core/widgets/cs_confirm_dialog.dart';
import '../../../../core/widgets/cs_icon_tile.dart';
import '../../../../core/widgets/cs_screen_header.dart';
import '../../../../core/widgets/cs_text_field.dart';
import '../../data/user_repository.dart';
import '../../models/user.dart';
import '../../providers/admin_users_provider.dart';
import '../../providers/auth_provider.dart';
import 'admin_user_form_screen.dart';

/// Account detail inspection screen for administrators.
/// Displays member identity, masked emergency phone, registration dates,
/// stay counts, and provides edit & delete entry points.
class AdminUserDetailScreen extends StatefulWidget {
  final User user;

  const AdminUserDetailScreen({
    super.key,
    required this.user,
  });

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  late User _currentUser;
  int _stayCount = 0;
  bool _isLoadingStays = true;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _fetchStayCount();
  }

  Future<void> _fetchStayCount() async {
    if (_currentUser.id == null) return;
    final repo = context.read<UserRepository>();
    final count = await repo.getStaysCountForUser(_currentUser.id!);
    if (mounted) {
      setState(() {
        _stayCount = count;
        _isLoadingStays = false;
      });
    }
  }

  Future<void> _handleEdit() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminUserFormScreen(
          mode: AdminUserFormMode.edit,
          userToEdit: _currentUser,
        ),
      ),
    );

    if (updated == true && mounted && _currentUser.id != null) {
      final repo = context.read<UserRepository>();
      final fresh = await repo.getUserById(_currentUser.id!);
      if (fresh != null && mounted) {
        setState(() => _currentUser = fresh);
      }
    }
  }

  Future<void> _handleDelete() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscurePassword = true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return CsConfirmDialog(
            icon: Icons.delete_forever_rounded,
            tileVariant: CsTileVariant.danger,
            isDanger: true,
            title: AppStrings.adminDeleteDialogTitle,
            message: AppStrings.adminDeleteDialogBody(
              _currentUser.fullName,
              _stayCount,
            ),
            confirmLabel: AppStrings.adminDeleteConfirmButton,
            cancelLabel: AppStrings.adminDeleteCancelButton,
            extraContent: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Form(
                key: formKey,
                child: CsTextField(
                  controller: passwordController,
                  label: AppStrings.adminPasswordConfirmLabel,
                  hint: AppStrings.adminPasswordConfirmHint,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: obscurePassword,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return AppStrings.errFieldRequired;
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                    ),
                    onPressed: () => setDialogState(
                        () => obscurePassword = !obscurePassword),
                  ),
                ),
              ),
            ),
            onConfirm: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            onCancel: () => Navigator.of(dialogCtx).pop(false),
          );
        },
      ),
    );

    if (confirmed == true && mounted) {
      final adminUser = context.read<AuthProvider>().currentUser;
      if (adminUser == null) return;

      final adminProvider = context.read<AdminUsersProvider>();
      final success = await adminProvider.deleteUser(
        adminUser: adminUser,
        targetUser: _currentUser,
        adminPassword: passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.userDeletedSuccess),
            backgroundColor: AppColors.lightPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(adminProvider.errorMessage ??
                AppStrings.incorrectPassword),
            backgroundColor: AppColors.lightDanger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final avatarBg = isDark ? AppColors.darkTile : AppColors.lightTile;
    final avatarFg = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final maskedPhone = Validators.maskPhoneNumber(_currentUser.emergencyContactPhone);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CsScreenHeader(
                overtitle: AppStrings.overtitleAdmin,
                title: AppStrings.userDetailTitle,
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Retour',
                ),
              ),
              const SizedBox(height: 20),

              // 1. User Identity Header Card
              CsCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: avatarBg,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _currentUser.initials,
                            style: GoogleFonts.inter(
                              fontSize: 22,
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
                                _currentUser.fullName,
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
                                _currentUser.email,
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
                        CsChip(
                          label: _currentUser.roleLabelFr,
                          icon: _currentUser.role == 'organizer'
                              ? Icons.supervisor_account_rounded
                              : Icons.hiking_rounded,
                          isSelected: true,
                        ),
                        const SizedBox(width: 8),
                        CsChip(
                          label: _currentUser.experienceLevelLabelFr,
                          isSelected: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2. Account Details Card
              CsCard(
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.calendar_today_rounded,
                      label: AppStrings.userDetailMemberSince,
                      value: DateFormatFr.formatShort(
                          DateFormatFr.fromIso(_currentUser.createdAt)),
                      isDark: isDark,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      icon: Icons.update_rounded,
                      label: AppStrings.userDetailLastUpdated,
                      value: DateFormatFr.formatShort(
                          DateFormatFr.fromIso(_currentUser.updatedAt)),
                      isDark: isDark,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      icon: Icons.cabin_rounded,
                      label: AppStrings.userDetailStayCount,
                      value: _isLoadingStays
                          ? '...'
                          : '$_stayCount séjour(s)',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 3. Emergency Contact Card (Masked phone, never plaintext)
              CsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CsIconTile(
                          icon: Icons.contact_emergency_outlined,
                          size: 40,
                          iconSize: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppStrings.emergencyContactTitle,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTitle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_currentUser.emergencyContactName == null &&
                        _currentUser.emergencyContactPhone == null)
                      Text(
                        AppStrings.noEmergencyContact,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      )
                    else ...[
                      if (_currentUser.emergencyContactName != null) ...[
                        Text(
                          _currentUser.emergencyContactName!,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTitle,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        maskedPhone.isEmpty
                            ? 'Non renseigné'
                            : maskedPhone,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 4. Action Buttons
              CsButtonPrimary(
                label: AppStrings.editUserButton,
                icon: Icons.edit_rounded,
                onPressed: _handleEdit,
              ),
              const SizedBox(height: 16),

              // Danger Zone Card with Delete Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkDangerTile.withValues(alpha: 0.3)
                      : AppColors.lightDangerTile.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkDanger.withValues(alpha: 0.3)
                        : AppColors.lightDanger.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.deleteAccountDangerZone,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkDanger
                            : AppColors.lightDanger,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkDanger
                              : AppColors.lightDanger,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _handleDelete,
                        icon: const Icon(Icons.delete_forever_rounded, size: 20),
                        label: Text(
                          AppStrings.deleteUserButton,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTitle,
          ),
        ),
      ],
    );
  }
}
