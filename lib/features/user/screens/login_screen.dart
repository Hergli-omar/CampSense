import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/cs_button_primary.dart';
import '../../../core/widgets/cs_card.dart';
import '../../../core/widgets/cs_screen_header.dart';
import '../../../core/widgets/cs_text_field.dart';
import '../providers/auth_provider.dart';

/// Login screen with email and password, 5-attempt 30s lockout countdown,
/// and smooth transitions.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.status == AuthStatus.locked) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final user = authProvider.currentUser;
      final target = user != null && user.isAdmin ? '/admin_shell' : '/shell';
      Navigator.of(context).pushNamedAndRemoveUntil(target, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLocked = authProvider.status == AuthStatus.locked;
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
                  title: AppStrings.loginTitle,
                ),
                const SizedBox(height: 20),
                const CsHeroBanner(height: 120),
                const SizedBox(height: 24),

                // Lockout Banner
                if (isLocked) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkDangerTile
                          : AppColors.lightDangerTile,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.darkDanger : AppColors.lightDanger,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_clock_rounded,
                          color: isDark ? AppColors.darkDanger : AppColors.lightDanger,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.accountLockedMessage,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.darkDanger
                                      : AppColors.lightDanger,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Compte à rebours : ${authProvider.lockoutSeconds ?? 0} seconde(s)',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkDanger
                                      : AppColors.lightDanger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Generic Error Banner
                if (authProvider.errorMessage != null && !isLocked) ...[
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
                  const SizedBox(height: 20),
                ],

                // Credentials Card
                CsCard(
                  child: Column(
                    children: [
                      CsTextField(
                        controller: _emailController,
                        labelText: AppStrings.emailLabel,
                        hintText: AppStrings.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                        validator: Validators.validateEmail,
                        enabled: !isLocked && !isLoading,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_passwordFocus),
                      ),
                      const SizedBox(height: 18),
                      CsTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        labelText: AppStrings.passwordLabel,
                        hintText: AppStrings.passwordHint,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
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
                        validator: (v) => (v == null || v.isEmpty)
                            ? AppStrings.errFieldRequired
                            : null,
                        enabled: !isLocked && !isLoading,
                        onFieldSubmitted: (_) => _handleLogin(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                CsButtonPrimary(
                  label: AppStrings.loginButton,
                  isLoading: isLoading,
                  onPressed: isLocked ? null : _handleLogin,
                ),
                const SizedBox(height: 20),

                // Switch to Register Link — Wrap allows text to wrap on
                // small screens so it never overflows horizontally.
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      AppStrings.noAccountPrompt,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/register'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.createAccountLink,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
