import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/cs_button_primary.dart';
import '../../../core/widgets/cs_card.dart';
import '../../../core/widgets/cs_dropdown.dart';
import '../../../core/widgets/cs_screen_header.dart';
import '../../../core/widgets/cs_text_field.dart';
import '../providers/auth_provider.dart';

/// Registration screen with segmented role selector, experience dropdown,
/// password strength indicator, emergency contact inputs, and terms checkbox.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();
  final _emergencyNameFocus = FocusNode();
  final _emergencyPhoneFocus = FocusNode();

  String _role = 'camper'; // 'camper' | 'organizer'
  String _experienceLevel = 'intermediate'; // 'beginner' | 'intermediate' | 'advanced'
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _termsError = false;

  PasswordStrength _passwordStrength = PasswordStrength.weak;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength =
          Validators.evaluatePasswordStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordStrength);
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    _emergencyNameFocus.dispose();
    _emergencyPhoneFocus.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _termsError = !_acceptedTerms;
    });

    if (!_formKey.currentState!.validate() || !_acceptedTerms) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      role: _role,
      experienceLevel: _experienceLevel,
      emergencyContactName: _emergencyNameController.text,
      emergencyContactPhone: _emergencyPhoneController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil('/shell', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLoading = authProvider.status == AuthStatus.authenticating;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CsScreenHeader(
                  overtitle: AppStrings.overtitleAccount,
                  title: AppStrings.registerTitle,
                ),
                const SizedBox(height: 16),

                // Error Banner
                if (authProvider.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkDangerTile
                          : AppColors.lightDangerTile,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: isDark ? AppColors.darkDanger : AppColors.lightDanger,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            authProvider.errorMessage!,
                            style: GoogleFonts.inter(
                              color: isDark
                                  ? AppColors.darkDanger
                                  : AppColors.lightDanger,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Role Segmented Selector
                Text(
                  AppStrings.roleLabel,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
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
                const SizedBox(height: 20),

                // Main Info Card
                CsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CsTextField(
                        controller: _fullNameController,
                        labelText: AppStrings.fullNameLabel,
                        hintText: AppStrings.fullNameHint,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                        validator: Validators.validateFullName,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailFocus),
                      ),
                      const SizedBox(height: 16),
                      CsTextField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        labelText: AppStrings.emailLabel,
                        hintText: AppStrings.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        validator: Validators.validateEmail,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocus),
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
                            setState(() => _experienceLevel = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Password Card
                CsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CsTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        labelText: AppStrings.passwordLabel,
                        hintText: AppStrings.passwordHint,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: Validators.validatePassword,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_confirmFocus),
                      ),
                      const SizedBox(height: 10),

                      // Password strength indicator
                      _buildStrengthIndicator(),
                      const SizedBox(height: 16),

                      CsTextField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmFocus,
                        labelText: AppStrings.confirmPasswordLabel,
                        hintText: AppStrings.confirmPasswordHint,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.lock_reset_rounded, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        validator: (v) => Validators.validateConfirmPassword(
                          v,
                          _passwordController.text,
                        ),
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_emergencyNameFocus),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Optional Emergency Contact Card
                CsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.emergencyContactSection,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      CsTextField(
                        controller: _emergencyNameController,
                        focusNode: _emergencyNameFocus,
                        labelText: AppStrings.emergencyContactNameLabel,
                        hintText: AppStrings.emergencyContactNameHint,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.person_add_outlined, size: 20),
                        onFieldSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_emergencyPhoneFocus),
                      ),
                      const SizedBox(height: 16),
                      CsTextField(
                        controller: _emergencyPhoneController,
                        focusNode: _emergencyPhoneFocus,
                        labelText: AppStrings.emergencyContactPhoneLabel,
                        hintText: AppStrings.emergencyContactPhoneHint,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                        validator: Validators.validatePhone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Terms Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      activeColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      onChanged: (val) {
                        setState(() {
                          _acceptedTerms = val ?? false;
                          if (_acceptedTerms) _termsError = false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptedTerms = !_acceptedTerms;
                            if (_acceptedTerms) _termsError = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            AppStrings.termsAcceptance,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_termsError) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Text(
                      AppStrings.termsRequiredError,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.lightDanger,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Register Button
                CsButtonPrimary(
                  label: AppStrings.registerButton,
                  isLoading: isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),

                // Switch to Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.alreadyAccountPrompt,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          AppStrings.loginLink,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
        onTap: () => setState(() => _role = roleValue),
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

  Widget _buildStrengthIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    String label;
    double progress;

    switch (_passwordStrength) {
      case PasswordStrength.strong:
        color = const Color(0xFF2E7D32);
        label = AppStrings.passwordStrengthStrong;
        progress = 1.0;
        break;
      case PasswordStrength.medium:
        color = const Color(0xFFF57C00);
        label = AppStrings.passwordStrengthMedium;
        progress = 0.66;
        break;
      case PasswordStrength.weak:
        color = AppColors.lightDanger;
        label = AppStrings.passwordStrengthWeak;
        progress = 0.33;
        break;
    }

    if (_passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? AppColors.darkTile : AppColors.lightTile,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}
