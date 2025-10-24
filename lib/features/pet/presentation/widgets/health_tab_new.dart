import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/pet_entity.dart';
import '../providers/pet_providers.dart';
import '../pages/health_history_page.dart';
import 'health_sheets/vaccination_status_sheet.dart';
import 'health_sheets/sterilization_status_sheet.dart';
import 'health_sheets/overall_health_check_sheet.dart';
import 'weight_input_sheet.dart';

class HealthTabNew extends ConsumerWidget {
  final PetEntity pet;

  const HealthTabNew({super.key, required this.pet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(petHealthProvider(pet.id));

    return healthAsync.when(
      data: (health) {
        if (health == null) {
          return const EmptyState(
            icon: Icons.health_and_safety,
            title: 'Belum Ada Data Kesehatan',
            message:
                'Tap tombol di bawah untuk mulai menambahkan data kesehatan',
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          children: [
            // Health Score Badge
            _buildHealthScoreCard(health.healthScore, health.lastScoredAt),

            const SizedBox(height: AppDimensions.spaceMd),

            // Quick Action Buttons
            _buildQuickActionsSection(context, ref),

            const SizedBox(height: AppDimensions.spaceMd),

            // Current Health Status
            _buildHealthStatusSection(health),

            const SizedBox(height: AppDimensions.spaceMd),

            // View History Button
            _buildHistoryButton(context),
          ],
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.refresh(petHealthProvider(pet.id)),
      ),
    );
  }

  Widget _buildHealthScoreCard(String healthScore, DateTime? lastScoredAt) {
    final isHealthy = healthScore == 'healthy';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHealthy
              ? [
                  AppColors.success.withValues(alpha: 0.1),
                  AppColors.success.withValues(alpha: 0.05),
                ]
              : [
                  AppColors.warning.withValues(alpha: 0.1),
                  AppColors.warning.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isHealthy ? AppColors.success : AppColors.warning,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isHealthy ? Icons.check_circle : Icons.warning,
            size: 48,
            color: isHealthy ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(height: 12),
          Text(
            isHealthy ? '✅ Sehat' : '⚠️ Perlu Perhatian',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isHealthy ? AppColors.success : AppColors.warning,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isHealthy
                ? 'Semua parameter kesehatan baik'
                : 'Ada parameter kesehatan yang perlu ditangani',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (lastScoredAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Terakhir diupdate: ${DateFormat('dd MMM yyyy, HH:mm').format(lastScoredAt)}',
              style: GoogleFonts.nunito(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              context,
              ref,
              icon: LucideIcons.weight,
              label: 'Berat Badan',
              color: AppColors.secondary,
              onTap: () => _showWeightSheet(context, ref),
            ),
            _buildQuickActionCard(
              context,
              ref,
              icon: LucideIcons.syringe,
              label: 'Vaksinasi',
              color: const Color(0xFF3B82F6),
              onTap: () => _showVaccinationSheet(context, ref),
            ),
            _buildQuickActionCard(
              context,
              ref,
              icon: LucideIcons.shield,
              label: 'Sterilisasi',
              color: AppColors.success,
              onTap: () => _showSterilizationSheet(context, ref),
            ),
            _buildQuickActionCard(
              context,
              ref,
              icon: LucideIcons.circleCheck,
              label: 'Overall Check',
              color: AppColors.warning,
              onTap: () => _showOverallHealthCheckSheet(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthStatusSection(health) {
    final params = health.healthParameters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Kesehatan Saat Ini',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Weight
        if (health.weight != null)
          _buildStatusCard(
            icon: LucideIcons.weight,
            label: 'Berat Badan',
            value: '${health.weight} kg',
            color: AppColors.secondary,
          ),

        // Vaccination
        _buildStatusCard(
          icon: LucideIcons.syringe,
          label: 'Vaksinasi',
          value: params['is_vaccinated'] == true ? 'Sudah ✓' : 'Belum',
          color: const Color(0xFF3B82F6),
          subtitle: params['vaccination_date'] != null
              ? DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(params['vaccination_date']))
              : null,
        ),

        // Sterilization
        _buildStatusCard(
          icon: LucideIcons.shield,
          label: 'Sterilisasi',
          value: params['is_sterilized'] == true ? 'Sudah ✓' : 'Belum',
          color: AppColors.success,
          subtitle: params['sterilization_date'] != null
              ? DateFormat(
                  'dd MMM yyyy',
                ).format(DateTime.parse(params['sterilization_date']))
              : null,
        ),

        // Parasites
        _buildStatusCard(
          icon: LucideIcons.bug,
          label: 'Parasit',
          value: _getParasiteStatus(params),
          color: _hasAnyParasite(params) ? AppColors.error : AppColors.success,
        ),

        // Stool Quality
        if (params['stool_quality'] != null)
          _buildStatusCard(
            icon: LucideIcons.clipboardCheck,
            label: 'Kualitas Kotoran',
            value: _getStoolQualityLabel(params['stool_quality']),
            color: _getStoolQualityColor(params['stool_quality']),
          ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppDimensions.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HealthHistoryPage(pet: pet),
            ),
          );
        },
        icon: const Icon(LucideIcons.history),
        label: Text(
          'Lihat Riwayat Kesehatan',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // Helper methods
  String _getParasiteStatus(Map<String, dynamic> params) {
    final hasFungus = params['has_fungus'] == true;
    final hasWorms = params['has_worms'] == true;
    final hasFleas = params['has_fleas'] == true;

    if (!hasFungus && !hasWorms && !hasFleas) {
      return 'Tidak Ada ✓';
    }

    final problems = <String>[];
    if (hasFungus) problems.add('Jamur');
    if (hasWorms) problems.add('Cacing');
    if (hasFleas) problems.add('Kutu');

    return problems.join(', ');
  }

  bool _hasAnyParasite(Map<String, dynamic> params) {
    return params['has_fungus'] == true ||
        params['has_worms'] == true ||
        params['has_fleas'] == true;
  }

  String _getStoolQualityLabel(String quality) {
    switch (quality) {
      case 'good':
        return '💚 Bagus';
      case 'normal':
        return '💛 Normal';
      case 'bad':
        return '❤️ Buruk';
      default:
        return quality;
    }
  }

  Color _getStoolQualityColor(String quality) {
    switch (quality) {
      case 'good':
        return AppColors.success;
      case 'normal':
        return AppColors.warning;
      case 'bad':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  // Sheet methods
  void _showWeightSheet(BuildContext context, WidgetRef ref) {
    final health = ref.read(petHealthProvider(pet.id)).value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WeightInputSheet(pet: pet, health: health),
    );
  }

  void _showVaccinationSheet(BuildContext context, WidgetRef ref) {
    final health = ref.read(petHealthProvider(pet.id)).value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VaccinationStatusSheet(pet: pet, health: health),
    );
  }

  void _showSterilizationSheet(BuildContext context, WidgetRef ref) {
    final health = ref.read(petHealthProvider(pet.id)).value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SterilizationStatusSheet(pet: pet, health: health),
    );
  }

  void _showOverallHealthCheckSheet(BuildContext context, WidgetRef ref) {
    final health = ref.read(petHealthProvider(pet.id)).value;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OverallHealthCheckSheet(pet: pet, health: health),
    );
  }
}
