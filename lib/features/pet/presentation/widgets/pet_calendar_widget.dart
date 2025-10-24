import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';

class PetCalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final List<DateTime> eventDates;
  final bool isCompact;

  const PetCalendarWidget({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.onDaySelected,
    required this.eventDates,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        calendarFormat: isCompact ? CalendarFormat.week : CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        eventLoader: (day) {
          return eventDates.where((date) => isSameDay(date, day)).toList();
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markersMaxCount: isCompact ? 2 : 3,
          markerSize: isCompact ? 4.0 : 6.0,
          todayTextStyle: GoogleFonts.poppins(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 12 : 14,
          ),
          selectedTextStyle: GoogleFonts.poppins(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 12 : 14,
          ),
          defaultTextStyle: GoogleFonts.poppins(
            color: AppColors.black,
            fontSize: isCompact ? 12 : 14,
          ),
          weekendTextStyle: GoogleFonts.poppins(
            color: AppColors.error,
            fontSize: isCompact ? 12 : 14,
          ),
          outsideTextStyle: GoogleFonts.poppins(
            color: AppColors.grey,
            fontSize: isCompact ? 12 : 14,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: isCompact ? 14 : 16,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.primary,
            size: isCompact ? 20 : 24,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.primary,
            size: isCompact ? 20 : 24,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: GoogleFonts.poppins(
            fontSize: isCompact ? 10 : 12,
            fontWeight: FontWeight.w600,
            color: AppColors.grey,
          ),
          weekendStyle: GoogleFonts.poppins(
            fontSize: isCompact ? 10 : 12,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}
