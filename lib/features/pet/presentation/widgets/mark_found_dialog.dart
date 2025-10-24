import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/pet_providers.dart';

class MarkFoundDialog extends ConsumerStatefulWidget {
  final String petId;

  const MarkFoundDialog({super.key, required this.petId});

  @override
  ConsumerState<MarkFoundDialog> createState() => _MarkFoundDialogState();
}

class _MarkFoundDialogState extends ConsumerState<MarkFoundDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);

    final useCase = ref.read(markPetFoundUseCaseProvider);
    final result = await useCase(widget.petId);

    if (!mounted) return;

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (pet) {
        // Refresh pet data
        ref.invalidate(petByIdProvider(widget.petId));

        Navigator.of(context).pop(true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status berhasil diperbarui'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingMd),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                color: AppColors.success,
                size: 48,
              ),
            ),

            const SizedBox(height: AppDimensions.spaceLg),

            // Title
            Text(
              'Hewan Sudah Ditemukan?',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spaceSm),

            // Message
            Text(
              'Status "HILANG" akan dihapus dari profil publik',
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spaceLg),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    text: AppStrings.cancel,
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    isFullWidth: true,
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceMd),
                Expanded(
                  child: AppButton(
                    text: 'Ya, Sudah Ditemukan',
                    onPressed: _handleConfirm,
                    isLoading: _isLoading,
                    isFullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
