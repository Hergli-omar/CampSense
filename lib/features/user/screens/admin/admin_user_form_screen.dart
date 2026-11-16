import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/cs_button_primary.dart';
import '../../../../core/widgets/cs_button_secondary.dart';
import '../../../../core/widgets/cs_card.dart';
import '../../../../core/widgets/cs_confirm_dialog.dart';
import '../../../../core/widgets/cs_dropdown.dart';
import '../../../../core/widgets/cs_icon_tile.dart';
import '../../../../core/widgets/cs_screen_header.dart';
import '../../../../core/widgets/cs_text_field.dart';
import '../../models/user.dart';
import '../../providers/admin_users_provider.dart';
import '../../providers/auth_provider.dart';

enum AdminUserFormMode { create, edit }

/// Unified form screen for creating or editing user accounts on behalf of the administrator.
/// In Edit mode, the password cannot be modified by the administrator.
class AdminUserFormScreen extends StatefulWidget {
  final AdminUserFormMode mode;
  final User? userToEdit;

  const AdminUserFormScreen({
    super.key,
    required this.mode,
    this.userToEdit,
  });

  @override
  State<AdminUserFormScreen> createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;

  late String _role;
  late String _experienceLevel;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Track initial values in edit mode
  late final String _initialFullName;
  late final String _initialEmail;
  late final String _initialRole;
  late final String _initialExperienceLevel;
  late final String _initialEmergencyName;
  late final String _initialEmergencyPhone;

  @override
  void initState() {
    super.initState();
    final u = widget.userToEdit;

    _initialFullName = u?.fullName ?? '';
    _initialEmail = u?.email ?? '';
    _initialRole = u?.role == 'organizer' ? 'organizer' : 'camper';
    _initialExperienceLevel = u?.experienceLevel ?? 'beginner';
    _initialEmergencyName = u?.emergencyContactName ?? '';
    _initialEmergencyPhone = u?.emergencyContactPhone ?? '';

    _fullNameController = TextEditingController(text: _initialFullName);
    _emailController = TextEditingController(text: _initialEmail);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _emergencyNameController = TextEditingController(text: _initialEmergencyName);
    _emergencyPhoneController = TextEditingController(text: _initialEmergencyPhone);

    _role = _initialRole;
    _experienceLevel = _initialExperienceLevel;

    _fullNameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _emergencyNameController.addListener(_onFieldChanged);
    _emergencyPhoneController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (widget.mode == AdminUserFormMode.edit) {
      setState(() {});
    }
  }

  bool get _hasChanges {
    if (widget.mode == AdminUserFormMode.create) return true;
    return _fullNameController.text.trim() != _initialFullName ||
        _emailController.text.trim().toLowerCase() != _initialEmail.toLowerCase() ||
        _role != _initialRole ||
        _experienceLevel != _initialExperienceLevel ||
        _emergencyNameController.text.trim() != _initialEmergencyName ||
        _emergencyPhoneController.text.trim() != _initialEmergencyPhone;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final adminUser = context.read<AuthProvider>().currentUser;
    if (adminUser == null) return;

    final adminProvider = context.read<AdminUsersProvider>();
    setState(() => _isLoading = true);

    bool success;
    if (widget.mode == AdminUserFormMode.create) {
      success = await adminProvider.createUser(
        adminUser: adminUser,
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _role,
        experienceLevel: _experienceLevel,
        emergencyContactName: _emergencyNameController.text,
        emergencyContactPhone: _emergencyPhoneController.text,
      );
    } else {
      final updated = widget.userToEdit!.copyWith(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        role: _role,
        experienceLevel: _experienceLevel,
        emergencyContactName: _emergencyNameController.text.trim().isNotEmpty
            ? _emergencyNameController.text.trim()
            : null,
        emergencyContactPhone: _emergencyPhoneController.text.trim().isNotEmpty
            ? _emergencyPhoneController.text.trim()
            : null,
      );
      success = await adminProvider.updateUser(
        adminUser: adminUser,
        updatedUser: updated,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.mode == AdminUserFormMode.create
                ? AppStrings.userCreatedSuccess
                : AppStrings.userUpdatedSuccess,
          ),
          backgroundColor: AppColors.lightPrimary,
        ),
      );
      Navigator.of(context).pop(true);
    } else if (adminProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(adminProvider.errorMessage!),
          backgroundColor: AppColors.lightDanger,
        ),
      );
    }
  }

  Future<void> _handleDiscard() async {
    if (!_hasChanges) {
      Navigator.of(context).pop(false);
      return;
    }

    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => CsConfirmDialog(
        icon: Icons.warning_amber_rounded,
        tileVariant: CsTileVariant.amber,
        title: AppStrings.discardConfirmTitle,
        message: AppStrings.discardConfirmMessage,
        confirmLabel: AppStrings.discardConfirmYes,
        cancelLabel: AppStrings.discardConfirmNo,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );

    if (discard == true && mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCreate = widget.mode == AdminUserFormMode.create;

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleDiscard();
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CsScreenHeader(
                    overtitle: AppStrings.overtitleAdmin,
                    title: isCreate
                        ? AppStrings.adminCreateUserTitle
                        : AppStrings.adminEditUserTitle,
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _handleDiscard,
                      tooltip: AppStrings.cancelButton,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. Identity section card
                  CsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.personalInfoSection,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTitle,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Full name
                        CsTextField(
                          controller: _fullNameController,
                          label: AppStrings.fullNameLabel,
                          hint: AppStrings.fullNameHint,
                          prefixIcon: Icons.person_outline_rounded,
                          validator: Validators.validateFullName,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        CsTextField(
                          controller: _emailController,
                          label: AppStrings.emailLabel,
                          hint: AppStrings.emailHint,
                          prefixIcon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        // Role Selector (strictly Camper vs Organizer, NEVER Admin)
                        Text(
                          AppStrings.roleLabel,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTitle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkTile : AppColors.lightTile,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildRoleButton(
                                  label: AppStrings.roleCamper,
                                  icon: Icons.hiking_rounded,
                                  roleValue: 'camper',
                                  isSelected: _role == 'camper',
                                  isDark: isDark,
                                ),
                              ),
                              Expanded(
                                child: _buildRoleButton(
                                  label: AppStrings.roleOrganizer,
                                  icon: Icons.supervisor_account_rounded,
                                  roleValue: 'organizer',
                                  isSelected: _role == 'organizer',
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Experience Level Dropdown
                        CsDropdown<String>(
                          label: AppStrings.experienceLevelLabel,
                          initialValue: _experienceLevel,
                          items: const [
                            DropdownMenuItem(
                              value: 'beginner',
                              child: Text(AppStrings.experienceBeginner),
                            ),
                            DropdownMenuItem(
                              value: 'intermediate',
                              child: Text(AppStrings.experienceIntermediate),
                            ),
                            DropdownMenuItem(
                              value: 'advanced',
                              child: Text(AppStrings.experienceAdvanced),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _experienceLevel = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Password section (ONLY in Create mode)
                  if (isCreate) ...[
                    CsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.passwordLabel,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTitle,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CsTextField(
                            controller: _passwordController,
                            label: AppStrings.passwordLabel,
                            hint: AppStrings.passwordHint,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            validator: Validators.validatePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CsTextField(
                            controller: _confirmPasswordController,
                            label: AppStrings.confirmPasswordLabel,
                            hint: AppStrings.confirmPasswordHint,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscureConfirm,
                            validator: (val) =>
                                Validators.validateConfirmPassword(
                              val,
                              _passwordController.text,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 3. Emergency Contact section
                  CsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.emergencyContactSection,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTitle,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CsTextField(
                          controller: _emergencyNameController,
                          label: AppStrings.emergencyContactNameLabel,
                          hint: AppStrings.emergencyContactNameHint,
                          prefixIcon: Icons.person_pin_circle_outlined,
                        ),
                        const SizedBox(height: 16),
                        CsTextField(
                          controller: _emergencyPhoneController,
                          label: AppStrings.emergencyContactPhoneLabel,
                          hint: AppStrings.emergencyContactPhoneHint,
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: Validators.validatePhone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  CsButtonPrimary(
                    label: isCreate
                        ? AppStrings.adminSubmitCreateUser
                        : AppStrings.adminSubmitEditUser,
                    isLoading: _isLoading,
                    onPressed: (!isCreate && !_hasChanges) ? null : _handleSave,
                  ),
                  const SizedBox(height: 12),
                  CsButtonSecondary(
                    label: AppStrings.discardChangesButton,
                    onPressed: _handleDiscard,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required IconData icon,
    required String roleValue,
    required bool isSelected,
    required bool isDark,
  }) {
    final selectedBg = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final selectedFg = isDark ? AppColors.darkPrimaryText : Colors.white;
    final unselectedFg =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: () => setState(() => _role = roleValue),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? selectedFg : unselectedFg,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? selectedFg : unselectedFg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
