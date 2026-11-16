import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_format_fr.dart';
import '../../../core/widgets/cs_button_primary.dart';
import '../../../core/widgets/cs_button_secondary.dart';
import '../../../core/widgets/cs_card.dart';
import '../../../core/widgets/cs_confirm_dialog.dart';
import '../../../core/widgets/cs_icon_tile.dart';
import '../../../core/widgets/cs_screen_header.dart';
import '../../../core/widgets/cs_text_field.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/ambient_light_card.dart';
import '../widgets/emergency_contact_card.dart';
import '../widgets/stay_tile.dart';

/// Profile screen displaying identity, emergency contact, stays history,
/// ambient light settings, and account management actions.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.currentUser?.id != null) {
        context.read<UserProvider>().loadStays(auth.currentUser!.id!);
      }
    });
  }

  @override
  void deactivate() {
    // Automatically re-mask emergency contact phone when leaving this screen
    context.read<UserProvider>().hideEmergencyPhone();
    super.deactivate();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => CsConfirmDialog(
        icon: Icons.logout_rounded,
        title: AppStrings.logoutConfirmTitle,
        message: AppStrings.logoutConfirmMessage,
        confirmLabel: AppStrings.logoutButton,
        cancelLabel: AppStrings.cancelButton,
        onConfirm: () => Navigator.of(ctx).pop(true),
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
      }
    }
  }

  Future<void> _handleDeleteAccount(User user, int staysCount) async {
    final passwordController = TextEditingController();
    var hasError = false;

    await showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => CsConfirmDialog(
          icon: Icons.delete_forever_rounded,
          tileVariant: CsTileVariant.danger,
          title: AppStrings.deleteAccountDialogTitle,
          message: AppStrings.deleteAccountDialogBody(user.fullName, staysCount),
          confirmLabel: AppStrings.deleteAccountConfirmButton,
          cancelLabel: AppStrings.deleteAccountCancelButton,
          isDanger: true,
          extraContent: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CsTextField(
                controller: passwordController,
                labelText: AppStrings.passwordLabel,
                hintText: AppStrings.passwordHint,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _confirmDelete(
                  dialogCtx,
                  passwordController.text,
                  setDialogState,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          onConfirm: () => _confirmDelete(
            dialogCtx,
            passwordController.text,
            setDialogState,
            (err) => hasError = err,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext dialogCtx,
    String password,
    void Function(void Function()) setDialogState,
    void Function(bool) setHasError,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final isValid = await authProvider.verifyCurrentPassword(password);
    if (!isValid) {
      setDialogState(() {
        setHasError(true);
      });
      return;
    }

    if (dialogCtx.mounted) {
      Navigator.of(dialogCtx).pop();
    }

    await authProvider.deleteAccount();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.deleteAccountSuccessNotice),
          backgroundColor: AppColors.lightDanger,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    }
  }

  void _showAddStayDialog(int userId) {
    final placeController = TextEditingController();
    final startController = TextEditingController(text: '2027-07-10');
    final endController = TextEditingController(text: '2027-07-14');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          AppStrings.addStayDialogTitle,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CsTextField(
                controller: placeController,
                labelText: AppStrings.stayPlaceLabel,
                hintText: AppStrings.stayPlaceHint,
              ),
              const SizedBox(height: 12),
              CsTextField(
                controller: startController,
                labelText: AppStrings.stayStartDateLabel,
                hintText: 'AAAA-MM-JJ',
              ),
              const SizedBox(height: 12),
              CsTextField(
                controller: endController,
                labelText: AppStrings.stayEndDateLabel,
                hintText: 'AAAA-MM-JJ',
              ),
              const SizedBox(height: 12),
              CsTextField(
                controller: notesController,
                labelText: AppStrings.stayNotesLabel,
                hintText: AppStrings.stayNotesHint,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancelButton),
          ),
          ElevatedButton(
            onPressed: () async {
              if (placeController.text.trim().isEmpty) return;
              await context.read<UserProvider>().addStay(
                    userId: userId,
                    placeName: placeController.text.trim(),
                    startDate: '${startController.text.trim()}T00:00:00.000',
                    endDate: '${endController.text.trim()}T23:59:59.000',
                    notes: notesController.text.trim(),
                  );
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text(AppStrings.saveStayButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final userProvider = context.watch<UserProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final stays = userProvider.stays;
    final memberSince = DateFormatFr.parseIso(user.createdAt);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header with back button if opened as a pushed route
              CsScreenHeader(
                overtitle: AppStrings.overtitleProfile,
                title: AppStrings.profileTitle,
                trailing: Navigator.of(context).canPop()
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: CommonStrings.back,
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    : null,
              ),
              const SizedBox(height: 20),

              // 1. Identity Card
              CsCard(
                child: Row(
                  children: [
                    // Avatar circle with initials
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkTile : AppColors.lightTile,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkCardBorder
                              : AppColors.lightCardBorder,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user.initials,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTitle
                                  : AppColors.lightTitle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${user.roleLabelFr} · ${user.experienceLevelLabelFr}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.lightAccent,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month_outlined,
                                size: 14,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${AppStrings.registeredSince} ${DateFormatFr.formatMemberSince(memberSince)}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 2. Emergency Contact Card
              EmergencyContactCard(user: user),
              const SizedBox(height: 18),

              // 3. Stays History (Temporary until Event module integration)
              CsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.overtitleStays,
                                style: AppTheme.overtitleStyle.copyWith(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppStrings.staysHistoryTitle,
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTitle
                                      : AppColors.lightTitle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (kDebugMode && user.id != null)
                          IconButton(
                            tooltip: AppStrings.addStayDemoButton,
                            icon: Icon(
                              Icons.add_circle_outline_rounded,
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                            ),
                            onPressed: () => _showAddStayDialog(user.id!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.staysHistorySubtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (userProvider.isLoadingStays)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (stays.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          AppStrings.noStaysYet,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: stays.length,
                        itemBuilder: (context, index) {
                          final stay = stays[index];
                          return StayTile(
                            stay: stay,
                            onDelete: kDebugMode
                                ? () async {
                                    if (stay.id != null) {
                                      await userProvider.deleteStay(stay.id!);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                AppStrings.stayDeletedNotice),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                : null,
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 4. Appearance & Ambient Light Sensor Card
              const AmbientLightCard(),
              const SizedBox(height: 24),

              // 5. Actions: Edit Profile, Logout, Delete Account
              CsButtonPrimary(
                label: AppStrings.editProfileTitle,
                icon: Icons.edit_outlined,
                onPressed: () =>
                    Navigator.of(context).pushNamed('/edit_profile'),
              ),
              const SizedBox(height: 12),
              CsButtonSecondary(
                label: AppStrings.logoutButton,
                icon: Icons.logout_rounded,
                onPressed: _handleLogout,
              ),
              const SizedBox(height: 24),

              // Danger Zone Card
              CsCard(
                backgroundColor: isDark
                    ? AppColors.darkDangerTile.withAlpha(80)
                    : AppColors.lightDangerTile.withAlpha(120),
                borderColor: isDark
                    ? AppColors.darkDanger.withAlpha(100)
                    : AppColors.lightDanger.withAlpha(100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CsIconTile(
                          icon: Icons.warning_rounded,
                          variant: CsTileVariant.danger,
                          size: 38,
                          iconSize: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppStrings.deleteAccountDangerZone,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkDanger
                                : AppColors.lightDanger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "La suppression de votre compte efface définitivement toutes vos données locales.",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CsButtonPrimary(
                      label: AppStrings.deleteAccountButton,
                      isDanger: true,
                      icon: Icons.delete_forever_rounded,
                      onPressed: () =>
                          _handleDeleteAccount(user, stays.length),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
