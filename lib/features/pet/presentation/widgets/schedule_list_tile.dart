import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/pet_schedule_entity.dart';

class ScheduleListTile extends StatelessWidget {
  final PetScheduleEntity schedule;
  final VoidCallback onTap;

  const ScheduleListTile({
    super.key,
    required this.schedule,
    required this.onTap,
  });

  Color _getStatusColor() {
    if (schedule.isCompleted) {
      return AppColors.success;
    } else if (schedule.isPast) {
      return AppColors.error;
    } else {
      return AppColors.tertiary;
    }
  }

  IconData _getIconByType() {
    final icon = schedule.scheduleTypeIcon?.toLowerCase() ?? '';
    if (icon.contains('grooming') || icon.contains('scissors')) {
      return LucideIcons.scissors;
    } else if (icon.contains('medical') || icon.contains('stethoscope')) {
      return LucideIcons.stethoscope;
    } else if (icon.contains('birthday') || icon.contains('cake')) {
      return LucideIcons.cake;
    } else if (icon.contains('vaccination') || icon.contains('syringe')) {
      return LucideIcons.syringe;
    } else if (icon.contains('medicine') || icon.contains('pill')) {
      return LucideIcons.pill;
    }
    return LucideIcons.calendar;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final timeFormat = DateFormat('HH:mm');

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // Icon with status color
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_getIconByType(), color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          schedule.scheduleTypeName ?? 'Schedule',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (schedule.isRecurring)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.repeat,
                                size: 10,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Recurring',
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 12, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        timeFormat.format(schedule.scheduledAt),
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (schedule.notes != null &&
                          schedule.notes!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            schedule.notes!,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Status indicator
            if (schedule.isCompleted)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.check,
                  size: 12,
                  color: AppColors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
