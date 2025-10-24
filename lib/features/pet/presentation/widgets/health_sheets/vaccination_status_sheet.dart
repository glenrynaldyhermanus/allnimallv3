import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/logger.dart';
import '../../../domain/entities/pet_entity.dart';
import '../../../domain/entities/pet_health_entity.dart';
import '../../../domain/entities/pet_timeline_entity.dart';
import '../../providers/pet_providers.dart';

class VaccinationStatusSheet extends ConsumerStatefulWidget {
  final PetEntity pet;
  final PetHealthEntity? health;

  const VaccinationStatusSheet({super.key, required this.pet, this.health});

  @override
  ConsumerState<VaccinationStatusSheet> createState() =>
      _VaccinationStatusSheetState();
}

class _VaccinationStatusSheetState
    extends ConsumerState<VaccinationStatusSheet> {
  late bool _isVaccinated;
  DateTime? _vaccinationDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isVaccinated = widget.health?.getBoolParameter('is_vaccinated') ?? false;
    _vaccinationDate = widget.health?.getDateParameter('vaccination_date');
  }

  Future<void> _saveVaccinationStatus() async {
    setState(() => _isLoading = true);

    try {
      final updateHealthParameterUseCase = ref.read(
        updateHealthParameterUseCaseProvider,
      );

      // Update vaccination status
      var result = await updateHealthParameterUseCase(
        petId: widget.pet.id,
        parameterKey: 'is_vaccinated',
        parameterValue: _isVaccinated,
        notes: _isVaccinated
            ? 'Marked as vaccinated'
            : 'Marked as not vaccinated',
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
          // If vaccinated and date is set, update date
          if (_isVaccinated && _vaccinationDate != null) {
            final dateResult = await updateHealthParameterUseCase(
              petId: widget.pet.id,
              parameterKey: 'vaccination_date',
              parameterValue: _vaccinationDate!.toIso8601String(),
              notes: 'Updated vaccination date',
            );

            // Handle date update result
            await dateResult.fold((failure) => null, (success) => null);
          }

          // Create timeline entry
          try {
            final createTimelineUseCase = ref.read(
              createTimelineEntryUseCaseProvider,
            );
            final timeline = PetTimelineEntity(
              id: '',
              petId: widget.pet.id,
              timelineType: 'health_update',
              title: _isVaccinated ? '💉 Sudah Divaksin' : '⚠️ Belum Divaksin',
              caption: _isVaccinated
                  ? (_vaccinationDate != null
                        ? 'Divaksin pada ${DateFormat('dd MMM yyyy').format(_vaccinationDate!)}'
                        : 'Status vaksinasi diperbarui')
                  : 'Status vaksinasi diperbarui',
              visibility: 'public',
              eventDate: DateTime.now(),
              createdAt: DateTime.now(),
            );
            await createTimelineUseCase(timeline);
          } catch (e) {
            AppLogger.error('Error creating timeline entry for vaccination', e);
          }

          if (mounted) {
            ref.invalidate(petHealthProvider(widget.pet.id));
            ref.invalidate(petTimelinesProvider(widget.pet.id));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status vaksinasi berhasil diupdate'),
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _vaccinationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _vaccinationDate = date;
      });
      HapticFeedback.selectionClick();
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
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.syringe,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Vaksinasi ${widget.pet.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Update status vaksinasi hewan peliharaan',
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
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  const Color(0xFF3B82F6).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF3B82F6), width: 2),
            ),
            child: Column(
              children: [
                Text(
                  _isVaccinated ? '✅ Sudah Divaksin' : '⚠️ Belum Divaksin',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
                if (_isVaccinated && _vaccinationDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_vaccinationDate!),
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Toggle Switch
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Material(
              color: AppColors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isVaccinated = !_isVaccinated;
                  });
                  HapticFeedback.selectionClick();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sudah Divaksin',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch(
                        value: _isVaccinated,
                        onChanged: (value) {
                          setState(() {
                            _isVaccinated = value;
                          });
                          HapticFeedback.selectionClick();
                        },
                        activeColor: const Color(0xFF3B82F6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Date Picker (only show if vaccinated)
          if (_isVaccinated) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                color: AppColors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _selectDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal Vaksinasi',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (_vaccinationDate != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(_vaccinationDate!),
                                style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const Icon(
                          LucideIcons.calendar,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Save Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveVaccinationStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
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
                        'Simpan Status Vaksinasi',
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
