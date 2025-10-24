import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/entities/pet_health_history_entity.dart';
import '../providers/pet_providers.dart';

class HealthHistoryPage extends ConsumerStatefulWidget {
  final PetEntity pet;

  const HealthHistoryPage({super.key, required this.pet});

  @override
  ConsumerState<HealthHistoryPage> createState() => _HealthHistoryPageState();
}

class _HealthHistoryPageState extends ConsumerState<HealthHistoryPage> {
  String? _selectedFilter;

  final Map<String, Map<String, dynamic>> _filterOptions = {
    'all': {'label': 'Semua', 'icon': LucideIcons.list},
    'is_vaccinated': {'label': 'Vaksinasi', 'icon': LucideIcons.syringe},
    'is_sterilized': {'label': 'Sterilisasi', 'icon': LucideIcons.shield},
    'has_fungus': {'label': 'Jamur', 'icon': LucideIcons.circleAlert},
    'has_worms': {'label': 'Cacing', 'icon': LucideIcons.triangleAlert},
    'has_fleas': {'label': 'Kutu', 'icon': LucideIcons.bug},
    'stool_quality': {
      'label': 'Kualitas Kotoran',
      'icon': LucideIcons.clipboardCheck,
    },
  };

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(healthHistoryProvider(widget.pet.id));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Riwayat Kesehatan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Pet Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingMd),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.grey, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: widget.pet.pictureUrl != null
                      ? NetworkImage(widget.pet.pictureUrl!)
                      : null,
                  child: widget.pet.pictureUrl == null
                      ? const Icon(
                          LucideIcons.pawPrint,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pet.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Riwayat perubahan data kesehatan',
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
          ),

          // Filter Chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMd,
              vertical: AppDimensions.paddingSm,
            ),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(color: AppColors.grey, width: 0.5),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.entries.map((entry) {
                  final isSelected =
                      _selectedFilter == entry.key ||
                      (_selectedFilter == null && entry.key == 'all');
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: isSelected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            entry.value['icon'] as IconData,
                            size: 16,
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(entry.value['label'] as String),
                        ],
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected && entry.key != 'all'
                              ? entry.key
                              : null;
                        });
                      },
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.grey.withValues(alpha: 0.1),
                      labelStyle: GoogleFonts.nunito(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // History List
          Expanded(
            child: historyAsync.when(
              data: (historyList) {
                if (historyList.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history,
                    title: 'Belum Ada Riwayat',
                    message: 'Riwayat perubahan kesehatan akan muncul di sini',
                  );
                }

                // Filter history
                final filteredHistory = _selectedFilter == null
                    ? historyList
                    : historyList
                          .where((h) => h.parameterKey == _selectedFilter)
                          .toList();

                if (filteredHistory.isEmpty) {
                  return EmptyState(
                    icon: Icons.filter_alt,
                    title: 'Tidak Ada Data',
                    message:
                        'Tidak ada riwayat untuk filter "${_filterOptions[_selectedFilter]?['label']}"',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.paddingMd),
                  itemCount: filteredHistory.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppDimensions.spaceMd),
                  itemBuilder: (context, index) {
                    final history = filteredHistory[index];
                    return _buildHistoryCard(history);
                  },
                );
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () =>
                    ref.refresh(healthHistoryProvider(widget.pet.id)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(PetHealthHistoryEntity history) {
    final parameterInfo = _getParameterInfo(history.parameterKey);

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: parameterInfo['color'].withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  parameterInfo['icon'],
                  color: parameterInfo['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parameterInfo['label'],
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'dd MMM yyyy, HH:mm',
                      ).format(history.changedAt),
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
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sebelumnya',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatValue(history.oldValue),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  LucideIcons.arrowRight,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sekarang',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatValue(history.newValue),
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (history.notes != null && history.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              history.notes!,
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

  Map<String, dynamic> _getParameterInfo(String parameterKey) {
    switch (parameterKey) {
      case 'is_vaccinated':
        return {
          'label': 'Status Vaksinasi',
          'icon': LucideIcons.syringe,
          'color': const Color(0xFF3B82F6),
        };
      case 'is_sterilized':
        return {
          'label': 'Status Sterilisasi',
          'icon': LucideIcons.shield,
          'color': AppColors.success,
        };
      case 'has_fungus':
        return {
          'label': 'Jamur',
          'icon': LucideIcons.circleAlert,
          'color': const Color(0xFFF59E0B),
        };
      case 'has_worms':
        return {
          'label': 'Cacing',
          'icon': LucideIcons.triangleAlert,
          'color': const Color(0xFFEF4444),
        };
      case 'has_fleas':
        return {
          'label': 'Kutu',
          'icon': LucideIcons.bug,
          'color': const Color(0xFFDC2626),
        };
      case 'stool_quality':
        return {
          'label': 'Kualitas Kotoran',
          'icon': LucideIcons.clipboardCheck,
          'color': const Color(0xFF8B5CF6),
        };
      default:
        return {
          'label': parameterKey,
          'icon': LucideIcons.info,
          'color': AppColors.grey,
        };
    }
  }

  String _formatValue(dynamic value) {
    if (value == null) return '-';

    if (value is bool) {
      return value ? 'Ya' : 'Tidak';
    }

    if (value is String) {
      // Try to parse as date
      final date = DateTime.tryParse(value);
      if (date != null) {
        return DateFormat('dd MMM yyyy').format(date);
      }

      // Handle stool quality
      switch (value) {
        case 'good':
          return '💚 Bagus';
        case 'normal':
          return '💛 Normal';
        case 'bad':
          return '❤️ Buruk';
        default:
          return value;
      }
    }

    return value.toString();
  }
}
