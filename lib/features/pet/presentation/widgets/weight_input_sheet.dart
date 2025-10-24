import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/entities/pet_health_entity.dart';
import '../../domain/entities/pet_timeline_entity.dart';
import '../providers/pet_providers.dart';

class WeightInputSheet extends ConsumerStatefulWidget {
  final PetEntity pet;
  final PetHealthEntity? health;

  const WeightInputSheet({super.key, required this.pet, this.health});

  @override
  ConsumerState<WeightInputSheet> createState() => _WeightInputSheetState();
}

class _WeightInputSheetState extends ConsumerState<WeightInputSheet> {
  late double _currentWeight;
  bool _isLoading = false;

  // Weight range: 0.1 kg to 100 kg
  static const double _minWeight = 0.1;
  static const double _maxWeight = 100.0;
  static const double _step = 0.1;

  @override
  void initState() {
    super.initState();
    // Initialize with current weight or default
    _currentWeight = widget.health?.weight?.toDouble() ?? 5.0;
  }

  void _incrementWeight() {
    if (_currentWeight < _maxWeight) {
      setState(() {
        _currentWeight = double.parse(
          (_currentWeight + _step).toStringAsFixed(1),
        );
      });
      HapticFeedback.lightImpact();
    }
  }

  void _decrementWeight() {
    if (_currentWeight > _minWeight) {
      setState(() {
        _currentWeight = double.parse(
          (_currentWeight - _step).toStringAsFixed(1),
        );
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _saveWeight() async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(petRepositoryProvider);

      final healthEntity = PetHealthEntity(
        id: widget.health?.id ?? '',
        petId: widget.pet.id,
        weight: _currentWeight,
        vaccinationStatus: widget.health?.vaccinationStatus,
        lastVaccinationDate: widget.health?.lastVaccinationDate,
        nextVaccinationDate: widget.health?.nextVaccinationDate,
        medicalConditions: widget.health?.medicalConditions,
        allergies: widget.health?.allergies,
        healthNotes: widget.health?.healthNotes,
        createdAt: widget.health?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.updatePetHealth(healthEntity);

      result.fold(
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
          // Create timeline entry for weight update
          try {
            final createTimelineUseCase = ref.read(
              createTimelineEntryUseCaseProvider,
            );
            final weightTimeline = PetTimelineEntity(
              id: '',
              petId: widget.pet.id,
              timelineType: 'weight_update',
              title: '⚖️ Update Berat Badan',
              caption:
                  'Berat badan ${widget.pet.name} sekarang $_currentWeight kg',
              visibility: 'public',
              eventDate: DateTime.now(),
              createdAt: DateTime.now(),
            );
            await createTimelineUseCase(weightTimeline);
          } catch (e) {
            AppLogger.error(
              'Error creating timeline entry for weight update',
              e,
            );
          }

          if (mounted) {
            ref.invalidate(petHealthProvider(widget.pet.id));
            ref.invalidate(petTimelinesProvider(widget.pet.id));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Berat badan berhasil diupdate'),
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
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    LucideIcons.weight,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Berat Badan ${widget.pet.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Atur berat badan dengan slider',
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

          // Weight Display
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'Berat Saat Ini',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _currentWeight.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'kg',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Counter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Decrement button
                Expanded(
                  child: Material(
                    color: _currentWeight > _minWeight
                        ? AppColors.secondary.withValues(alpha: 0.1)
                        : AppColors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _currentWeight > _minWeight
                          ? _decrementWeight
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Icon(
                          LucideIcons.minus,
                          color: _currentWeight > _minWeight
                              ? AppColors.secondary
                              : AppColors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Increment button
                Expanded(
                  child: Material(
                    color: _currentWeight < _maxWeight
                        ? AppColors.secondary.withValues(alpha: 0.1)
                        : AppColors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _currentWeight < _maxWeight
                          ? _incrementWeight
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Icon(
                          LucideIcons.plus,
                          color: _currentWeight < _maxWeight
                              ? AppColors.secondary
                              : AppColors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.secondary,
                    inactiveTrackColor: AppColors.secondary.withValues(
                      alpha: 0.2,
                    ),
                    thumbColor: AppColors.secondary,
                    overlayColor: AppColors.secondary.withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 24,
                    ),
                  ),
                  child: Slider(
                    value: _currentWeight,
                    min: _minWeight,
                    max: _maxWeight,
                    divisions: ((_maxWeight - _minWeight) / _step).round(),
                    onChanged: (value) {
                      setState(() {
                        _currentWeight = double.parse(value.toStringAsFixed(1));
                      });
                      HapticFeedback.selectionClick();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_minWeight.toStringAsFixed(1)} kg',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${_maxWeight.toStringAsFixed(0)} kg',
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

          const SizedBox(height: 24),

          // Save Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveWeight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
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
                        'Simpan Berat Badan',
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
}
