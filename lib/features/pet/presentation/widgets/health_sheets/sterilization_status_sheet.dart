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

class SterilizationStatusSheet extends ConsumerStatefulWidget {
  final PetEntity pet;
  final PetHealthEntity? health;

  const SterilizationStatusSheet({super.key, required this.pet, this.health});

  @override
  ConsumerState<SterilizationStatusSheet> createState() =>
      _SterilizationStatusSheetState();
}

class _SterilizationStatusSheetState
    extends ConsumerState<SterilizationStatusSheet> {
  late bool _isSterilized;
  DateTime? _sterilizationDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isSterilized = widget.health?.getBoolParameter('is_sterilized') ?? false;
    _sterilizationDate = widget.health?.getDateParameter('sterilization_date');
  }

  Future<void> _saveSterilizationStatus() async {
    setState(() => _isLoading = true);

    try {
      final updateHealthParameterUseCase = ref.read(
        updateHealthParameterUseCaseProvider,
      );

      // Update sterilization status
      var result = await updateHealthParameterUseCase(
        petId: widget.pet.id,
        parameterKey: 'is_sterilized',
        parameterValue: _isSterilized,
        notes: _isSterilized
            ? 'Marked as sterilized'
            : 'Marked as not sterilized',
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
          // If sterilized and date is set, update date
          if (_isSterilized && _sterilizationDate != null) {
            final dateResult = await updateHealthParameterUseCase(
              petId: widget.pet.id,
              parameterKey: 'sterilization_date',
              parameterValue: _sterilizationDate!.toIso8601String(),
              notes: 'Updated sterilization date',
            );

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
              title: _isSterilized ? '🛡️ Sudah Disteril' : '⚠️ Belum Disteril',
              caption: _isSterilized
                  ? (_sterilizationDate != null
                        ? 'Disteril pada ${DateFormat('dd MMM yyyy').format(_sterilizationDate!)}'
                        : 'Status sterilisasi diperbarui')
                  : 'Status sterilisasi diperbarui',
              visibility: 'public',
              eventDate: DateTime.now(),
              createdAt: DateTime.now(),
            );
            await createTimelineUseCase(timeline);
          } catch (e) {
            AppLogger.error(
              'Error creating timeline entry for sterilization',
              e,
            );
          }

          if (mounted) {
            ref.invalidate(petHealthProvider(widget.pet.id));
            ref.invalidate(petTimelinesProvider(widget.pet.id));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status sterilisasi berhasil diupdate'),
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
      initialDate: _sterilizationDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.success),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _sterilizationDate = date;
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
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.shield,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Sterilisasi ${widget.pet.name}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Update status sterilisasi/kastrasi',
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
                  AppColors.success.withValues(alpha: 0.1),
                  AppColors.success.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.success, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  _isSterilized ? '✅ Sudah Disteril' : '⚠️ Belum Disteril',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                if (_isSterilized && _sterilizationDate != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('dd MMMM yyyy').format(_sterilizationDate!),
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
                    _isSterilized = !_isSterilized;
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
                        'Sudah Disteril/Dikebiri',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch(
                        value: _isSterilized,
                        onChanged: (value) {
                          setState(() {
                            _isSterilized = value;
                          });
                          HapticFeedback.selectionClick();
                        },
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Date Picker (only show if sterilized)
          if (_isSterilized) ...[
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
                              'Tanggal Sterilisasi',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (_sterilizationDate != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(_sterilizationDate!),
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
                          color: AppColors.success,
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
                onPressed: _isLoading ? null : _saveSterilizationStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
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
                        'Simpan Status Sterilisasi',
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
