import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

/// Reusable modal bottom sheet wrapper for pet forms
class PetFormBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final bool isLoading;
  final bool showActions;

  const PetFormBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.onSave,
    this.onCancel,
    this.isLoading = false,
    this.showActions = true,
  });

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
          // Draggable handle
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(context);
                  },
                  icon: const Icon(LucideIcons.x, color: AppColors.grey),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            ),
          ),

          // Action buttons
          if (showActions)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.greyLight, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton.outlined(
                      text: 'Cancel',
                      onPressed: isLoading
                          ? null
                          : (onCancel ?? () => Navigator.pop(context)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton.primary(
                      text: 'Save',
                      onPressed: isLoading ? null : onSave,
                      isLoading: isLoading,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Reusable date picker field
class PetDatePickerField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String? hint;
  final IconData icon;

  const PetDatePickerField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
    this.hint,
    this.icon = LucideIcons.calendar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.grey),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('dd MMM yyyy').format(selectedDate!)
                        : (hint ?? 'Select date'),
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: selectedDate != null
                          ? AppColors.black
                          : AppColors.grey,
                    ),
                  ),
                ),
                const Icon(
                  LucideIcons.chevronDown,
                  size: 20,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable dropdown field
class PetDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final IconData icon;

  const PetDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.icon = LucideIcons.chevronDown,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint ?? 'Select option',
                style: GoogleFonts.nunito(fontSize: 14, color: AppColors.grey),
              ),
              items: items,
              onChanged: (newValue) {
                HapticFeedback.selectionClick();
                onChanged(newValue);
              },
              icon: Icon(icon, color: AppColors.grey, size: 20),
              style: GoogleFonts.nunito(fontSize: 14, color: AppColors.black),
            ),
          ),
        ),
      ],
    );
  }
}

/// Gender selector widget
class GenderSelector extends StatelessWidget {
  final String? selectedGender;
  final ValueChanged<String> onChanged;

  const GenderSelector({
    super.key,
    required this.selectedGender,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
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
              child: _GenderOption(
                label: 'Male',
                icon: Icons.male,
                value: 'male',
                selectedValue: selectedGender,
                onTap: onChanged,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _GenderOption(
                label: 'Female',
                icon: Icons.female,
                value: 'female',
                selectedValue: selectedGender,
                onTap: onChanged,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String? selectedValue;
  final ValueChanged<String> onTap;
  final Color color;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selectedValue,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedValue == value;

    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap(value);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.grey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : AppColors.grey, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header with edit button
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  final Color color;

  const SectionHeader({
    super.key,
    required this.title,
    this.onEdit,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
        if (onEdit != null)
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              onEdit!();
            },
            icon: Icon(LucideIcons.pencil, color: color, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }
}
