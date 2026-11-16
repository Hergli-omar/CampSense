import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/theme_x.dart';
import '../features/user/providers/auth_provider.dart';
import '../features/user/screens/profile_screen.dart';
import 'module_placeholder_screen.dart';
import 'shell_tab.dart';

/// Coque de navigation principale (AppShell) pour les campeurs et organisateurs.
///
/// Comprend :
/// 1. Une AppBar commune visible sur les 5 modules :
///    - Gauche : Logo montagne + "CampSense"
///    - Droite : Icône Loupe (recherche par module) + Avatar utilisateur cliquable
/// 2. 5 onglets de modules en bas (Sorties, Matériel, Trajets, Guides, Camp)
///    - L'onglet affiché par défaut est "Sorties" (index 0).
/// 3. L'appui sur l'avatar ouvre l'écran Profil existant au-dessus de la coque.
///
/// =========================================================================
/// CHECKLIST D'INTÉGRATION D'UN NOUVEAU MODULE :
/// 1) Remplacer le [builder] de l'onglet correspondant dans [_shellTabs]
///    par l'écran racine du module (ex: `builder: (ctx) => const EventHomeScreen()`).
/// 2) Brancher éventuellement la recherche via [onSearch] et [searchHint].
/// 3) Ajouter ses routes dans `lib/core/routes/app_routes.dart` via `moduleRoutes`.
/// 4) Enregistrer son schéma dans `lib/core/database/app_database.dart`
///    via `registeredSchemas`.
/// =========================================================================
class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  /// Liste des 5 onglets de modules métier.
  /// Onglet par défaut : Sorties (index 0).
  late final List<ShellTab> _shellTabs = [
    // 1. Sorties (Event Module - Capteur associé: Baromètre)
    // >>> POUR INTÉGRER LE MODULE SORTIES : remplacer par `builder: (ctx) => const EventHomeScreen()`
    ShellTab(
      label: CommonStrings.moduleEvents,
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
      builder: (context) => const ModulePlaceholderScreen(
        moduleName: CommonStrings.moduleEvents,
        moduleIcon: Icons.explore_rounded,
        associatedSensor: CommonStrings.sensorBarometer,
        sensorIcon: Icons.speed_rounded,
      ),
    ),

    // 2. Matériel (Marketplace Module - Capteur associé: NFC)
    // >>> POUR INTÉGRER LE MODULE MATÉRIEL : remplacer par `builder: (ctx) => const MarketplaceHomeScreen()`
    ShellTab(
      label: CommonStrings.moduleMarketplace,
      icon: Icons.backpack_outlined,
      selectedIcon: Icons.backpack_rounded,
      builder: (context) => const ModulePlaceholderScreen(
        moduleName: CommonStrings.moduleMarketplace,
        moduleIcon: Icons.backpack_rounded,
        associatedSensor: CommonStrings.sensorNfc,
        sensorIcon: Icons.nfc_rounded,
      ),
    ),

    // 3. Trajets (Transport Module - Capteur associé: GPS)
    // >>> POUR INTÉGRER LE MODULE TRAJETS : remplacer par `builder: (ctx) => const TransportHomeScreen()`
    ShellTab(
      label: CommonStrings.moduleTransport,
      icon: Icons.directions_car_outlined,
      selectedIcon: Icons.directions_car_rounded,
      builder: (context) => const ModulePlaceholderScreen(
        moduleName: CommonStrings.moduleTransport,
        moduleIcon: Icons.directions_car_rounded,
        associatedSensor: CommonStrings.sensorGps,
        sensorIcon: Icons.navigation_rounded,
      ),
    ),

    // 4. Guides (Tutorial Module - Capteur associé: Accéléromètre)
    // >>> POUR INTÉGRER LE MODULE GUIDES : remplacer par `builder: (ctx) => const TutorialHomeScreen()`
    ShellTab(
      label: CommonStrings.moduleTutorial,
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      builder: (context) => const ModulePlaceholderScreen(
        moduleName: CommonStrings.moduleTutorial,
        moduleIcon: Icons.menu_book_rounded,
        associatedSensor: CommonStrings.sensorAccelerometer,
        sensorIcon: Icons.screen_rotation_rounded,
      ),
    ),

    // 5. Camp (Campsite Module - Capteur associé: Magnétomètre)
    // >>> POUR INTÉGRER LE MODULE CAMP : remplacer par `builder: (ctx) => const CampsiteHomeScreen()`
    ShellTab(
      label: CommonStrings.moduleCampsite,
      icon: Icons.cabin_outlined,
      selectedIcon: Icons.cabin_rounded,
      builder: (context) => const ModulePlaceholderScreen(
        moduleName: CommonStrings.moduleCampsite,
        moduleIcon: Icons.cabin_rounded,
        associatedSensor: CommonStrings.sensorMagnetometer,
        sensorIcon: Icons.explore_outlined,
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _handleSearchTap() {
    final currentTab = _shellTabs[_currentIndex];
    if (currentTab.onSearch != null) {
      currentTab.onSearch!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(CommonStrings.searchComingSoon),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    // Role guard: redirect admin to /admin_shell
    if (user != null && user.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/admin_shell');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      // AppBar commune visible sur les 5 modules
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: context.colors.background,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkTile : AppColors.lightTile,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.terrain_rounded,
                size: 20,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              CommonStrings.appName,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          // 1. Bouton Loupe (Recherche)
          IconButton(
            icon: const Icon(Icons.search_rounded),
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            tooltip: CommonStrings.search,
            onPressed: _handleSearchTap,
          ),
          const SizedBox(width: 4),

          // 2. Avatar utilisateur cliquable
          InkWell(
            onTap: _openProfile,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkTile : AppColors.lightTile,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                user?.initials ?? 'CS',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      // IndexedStack preserves state across all 5 tabs
      body: IndexedStack(
        index: _currentIndex,
        children: _shellTabs.map((tab) => tab.builder(context)).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_shellTabs.length, (index) {
                final tab = _shellTabs[index];
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? tab.selectedIcon : tab.icon,
              size: 22,
              color: isSelected ? selectedFg : unselectedFg,
            ),
            const SizedBox(height: 3),
            Text(
              tab.label,
              style: GoogleFonts.inter(
                fontSize: 11,
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
