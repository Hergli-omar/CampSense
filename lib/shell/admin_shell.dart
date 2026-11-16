import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/strings.dart';
import '../core/theme/app_colors.dart';
import '../features/user/providers/auth_provider.dart';
import '../features/user/screens/admin/admin_profile_tab.dart';
import '../features/user/screens/admin/admin_reports_screen.dart';
import '../features/user/screens/admin/admin_users_screen.dart';
import 'shell_tab.dart';

/// Navigation shell exclusively reserved for the Administrator.
/// Contains 3 persistent tabs:
/// 1. Utilisateurs (User accounts directory & CRUD)
/// 2. Signalements (Moderation reports preview)
/// 3. Profil (Admin identity, ambient sensor, logout)
///
/// Strictly guards against unauthorized non-admin access.
class AdminShell extends StatefulWidget {
  final int initialIndex;

  const AdminShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  late int _currentIndex;

  late final List<ShellTab> _adminTabs = [
    // 1. Utilisateurs
    const ShellTab(
      label: AppStrings.adminTabUsers,
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
      builder: _buildUsersTab,
    ),

    // 2. Signalements
    const ShellTab(
      label: AppStrings.adminTabReports,
      icon: Icons.flag_outlined,
      selectedIcon: Icons.flag_rounded,
      builder: _buildReportsTab,
    ),

    // 3. Profil
    const ShellTab(
      label: AppStrings.adminTabProfile,
      icon: Icons.shield_outlined,
      selectedIcon: Icons.shield_rounded,
      builder: _buildProfileTab,
    ),
  ];

  static Widget _buildUsersTab(BuildContext context) {
    return const AdminUsersScreen();
  }

  static Widget _buildReportsTab(BuildContext context) {
    return const AdminReportsScreen();
  }

  static Widget _buildProfileTab(BuildContext context) {
    return const AdminProfileTab();
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Role guard: strictly kick out non-admins
    if (user == null || !user.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.unauthorizedAccess),
              backgroundColor: AppColors.lightDanger,
            ),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _adminTabs.map((tab) => tab.builder(context)).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.darkCardBorder
                  : AppColors.lightCardBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_adminTabs.length, (index) {
                final tab = _adminTabs[index];
                final isSelected = index == _currentIndex;

                return _buildNavItem(
                  context: context,
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () => setState(() => _currentIndex = index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required ShellTab tab,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedBg = isDark ? AppColors.darkTile : AppColors.lightTile;
    final selectedFg = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final unselectedFg =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? tab.selectedIcon : tab.icon,
              size: 24,
              color: isSelected ? selectedFg : unselectedFg,
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: GoogleFonts.inter(
                fontSize: 12,
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
