import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/cs_card.dart';
import '../../../../core/widgets/cs_chip.dart';
import '../../../../core/widgets/cs_icon_tile.dart';
import '../../../../core/widgets/cs_screen_header.dart';
import 'admin_report_detail_screen.dart';

/// Graphical mockup screen for Reports administration.
///
/// ============================================================================
/// NOTE: Données de démonstration, à remplacer par les vrais signalements
/// lors de l'intégration des modules métier.
/// Aucune persistance ni backend n'est requis pour cet écran.
/// ============================================================================
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedFilter = 'all'; // 'all' | 'open' | 'in_progress' | 'resolved'

  // Données de démonstration, à remplacer par les vrais signalements lors de l'intégration
  final List<Map<String, dynamic>> _demoReports = [
    {
      'id': 1,
      'title': 'Annonce « Tente Dôme 2 places »',
      'targetType': 'Matériel (Marketplace)',
      'author': 'Azza Drissi',
      'reason': 'Arnaque potentielle',
      'description':
          'Le vendeur demande un paiement par virement externe avant expédition.',
      'date': '28 oct. 2026',
      'status': 'open',
      'icon': Icons.backpack_rounded,
    },
    {
      'id': 2,
      'title': 'Trajet Grenoble → Arolles',
      'targetType': 'Trajets (Covoiturage)',
      'author': 'Marc Lefevre',
      'reason': 'Information incorrecte',
      'description':
          'Le point de rendez-vous indiqué est inaccessible en raison d’un éboulement.',
      'date': '26 oct. 2026',
      'status': 'in_progress',
      'icon': Icons.directions_car_rounded,
    },
    {
      'id': 3,
      'title': 'Utilisateur Noé Bernard',
      'targetType': 'Profil Utilisateur',
      'author': 'Sophie Durand',
      'reason': 'Contenu inapproprié',
      'description':
          'Commentaires agressifs répétés dans la section d’organisation de la sortie.',
      'date': '25 oct. 2026',
      'status': 'open',
      'icon': Icons.person_rounded,
    },
    {
      'id': 4,
      'title': 'Bivouac Lac Blanc',
      'targetType': 'Camp (Lieu)',
      'author': 'Julien Petit',
      'reason': 'Non-respect de la réglementation',
      'description':
          'Feu de camp allumé dans une zone naturelle strictement protégée.',
      'date': '20 oct. 2026',
      'status': 'resolved',
      'icon': Icons.cabin_rounded,
    },
    {
      'id': 5,
      'title': 'Guide « Allumage par friction »',
      'targetType': 'Guides (Tutoriel)',
      'author': 'Claire Thomas',
      'reason': 'Consignes de sécurité absentes',
      'description':
          'Absence d’avertissement sur les risques d’incendie par vent fort.',
      'date': '18 oct. 2026',
      'status': 'open',
      'icon': Icons.menu_book_rounded,
    },
    {
      'id': 6,
      'title': 'Sortie Randonnée Belledonne',
      'targetType': 'Sorties (Événement)',
      'author': 'Karim Benzema',
      'reason': 'Annulation sans préavis',
      'description':
          'Organisateur injoignable au départ du refuge, 6 personnes bloquées.',
      'date': '12 oct. 2026',
      'status': 'resolved',
      'icon': Icons.explore_rounded,
    },
  ];

  int get _openCount =>
      _demoReports.where((r) => r['status'] == 'open').length;
  int get _inProgressCount =>
      _demoReports.where((r) => r['status'] == 'in_progress').length;
  int get _resolvedCount =>
      _demoReports.where((r) => r['status'] == 'resolved').length;

  List<Map<String, dynamic>> get _filteredReports {
    if (_selectedFilter == 'all') return _demoReports;
    return _demoReports.where((r) => r['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reports = _filteredReports;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CsScreenHeader(
                overtitle: AppStrings.overtitleAdmin,
                title: AppStrings.adminReportsTitle,
              ),
              const SizedBox(height: 16),

              // 1. Preview Banner Notice
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTile.withValues(alpha: 0.5)
                      : AppColors.lightTile,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkCardBorder
                        : AppColors.lightCardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppStrings.reportsBannerNotice,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Metric Counters (Ouverts, En cours, Résolus)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      label: AppStrings.reportsCountOpen,
                      count: _openCount,
                      variant: CsTileVariant.amber,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricItem(
                      label: AppStrings.reportsCountInProgress,
                      count: _inProgressCount,
                      variant: CsTileVariant.standard,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricItem(
                      label: AppStrings.reportsCountResolved,
                      count: _resolvedCount,
                      variant: CsTileVariant.standard,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CsChip(
                      label: AppStrings.filterReportsAll,
                      isSelected: _selectedFilter == 'all',
                      onTap: () => setState(() => _selectedFilter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    CsChip(
                      label: AppStrings.filterReportsOpen,
                      isSelected: _selectedFilter == 'open',
                      onTap: () => setState(() => _selectedFilter = 'open'),
                    ),
                    const SizedBox(width: 8),
                    CsChip(
                      label: AppStrings.filterReportsInProgress,
                      isSelected: _selectedFilter == 'in_progress',
                      onTap: () =>
                          setState(() => _selectedFilter = 'in_progress'),
                    ),
                    const SizedBox(width: 8),
                    CsChip(
                      label: AppStrings.filterReportsResolved,
                      isSelected: _selectedFilter == 'resolved',
                      onTap: () =>
                          setState(() => _selectedFilter = 'resolved'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Reports List or Empty State
              if (reports.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const CsIconTile(
                          icon: Icons.check_circle_outline_rounded,
                          size: 64,
                          iconSize: 32,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.noReportsFound,
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
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildReportTile(report, isDark);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required int count,
    required CsTileVariant variant,
    required bool isDark,
  }) {
    return CsCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Column(
        children: [
          Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTitle,
            ),
          ),
          const SizedBox(height: 2),
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
    );
  }

  Widget _buildReportTile(Map<String, dynamic> report, bool isDark) {
    Color statusBg;
    Color statusFg;
    String statusLabel;

    switch (report['status']) {
      case 'open':
        statusBg = isDark
            ? AppColors.darkAmberBackground
            : AppColors.lightAmberBackground;
        statusFg =
            isDark ? AppColors.darkAmberText : AppColors.lightAmberText;
        statusLabel = AppStrings.reportsCountOpen;
        break;
      case 'in_progress':
        statusBg = isDark ? AppColors.darkTile : AppColors.lightTile;
        statusFg = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
        statusLabel = AppStrings.reportsCountInProgress;
        break;
      case 'resolved':
      default:
        statusBg = isDark
            ? AppColors.darkPrimary.withValues(alpha: 0.2)
            : AppColors.lightPrimary.withValues(alpha: 0.15);
        statusFg = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
        statusLabel = AppStrings.reportsCountResolved;
        break;
    }

    return CsCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AdminReportDetailScreen(report: report),
          ),
        );
      },
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CsIconTile(
            icon: report['icon'] as IconData? ?? Icons.flag_rounded,
            size: 42,
            iconSize: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['title'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTitle,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${report['reason']} · ${report['date']}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusFg,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.chevron_right_rounded,
            size: 18,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ],
      ),
    );
  }
}
