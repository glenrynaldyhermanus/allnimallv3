import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/pet_providers.dart';

class ReportLostDialog extends ConsumerStatefulWidget {
  final String petId;

  const ReportLostDialog({super.key, required this.petId});

  @override
  ConsumerState<ReportLostDialog> createState() => _ReportLostDialogState();
}

class _ReportLostDialogState extends ConsumerState<ReportLostDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final useCase = ref.read(reportLostPetUseCaseProvider);
    final result = await useCase(
      widget.petId,
      lostMessage: _messageController.text.trim(),
      emergencyContact: _contactController.text.trim(),
    );

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
            content: Text('Laporan kehilangan berhasil dibuat'),
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
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingSm),
                      decoration: BoxDecoration(
                        color: AppColors.lostPetBanner.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.warning,
                        color: AppColors.lostPetBanner,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMd),
                    Expanded(
                      child: Text(
                        AppStrings.reportLost,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.spaceLg),

                // Lost Message
                AppTextField(
                  controller: _messageController,
                  label: 'Pesan Khusus',
                  hint: 'Contoh: Terakhir terlihat di Taman Menteng',
                  maxLines: 3,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: AppDimensions.spaceMd),

                // Emergency Contact
                AppTextField(
                  controller: _contactController,
                  label: '${AppStrings.emergencyContact} *',
                  hint: '08xxxxxxxxxx',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                  textInputAction: TextInputAction.done,
                  validator: Validators.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                  ],
                ),

                const SizedBox(height: AppDimensions.spaceMd),

                // Warning
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMd),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.spaceSm),
                      Expanded(
                        child: Text(
                          'Nomor kontak akan ditampilkan di profil publik',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceLg),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: AppButton.outlined(
                        text: AppStrings.cancel,
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pop(context),
                        isFullWidth: true,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spaceMd),
                    Expanded(
                      child: AppButton(
                        text: 'Laporkan',
                        onPressed: _handleSubmit,
                        isLoading: _isLoading,
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
