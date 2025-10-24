import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/pet_entity.dart';
import '../../../domain/entities/pet_health_entity.dart';
import '../../../domain/entities/pet_timeline_entity.dart';
import '../../providers/pet_providers.dart';

class OverallHealthCheckSheet extends ConsumerStatefulWidget {
  final PetEntity pet;
  final PetHealthEntity? health;

  const OverallHealthCheckSheet({super.key, required this.pet, this.health});

  @override
  ConsumerState<OverallHealthCheckSheet> createState() =>
      _OverallHealthCheckSheetState();
}

class _OverallHealthCheckSheetState
    extends ConsumerState<OverallHealthCheckSheet> {
  late bool _hasFungus;
  late bool _hasWorms;
  late bool _hasFleas;
  late String _stoolQuality;
  bool _isLoading = false;

  final Map<String, Map<String, dynamic>> _qualityOptions = {
    'good': {
      'label': 'Bagus',
      'emoji': '💚',
      'color': AppColors.success,
      'description': 'Bentuk padat, tidak terlalu keras atau lembek',
    },
    'normal': {
      'label': 'Normal',
      'emoji': '💛',
      'color': AppColors.warning,
      'description': 'Agak lembek tapi masih terbentuk',
    },
    'bad': {
      'label': 'Buruk',
      'emoji': '❤️',
      'color': AppColors.error,
      'description': 'Sangat lembek atau cair (diare)',
    },
  };

  @override
  void initState() {
    super.initState();
    _hasFungus = widget.health?.getBoolParameter('has_fungus') ?? false;
    _hasWorms = widget.health?.getBoolParameter('has_worms') ?? false;
    _hasFleas = widget.health?.getBoolParameter('has_fleas') ?? false;
    _stoolQuality =
        widget.health?.getStringParameter('stool_quality') ?? 'good';
  }

  Future<void> _saveHealthCheck() async {
    setState(() => _isLoading = true);

    try {
      final updateHealthParameterUseCase = ref.read(
        updateHealthParameterUseCaseProvider,
      );

      // Update all parasite parameters
      await updateHealthParameterUseCase(
        petId: widget.pet.id,
        parameterKey: 'has_fungus',
        parameterValue: _hasFungus,
        notes: _hasFungus ? 'Has fungal infection' : 'No fungal infection',
      );

      await updateHealthParameterUseCase(
        petId: widget.pet.id,
        parameterKey: 'has_worms',
        parameterValue: _hasWorms,
        notes: _hasWorms ? 'Has worms' : 'No worms',
      );

      await updateHealthParameterUseCase(
        petId: widget.pet.id,
        parameterKey: 'has_fleas',
        parameterValue: _hasFleas,
        notes: _hasFleas ? 'Has fleas' : 'No fleas',
      );

      // Update stool quality
      var result = await updateHealthParameterUseCase(
        petId: widget.pet.id,
        parameterKey: 'stool_quality',
        parameterValue: _stoolQuality,
        notes: 'Updated stool quality to $_stoolQuality',
      );

      await result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${failure.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        (success) async {
          // Create timeline entry
          try {
            final createTimelineUseCase = ref.read(
              createTimelineEntryUseCaseProvider,
            );

            final hasAnyParasite = _hasFungus || _hasWorms || _hasFleas;
            final problems = <String>[];
            if (_hasFungus) problems.add('Jamur');
            if (_hasWorms) problems.add('Cacing');
            if (_hasFleas) problems.add('Kutu');

            final qualityInfo = _qualityOptions[_stoolQuality]!;

            String title;
            String caption;

            if (hasAnyParasite) {
              title = '⚠️ Cek Kesehatan - Ditemukan Parasit';
              caption =
                  'Parasit: ${problems.join(', ')} | Kotoran: ${qualityInfo['label']}';
            } else {
              title = '✅ Cek Kesehatan - Kondisi Baik';
              caption = 'Bebas parasit | Kotoran: ${qualityInfo['label']}';
            }

            final timeline = PetTimelineEntity(
              id: '',
              petId: widget.pet.id,
              timelineType: 'health_update',
              title: title,
              caption: caption,
              visibility: 'public',
              eventDate: DateTime.now(),
              createdAt: DateTime.now(),
            );
            await createTimelineUseCase(timeline);
          } catch (e) {
            AppLogger.error(
              'Error creating timeline entry for health check',
              e,
            );
          }

          if (mounted) {
            ref.invalidate(petHealthProvider(widget.pet.id));
            ref.invalidate(petTimelinesProvider(widget.pet.id));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cek kesehatan berhasil diupdate'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyParasite = _hasFungus || _hasWorms || _hasFleas;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.clipboardCheck,
                    color: Color(0xFF8B5CF6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cek Kesehatan ${widget.pet.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cek parasit dan kualitas kotoran',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Status Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: hasAnyParasite
                    ? [
                        AppColors.error.withValues(alpha: 0.1),
                        AppColors.error.withValues(alpha: 0.05),
                      ]
                    : [
                        AppColors.success.withValues(alpha: 0.1),
                        AppColors.success.withValues(alpha: 0.05),
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasAnyParasite ? AppColors.error : AppColors.success,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  hasAnyParasite ? '⚠️ Ada Masalah' : '✅ Kondisi Baik',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: hasAnyParasite ? AppColors.error : AppColors.success,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  hasAnyParasite
                      ? 'Segera konsultasi ke dokter hewan'
                      : 'Kondisi sehat tanpa parasit',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Parasite Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cek Parasit',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                // Fungus
                _buildParasiteCheckbox(
                  label: '🍄 Ada Jamur',
                  value: _hasFungus,
                  color: const Color(0xFFF59E0B),
                  onChanged: (value) {
                    setState(() {
                      _hasFungus = value ?? false;
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
                const SizedBox(height: 12),

                // Worms
                _buildParasiteCheckbox(
                  label: '🪱 Ada Cacing',
                  value: _hasWorms,
                  color: const Color(0xFFEF4444),
                  onChanged: (value) {
                    setState(() {
                      _hasWorms = value ?? false;
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
                const SizedBox(height: 12),

                // Fleas
                _buildParasiteCheckbox(
                  label: '🦟 Ada Kutu',
                  value: _hasFleas,
                  color: const Color(0xFFDC2626),
                  onChanged: (value) {
                    setState(() {
                      _hasFleas = value ?? false;
                    });
                    HapticFeedback.selectionClick();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Stool Quality Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kualitas Kotoran',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  children: _qualityOptions.entries.map((entry) {
                    final key = entry.key;
                    final option = entry.value;
                    final isSelected = _stoolQuality == key;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _stoolQuality = key;
                            });
                            HapticFeedback.selectionClick();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? option['color'].withValues(alpha: 0.1)
                                  : AppColors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? option['color']
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  option['emoji'],
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option['label'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        option['description'],
                                        style: GoogleFonts.nunito(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    LucideIcons.check,
                                    color: option['color'],
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveHealthCheck,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Simpan Cek Kesehatan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParasiteCheckbox({
    required String label,
    required bool value,
    required Color color,
    required ValueChanged<bool?> onChanged,
  }) {
    return Material(
      color: AppColors.grey.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
