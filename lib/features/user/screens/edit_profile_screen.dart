import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/cs_button_primary.dart';
import '../../../core/widgets/cs_button_secondary.dart';
import '../../../core/widgets/cs_card.dart';
import '../../../core/widgets/cs_confirm_dialog.dart';
import '../../../core/widgets/cs_dropdown.dart';
import '../../../core/widgets/cs_icon_tile.dart';
import '../../../core/widgets/cs_screen_header.dart';
import '../../../core/widgets/cs_text_field.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';

/// Screen allowing the camper to update personal details, emergency contact,
/// or change password with identity verification.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late String _role;
  late String _experienceLevel;

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _isProfileDirty = false;
  bool _isPasswordDirty = false;
  bool _isSavingProfile = false;
  bool _isChangingPassword = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser!;
    _fullNameController = TextEditingController(text: user.fullName);
    _emailController = TextEditingController(text: user.email);
    _emergencyNameController =
        TextEditingController(text: user.emergencyContactName ?? '');
    _emergencyPhoneController =
        TextEditingController(text: user.emergencyContactPhone ?? '');
    _role = user.role;
    _experienceLevel = user.experienceLevel;

    _fullNameController.addListener(_checkProfileDirty);
    _emailController.addListener(_checkProfileDirty);
    _emergencyNameController.addListener(_checkProfileDirty);
    _emergencyPhoneController.addListener(_checkProfileDirty);

    _currentPasswordController.addListener(_checkPasswordDirty);
    _newPasswordController.addListener(_checkPasswordDirty);
    _confirmPasswordController.addListener(_checkPasswordDirty);
  }

  void _checkProfileDirty() {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final isChanged = _fullNameController.text != user.fullName ||
        _emailController.text != user.email ||
        _emergencyNameController.text != (user.emergencyContactName ?? '') ||
        _emergencyPhoneController.text != (user.emergencyContactPhone ?? '') ||
        _role != user.role ||
        _experienceLevel != user.experienceLevel;

    if (isChanged != _isProfileDirty) {
      setState(() => _isProfileDirty = isChanged);
    }
  }

  void _checkPasswordDirty() {
    final hasInput = _currentPasswordController.text.isNotEmpty ||
        _newPasswordController.text.isNotEmpty ||
        _confirmPasswordController.text.isNotEmpty;
    if (hasInput != _isPasswordDirty) {
      setState(() => _isPasswordDirty = hasInput);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_profileFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    setState(() => _isSavingProfile = true);

    try {
      final updated = await userProvider.updateProfile(
        currentUser: user,
        fullName: _fullNameController.text,
        email: _emailController.text,
        role: _role,
        experienceLevel: _experienceLevel,
        emergencyContactName: _emergencyNameController.text,
        emergencyContactPhone: _emergencyPhoneController.text,
      );

      authProvider.refreshCurrentUser(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.profileUpdatedSuccess),
            backgroundColor: AppColors.lightPrimary,
          ),
        );
        setState(() => _isProfileDirty = false);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.lightDanger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  Future<void> _handleChangePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final user = authProvider.currentUser;
    if (user == null) return;

    setState(() => _isChangingPassword = true);

    try {
      final updated = await userProvider.changePassword(
        currentUser: user,
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      authProvider.refreshCurrentUser(updated);

      if (mounted) {
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        setState(() => _isPasswordDirty = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.passwordUpdatedSuccess),
            backgroundColor: AppColors.lightPrimary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.lightDanger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChangingPassword = false);
    }
  }

  Future<void> _handleDiscard() async {
    if (_isProfileDirty || _isPasswordDirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (ctx) => CsConfirmDialog(
          icon: Icons.warning_amber_rounded,
          tileVariant: CsTileVariant.amber,
          title: AppStrings.discardConfirmTitle,
          message: AppStrings.discardConfirmMessage,
          confirmLabel: AppStrings.discardConfirmYes,
          cancelLabel: AppStrings.discardConfirmNo,
          isDanger: true,
          onConfirm: () => Navigator.of(ctx).pop(true),
        ),
      );

      if (discard == true && mounted) {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: !_isProfileDirty && !_isPasswordDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleDiscard();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen Header
                const CsScreenHeader(
                  overtitle: AppStrings.overtitleEditProfile,
                  title: AppStrings.editProfileTitle,
                ),
                const SizedBox(height: 20),

                // 1. Personal Info Section
                Text(
                  AppStrings.personalInfoSection,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                  ),
                ),
                const SizedBox(height: 12),
                Form(
                  key: _profileFormKey,
                  child: CsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CsTextField(
                          controller: _fullNameController,
                          labelText: AppStrings.fullNameLabel,
                          hintText: AppStrings.fullNameHint,
                          prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                          validator: Validators.validateFullName,
                        ),
                        const SizedBox(height: 16),
                        CsTextField(
                          controller: _emailController,
                          labelText: AppStrings.emailLabel,
                          hintText: AppStrings.emailHint,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          validator: Validators.validateEmail,
                        ),
                        const SizedBox(height: 16),
                        // Role selection
                        Text(
                          AppStrings.roleLabel,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                              _buildRoleOption(
                                label: AppStrings.roleCamper,
                                roleValue: 'camper',
                                icon: Icons.backpack_outlined,
                              ),
                              _buildRoleOption(
                                label: AppStrings.roleOrganizer,
                                roleValue: 'organizer',
                                icon: Icons.map_outlined,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CsDropdown<String>(
                          labelText: AppStrings.experienceLevelLabel,
                          value: _experienceLevel,
                          prefixIcon: const Icon(Icons.military_tech_outlined, size: 20),
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
                              setState(() {
                                _experienceLevel = val;
                                _checkProfileDirty();
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        Divider(
                          color: isDark
                              ? AppColors.darkCardBorder
                              : AppColors.lightCardBorder,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppStrings.emergencyContactSection,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CsTextField(
                          controller: _emergencyNameController,
                          labelText: AppStrings.emergencyContactNameLabel,
                          hintText: AppStrings.emergencyContactNameHint,
                          prefixIcon: const Icon(Icons.person_add_outlined, size: 20),
                        ),
                        const SizedBox(height: 14),
                        CsTextField(
                          controller: _emergencyPhoneController,
                          labelText: AppStrings.emergencyContactPhoneLabel,
                          hintText: AppStrings.emergencyContactPhoneHint,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                          validator: Validators.validatePhone,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Save Profile Button
                CsButtonPrimary(
                  label: AppStrings.saveChangesButton,
                  icon: Icons.save_outlined,
                  isLoading: _isSavingProfile,
                  onPressed: _isProfileDirty ? _handleSaveProfile : null,
                ),
                const SizedBox(height: 28),

                // 2. Change Password Section
                Text(
                  AppStrings.changePasswordSection,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTitle : AppColors.lightTitle,
                  ),
                ),
                const SizedBox(height: 12),
                Form(
                  key: _passwordFormKey,
                  child: CsCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CsTextField(
                          controller: _currentPasswordController,
                          labelText: AppStrings.currentPasswordLabel,
                          hintText: AppStrings.currentPasswordHint,
                          obscureText: _obscureCurrent,
                          prefixIcon: const Icon(Icons.lock_clock_outlined, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrent
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscureCurrent = !_obscureCurrent),
                          ),
                          validator: (v) => (_isPasswordDirty &&
                                  (v == null || v.isEmpty))
                              ? AppStrings.errFieldRequired
                              : null,
                        ),
                        const SizedBox(height: 14),
                        CsTextField(
                          controller: _newPasswordController,
                          labelText: AppStrings.newPasswordLabel,
                          hintText: AppStrings.newPasswordHint,
                          obscureText: _obscureNew,
                          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                          validator: (v) => _isPasswordDirty
                              ? Validators.validatePassword(v)
                              : null,
                        ),
                        const SizedBox(height: 14),
                        CsTextField(
                          controller: _confirmPasswordController,
                          labelText: AppStrings.confirmPasswordLabel,
                          hintText: AppStrings.confirmPasswordHint,
                          obscureText: _obscureConfirm,
                          prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
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
                          validator: (v) => _isPasswordDirty
                              ? Validators.validateConfirmPassword(
                                  v,
                                  _newPasswordController.text,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CsButtonPrimary(
                  label: 'Mettre à jour le mot de passe',
                  icon: Icons.key_outlined,
                  isLoading: _isChangingPassword,
                  onPressed: _isPasswordDirty ? _handleChangePassword : null,
                ),
                const SizedBox(height: 20),

                // Discard Button
                CsButtonSecondary(
                  label: AppStrings.discardChangesButton,
                  icon: Icons.close_rounded,
                  onPressed: _handleDiscard,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String label,
    required String roleValue,
    required IconData icon,
  }) {
    final isSelected = _role == roleValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _role = roleValue;
            _checkProfileDirty();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? (isDark ? AppColors.darkPrimaryText : Colors.white)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimaryText : Colors.white)
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
