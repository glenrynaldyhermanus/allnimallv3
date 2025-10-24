import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/pet_schedule_entity.dart';
import '../../domain/entities/recurring_pattern_entity.dart';
import '../../domain/entities/pet_timeline_entity.dart';
import '../providers/pet_providers.dart';
import 'pet_form_widgets.dart';

class AddEditScheduleSheet extends ConsumerStatefulWidget {
  final String petId;
  final PetScheduleEntity? schedule;
  final VoidCallback onSuccess;

  const AddEditScheduleSheet({
    super.key,
    required this.petId,
    this.schedule,
    required this.onSuccess,
  });

  @override
  ConsumerState<AddEditScheduleSheet> createState() =>
      _AddEditScheduleSheetState();
}

class _AddEditScheduleSheetState extends ConsumerState<AddEditScheduleSheet> {
  final _notesController = TextEditingController();
  String? _selectedScheduleTypeId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRecurring = false;
  String _patternType = 'daily';
  int _intervalValue = 1;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      // Edit mode - populate existing data
      _selectedScheduleTypeId = widget.schedule!.scheduleTypeId;
      _selectedDate = widget.schedule!.scheduledAt;
      _selectedTime = TimeOfDay.fromDateTime(widget.schedule!.scheduledAt);
      _notesController.text = widget.schedule!.notes ?? '';
      _isRecurring = widget.schedule!.isRecurring;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.tertiary,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.tertiary,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _selectedDate.add(const Duration(days: 30)),
      firstDate: _selectedDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.tertiary,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  Future<void> _saveSchedule() async {
    if (_selectedScheduleTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a schedule type'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Combine date and time
      final scheduledAt = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      String? recurringPatternId;

      // Create recurring pattern if needed
      if (_isRecurring) {
        final patternEntity = RecurringPatternEntity(
          id: const Uuid().v4(),
          patternType: _patternType,
          intervalValue: _intervalValue,
          endDate: _endDate,
          isActive: true,
          createdAt: DateTime.now(),
        );

        final repository = ref.read(petRepositoryProvider);
        final result = await repository.createRecurringPattern(patternEntity);

        result.fold(
          (failure) {
            throw Exception(failure.message);
          },
          (pattern) {
            recurringPatternId = pattern.id;
          },
        );
      }

      // Create or update schedule
      final scheduleEntity = PetScheduleEntity(
        id: widget.schedule?.id ?? const Uuid().v4(),
        petId: widget.petId,
        scheduleTypeId: _selectedScheduleTypeId!,
        scheduledAt: scheduledAt,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        status: widget.schedule?.status ?? 'scheduled',
        recurringPatternId: recurringPatternId,
        createdAt: widget.schedule?.createdAt ?? DateTime.now(),
      );

      if (widget.schedule == null) {
        // Create new schedule
        final createUseCase = ref.read(createScheduleUseCaseProvider);
        final result = await createUseCase(scheduleEntity);

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
          (createdSchedule) async {
            // Create timeline entry for schedule
            try {
              final createTimelineUseCase = ref.read(
                createTimelineEntryUseCaseProvider,
              );

              // Get schedule type name
              final scheduleTypesAsync = ref.read(scheduleTypesProvider);
              String scheduleTypeName = 'Schedule';
              scheduleTypesAsync.whenData((types) {
                final scheduleType = types.firstWhere(
                  (type) => type.id == _selectedScheduleTypeId,
                  orElse: () => types.first,
                );
                scheduleTypeName = scheduleType.name;
              });

              final scheduleTimeline = PetTimelineEntity(
                id: '',
                petId: widget.petId,
                timelineType: 'schedule',
                title: '📅 $scheduleTypeName',
                caption: _notesController.text.trim().isEmpty
                    ? 'Scheduled for ${DateFormat('MMM dd, yyyy · HH:mm').format(_selectedDate)}'
                    : _notesController.text.trim(),
                visibility: 'public',
                eventDate: _selectedDate,
                createdAt: DateTime.now(),
              );
              await createTimelineUseCase(scheduleTimeline);
            } catch (e) {
              AppLogger.error('Error creating timeline entry for schedule', e);
              // Don't fail the whole operation if timeline creation fails
            }

            if (mounted) {
              Navigator.pop(context);
              widget.onSuccess();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Schedule created successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
        );
      } else {
        // Update existing schedule
        final updateUseCase = ref.read(updateScheduleUseCaseProvider);
        final result = await updateUseCase(scheduleEntity);

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
          (success) {
            if (mounted) {
              Navigator.pop(context);
              widget.onSuccess();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Schedule updated successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            }
          },
        );
      }
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

  Future<void> _deleteSchedule() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Schedule',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete this schedule?',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && widget.schedule != null) {
      setState(() => _isLoading = true);

      final deleteUseCase = ref.read(deleteScheduleUseCaseProvider);
      final result = await deleteUseCase(widget.schedule!.id);

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
        (success) {
          if (mounted) {
            Navigator.pop(context);
            widget.onSuccess();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Schedule deleted successfully'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _markAsComplete() async {
    if (widget.schedule == null) return;

    setState(() => _isLoading = true);

    final updatedSchedule = widget.schedule!.copyWith(
      status: 'completed',
      completedAt: DateTime.now(),
    );

    final updateUseCase = ref.read(updateScheduleUseCaseProvider);
    final result = await updateUseCase(updatedSchedule);

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
      (success) {
        if (mounted) {
          Navigator.pop(context);
          widget.onSuccess();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule marked as complete'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleTypesAsync = ref.watch(scheduleTypesProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.schedule == null
                          ? 'Add Schedule'
                          : 'Edit Schedule',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  if (widget.schedule != null && !widget.schedule!.isCompleted)
                    IconButton(
                      onPressed: _isLoading ? null : _markAsComplete,
                      icon: const Icon(
                        LucideIcons.check,
                        color: AppColors.success,
                      ),
                      tooltip: 'Mark as complete',
                    ),
                  if (widget.schedule != null)
                    IconButton(
                      onPressed: _isLoading ? null : _deleteSchedule,
                      icon: const Icon(
                        LucideIcons.trash2,
                        color: AppColors.error,
                      ),
                      tooltip: 'Delete',
                    ),
                ],
              ),
            ),
            const Divider(),
            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Schedule Type Dropdown
                    scheduleTypesAsync.when(
                      data: (types) {
                        if (types.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  LucideIcons.triangleAlert,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No schedule types available. Please add schedule types first.',
                                    style: GoogleFonts.nunito(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return PetDropdownField<String>(
                          label: 'Schedule Type',
                          value: _selectedScheduleTypeId,
                          hint: 'Select type',
                          items: types
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type.id,
                                  child: Text(type.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedScheduleTypeId = value);
                          },
                        );
                      },
                      loading: () => const Center(child: LoadingIndicator()),
                      error: (error, stack) => Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Error loading schedule types: $error',
                          style: GoogleFonts.nunito(color: AppColors.error),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Date Picker
                    PetDatePickerField(
                      label: 'Date',
                      selectedDate: _selectedDate,
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                    // Time Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _selectTime,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greyLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.grey),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.clock,
                                  color: AppColors.tertiary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedTime.format(context),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Notes
                    AppTextField(
                      controller: _notesController,
                      label: 'Notes (Optional)',
                      hint: 'Add notes about this schedule',
                      prefixIcon: LucideIcons.fileText,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // Recurring Checkbox
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: CheckboxListTile(
                        value: _isRecurring,
                        onChanged: (value) {
                          setState(() => _isRecurring = value ?? false);
                        },
                        title: Text(
                          'Recurring Schedule',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          'Repeat this schedule automatically',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                        activeColor: AppColors.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                    // Recurring options
                    if (_isRecurring) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.repeat,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Recurring Pattern',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Pattern Type
                            PetDropdownField<String>(
                              label: 'Repeat',
                              value: _patternType,
                              hint: 'Select pattern',
                              items: const [
                                DropdownMenuItem(
                                  value: 'daily',
                                  child: Text('Daily'),
                                ),
                                DropdownMenuItem(
                                  value: 'weekly',
                                  child: Text('Weekly'),
                                ),
                                DropdownMenuItem(
                                  value: 'monthly',
                                  child: Text('Monthly'),
                                ),
                                DropdownMenuItem(
                                  value: 'yearly',
                                  child: Text('Yearly'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _patternType = value!);
                              },
                            ),
                            const SizedBox(height: 16),
                            // Interval
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Every',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.greyLight,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.grey,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                if (_intervalValue > 1) {
                                                  setState(
                                                    () => _intervalValue--,
                                                  );
                                                }
                                              },
                                              icon: const Icon(
                                                LucideIcons.minus,
                                                size: 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                            Text(
                                              '$_intervalValue',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.black,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                setState(
                                                  () => _intervalValue++,
                                                );
                                              },
                                              icon: const Icon(
                                                LucideIcons.plus,
                                                size: 20,
                                              ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _patternType == 'daily'
                                          ? 'day(s)'
                                          : _patternType == 'weekly'
                                          ? 'week(s)'
                                          : _patternType == 'monthly'
                                          ? 'month(s)'
                                          : 'year(s)',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // End Date
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'End Date (Optional)',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (_endDate != null)
                                      TextButton(
                                        onPressed: () {
                                          setState(() => _endDate = null);
                                        },
                                        child: Text(
                                          'Clear',
                                          style: GoogleFonts.poppins(
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _selectEndDate,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.greyLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.grey),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.calendar,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _endDate != null
                                              ? DateFormat(
                                                  'dd MMM yyyy',
                                                ).format(_endDate!)
                                              : 'Never',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: _endDate != null
                                                ? AppColors.black
                                                : AppColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.tertiary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                widget.schedule == null
                                    ? 'Create Schedule'
                                    : 'Update Schedule',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
