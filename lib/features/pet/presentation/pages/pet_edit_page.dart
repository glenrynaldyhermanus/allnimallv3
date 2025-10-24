import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/pet_providers.dart';
import '../providers/pet_edit_state_provider.dart';

class PetEditPage extends ConsumerStatefulWidget {
  final String petId;

  const PetEditPage({super.key, required this.petId});

  @override
  ConsumerState<PetEditPage> createState() => _PetEditPageState();
}

class _PetEditPageState extends ConsumerState<PetEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();
  final _notesController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  XFile? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    final petAsync = await ref.read(petByIdProvider(widget.petId).future);

    if (!mounted) return;

    _nameController.text = petAsync.name;
    _breedController.text = petAsync.breed ?? '';
    _colorController.text = petAsync.color ?? '';
    _weightController.text = petAsync.weight?.toString() ?? '';
    _microchipController.text = petAsync.microchipId ?? '';
    _notesController.text = petAsync.story ?? '';
    _emergencyContactController.text = petAsync.emergencyContact ?? '';
    _selectedBirthDate = petAsync.birthDate;
    _selectedGender = petAsync.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    _notesController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _selectedBirthDate = date);
    }
  }

  Future<void> _pickPhoto() async {
    final imagePicker = ref.read(imagePickerServiceProvider);
    final photo = await imagePicker.pickAndCropImage(context);

    if (photo != null) {
      setState(() => _selectedPhoto = photo);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null) {
      _showError('Silakan pilih jenis kelamin');
      return;
    }

    ref.read(petEditStateProvider.notifier).setLoading(true);

    try {
      // Get current user
      final userResult = await ref.read(getCurrentUserUseCaseProvider)();
      final user = userResult.fold(
        (failure) => throw Exception('User not found: ${failure.message}'),
        (user) => user ?? (throw Exception('User not authenticated')),
      );

      // Upload new photo if selected
      String? pictureUrl;
      if (_selectedPhoto != null && mounted) {
        final storage = ref.read(storageServiceProvider);
        pictureUrl = await storage.uploadPetPhoto(
          ownerId: user.id,
          petId: widget.petId,
          imageFile: _selectedPhoto!,
        );
      }

      if (!mounted) return;

      // Get existing pet
      final existingPet = await ref.read(getPetByIdUseCaseProvider)(
        widget.petId,
      );
      final pet = existingPet.getOrElse(() => throw Exception('Pet not found'));

      // Update pet data
      final updatedPet = pet.copyWith(
        name: _nameController.text.trim(),
        breed: _breedController.text.trim().isEmpty
            ? null
            : _breedController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
        weight: _weightController.text.trim().isEmpty
            ? null
            : double.tryParse(_weightController.text.trim()),
        microchipId: _microchipController.text.trim().isEmpty
            ? null
            : _microchipController.text.trim(),
        story: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        emergencyContact: _emergencyContactController.text.trim().isEmpty
            ? null
            : _emergencyContactController.text.trim(),
        pictureUrl: pictureUrl ?? pet.pictureUrl,
      );

      final updatePet = ref.read(updatePetUseCaseProvider);
      final result = await updatePet(updatedPet);

      if (!mounted) return;

      ref.read(petEditStateProvider.notifier).setLoading(false);

      result.fold((failure) => _showError(failure.message), (pet) {
        // Invalidate cache
        ref.invalidate(petByIdProvider(widget.petId));

        // Show success and go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: AppColors.success,
          ),
        );

        if (context.mounted) {
          context.pop();
        }
      });
    } catch (e) {
      if (mounted) {
        ref.read(petEditStateProvider.notifier).setLoading(false);
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(petEditStateProvider);
    final petAsync = ref.watch(petByIdProvider(widget.petId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profil Hewan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: petAsync.when(
        data: (pet) => LoadingOverlay(
          isLoading: state.isLoading,
          message: 'Menyimpan perubahan...',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Upload
                  Center(
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Stack(
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: AppColors.greyLight,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusXl,
                              ),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                              image: _selectedPhoto != null
                                  ? null
                                  : pet.pictureUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(pet.pictureUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child:
                                _selectedPhoto == null && pet.pictureUrl == null
                                ? const Icon(
                                    Icons.pets,
                                    size: 60,
                                    color: AppColors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(
                                AppDimensions.paddingSm,
                              ),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceXl),

                  // Form Fields (same as registration)
                  AppTextField(
                    controller: _nameController,
                    label: '${AppStrings.petName} *',
                    hint: 'Nama hewan peliharaan',
                    prefixIcon: Icons.pets,
                    textInputAction: TextInputAction.next,
                    validator: (value) => Validators.required(value, 'Nama'),
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  AppTextField(
                    controller: _breedController,
                    label: AppStrings.breed,
                    hint: 'Contoh: Persian, Anggora, dll',
                    prefixIcon: Icons.category,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  GestureDetector(
                    onTap: _selectBirthDate,
                    child: AbsorbPointer(
                      child: AppTextField(
                        controller: TextEditingController(
                          text: _selectedBirthDate != null
                              ? DateFormat(
                                  'dd MMMM yyyy',
                                ).format(_selectedBirthDate!)
                              : '',
                        ),
                        label: AppStrings.birthDate,
                        hint: 'Pilih tanggal lahir',
                        prefixIcon: Icons.cake,
                        suffixIcon: Icons.calendar_today,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.gender} *',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceXs),
                      Row(
                        children: [
                          Expanded(
                            child: _buildGenderButton(
                              'male',
                              Icons.male,
                              AppStrings.male,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spaceMd),
                          Expanded(
                            child: _buildGenderButton(
                              'female',
                              Icons.female,
                              AppStrings.female,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  AppTextField(
                    controller: _colorController,
                    label: AppStrings.color,
                    hint: 'Contoh: Putih, Belang, dll',
                    prefixIcon: Icons.palette,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  AppTextField(
                    controller: _weightController,
                    label: '${AppStrings.weight} (kg)',
                    hint: 'Contoh: 3.5',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.monitor_weight,
                    textInputAction: TextInputAction.next,
                    validator: Validators.decimal,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  AppTextField(
                    controller: _microchipController,
                    label: AppStrings.microchipId,
                    hint: 'ID microchip (optional)',
                    prefixIcon: Icons.qr_code,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  AppTextField(
                    controller: _emergencyContactController,
                    label: 'Kontak Darurat',
                    hint: 'Nomor telepon darurat (optional)',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  AppTextField(
                    controller: _notesController,
                    label: 'Catatan Kesehatan',
                    hint: 'Vaksin, alergi, kondisi medis (optional)',
                    prefixIcon: Icons.medical_information,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                  ),

                  const SizedBox(height: AppDimensions.spaceXl),

                  AppButton.primary(
                    text: AppStrings.save,
                    onPressed: _handleSubmit,
                    isLoading: state.isLoading,
                    icon: Icons.check,
                  ),

                  const SizedBox(height: AppDimensions.spaceMd),

                  AppButton.outlined(
                    text: AppStrings.cancel,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.refresh(petByIdProvider(widget.petId)),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String value, IconData icon, String label) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingMd),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? AppColors.white : AppColors.grey),
            const SizedBox(width: AppDimensions.spaceXs),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
