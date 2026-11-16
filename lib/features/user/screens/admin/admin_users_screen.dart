import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cs_card.dart';
import '../../../../core/widgets/cs_chip.dart';
import '../../../../core/widgets/cs_icon_tile.dart';
import '../../../../core/widgets/cs_screen_header.dart';
import '../../../../core/widgets/cs_text_field.dart';
import '../../models/user.dart';
import '../../providers/admin_users_provider.dart';
import 'admin_user_detail_screen.dart';
import 'admin_user_form_screen.dart';

/// Administrator tab "Utilisateurs":
/// - Camper & Organizer counter metric cards
/// - Live search field with short debounce
/// - Role filter chips (Tous / Campeurs / Organisateurs)
/// - Alphabetical user list with initials badge and role chip
/// - "Créer un compte" button
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().loadUsers();
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        context.read<AdminUsersProvider>().setSearchQuery(query);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateUser() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const AdminUserFormScreen(
          mode: AdminUserFormMode.create,
        ),
      ),
    );
    if (created == true && mounted) {
      context.read<AdminUsersProvider>().loadUsers();
    }
  }

  Future<void> _openUserDetail(User user) async {
    final refreshed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminUserDetailScreen(user: user),
      ),
    );
    if (refreshed == true && mounted) {
      context.read<AdminUsersProvider>().loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUsersProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final users = provider.users;
    final isLoading = provider.isLoading;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => provider.loadUsers(),
          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          child: CustomScrollView(
            slivers: [
              // Sticky / Top Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    CsScreenHeader(
                      overtitle: AppStrings.overtitleAdmin,
                      title: AppStrings.adminUsersTitle,
                      trailing: ElevatedButton.icon(
                        onPressed: _openCreateUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                          foregroundColor: isDark
                              ? AppColors.darkPrimaryText
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: Text(
                          AppStrings.createAccountAdminButton,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1. Counter metric cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            label: AppStrings.countCampers,
                            count: provider.camperCount,
                            icon: Icons.hiking_rounded,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            label: AppStrings.countOrganizers,
                            count: provider.organizerCount,
                            icon: Icons.supervisor_account_rounded,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 2. Search Input
                    CsTextField(
                      controller: _searchController,
                      hint: AppStrings.searchUsersHint,
                      prefixIcon: Icons.search_rounded,
                      onChanged: _onSearchChanged,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                provider.clearSearch();
                              },
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // 3. Role Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          CsChip(
                            label: AppStrings.filterAll,
                            isSelected: provider.selectedRole == 'all',
                            onTap: () => provider.setRoleFilter('all'),
                          ),
                          const SizedBox(width: 8),
                          CsChip(
                            label: AppStrings.filterCampers,
                            isSelected: provider.selectedRole == 'camper',
                            icon: Icons.hiking_rounded,
                            onTap: () => provider.setRoleFilter('camper'),
                          ),
                          const SizedBox(width: 8),
                          CsChip(
                            label: AppStrings.filterOrganizers,
                            isSelected: provider.selectedRole == 'organizer',
                            icon: Icons.supervisor_account_rounded,
                            onTap: () => provider.setRoleFilter('organizer'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),

              // Loading Indicator
              if (isLoading && users.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              // Empty State
              else if (users.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CsIconTile(
                            icon: Icons.person_search_rounded,
                            size: 64,
                            iconSize: 32,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.noUsersFound,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              // User List Items
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final user = users[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildUserTile(
                            context: context,
                            user: user,
                            isDark: isDark,
                          ),
                        );
                      },
                      childCount: users.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required int count,
    required IconData icon,
    required bool isDark,
  }) {
    return CsCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CsIconTile(
            icon: icon,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTitle,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile({
    required BuildContext context,
    required User user,
    required bool isDark,
  }) {
    final avatarBg = isDark ? AppColors.darkTile : AppColors.lightTile;
    final avatarFg = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return CsCard(
      onTap: () => _openUserDetail(user),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Avatar with initials
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: avatarBg,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              user.initials,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: avatarFg,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTitle,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Role chip & Chevron
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CsChip(
                label: user.roleLabelFr,
                isSelected: user.role == 'organizer',
              ),
              const SizedBox(height: 4),
              Text(
                user.experienceLevelLabelFr,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
