import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/entities/pet_timeline_entity.dart';
import '../providers/pet_registration_state_provider.dart';
import '../providers/pet_providers.dart';
import '../widgets/pet_form_widgets.dart';

class PetRegistrationPage extends ConsumerStatefulWidget {
  final String? petId; // Keep for backward compatibility
  final String? qrId; // NEW: QR ID to assign after creation

  const PetRegistrationPage({super.key, this.petId, this.qrId});

  @override
  ConsumerState<PetRegistrationPage> createState() =>
      _PetRegistrationPageState();
}

class _PetRegistrationPageState extends ConsumerState<PetRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  String? _petPhotoUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
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
    try {
      final imagePickerService = ref.read(imagePickerServiceProvider);
      final storageService = ref.read(storageServiceProvider);

      // Show image picker bottom sheet
      final imageFile = await imagePickerService.showImagePickerBottomSheet(
        context,
      );
      if (imageFile == null) {
        print('Image picker cancelled');
        return;
      }
      print('Image picked: ${imageFile.path}');

      // Upload directly without cropping
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        _showError('User not authenticated');
        return;
      }

      // Generate pet ID if not provided (for new pets)
      final petId = (widget.petId?.isEmpty ?? true)
          ? const Uuid().v4()
          : widget.petId!;

      print('Uploading photo to storage...');
      final photoUrl = await storageService.uploadPetPhoto(
        imageFile: imageFile,
        ownerId: currentUser.id,
        petId: petId,
      );
      print('Photo uploaded: $photoUrl');

      setState(() {
        _petPhotoUrl = photoUrl;
      });
    } catch (e) {
      print('Error in _pickPhoto: $e');
      _showError('Failed to upload photo: $e');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGender == null) {
      _showError('Silakan pilih jenis kelamin');
      return;
    }

    ref.read(petRegistrationStateProvider.notifier).setLoading(true);

    try {
      if (!mounted) return;

      // Get current user for owner ID
      final userResult = await ref.read(getCurrentUserUseCaseProvider)();
      final user = userResult.fold(
        (failure) => throw Exception('User not found: ${failure.message}'),
        (user) => user ?? (throw Exception('User not authenticated')),
      );

      String petId = widget.petId ?? '';

      // Check if this is a new pet (no petId) or updating existing pet
      final isNewPet = widget.petId?.isEmpty ?? true;

      late final PetEntity petToSave;

      if (isNewPet) {
        // Create new pet
        petId = const Uuid().v4();
        petToSave = PetEntity(
          id: petId,
          ownerId: user.id,
          name: _nameController.text.trim(),
          petCategoryId:
              'b30f979e-df0d-4151-ba0e-a958093f2ae3', // Default to Dog
          gender: _selectedGender ?? 'male',
          breed: _breedController.text.trim().isEmpty
              ? null
              : _breedController.text.trim(),
          birthDate: _selectedBirthDate,
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
          pictureUrl: _petPhotoUrl,
          activatedAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      } else {
        // Update existing pet
        final existingPet = await ref.read(getPetByIdUseCaseProvider)(
          widget.petId!,
        );

        final pet = existingPet.getOrElse(
          () => throw Exception('Pet not found'),
        );

        petToSave = pet.copyWith(
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
          pictureUrl: _petPhotoUrl ?? pet.pictureUrl,
          activatedAt: DateTime.now(),
        );
      }

      // Save pet (create or update)
      final result = isNewPet
          ? await ref.read(createPetUseCaseProvider)(petToSave)
          : await ref.read(updatePetUseCaseProvider)(petToSave);

      if (!mounted) return;

      ref.read(petRegistrationStateProvider.notifier).setLoading(false);

      result.fold((failure) => _showError(failure.message), (savedPet) async {
        // Create timeline entries for birthday and welcome
        final createTimelineUseCase = ref.read(
          createTimelineEntryUseCaseProvider,
        );

        try {
          // Create birthday entry if birthdate exists
          if (_selectedBirthDate != null) {
            final birthdayTimeline = PetTimelineEntity(
              id: '',
              petId: petId,
              timelineType: 'birthday',
              title: '🎂 Birthday',
              caption:
                  'Born on ${DateFormat('MMMM dd, yyyy').format(_selectedBirthDate!)}',
              visibility: 'public',
              eventDate: _selectedBirthDate!,
              createdAt: DateTime.now(),
            );
            await createTimelineUseCase(birthdayTimeline);
          }

          // Create welcome entry
          final welcomeTimeline = PetTimelineEntity(
            id: '',
            petId: petId,
            timelineType: 'welcome',
            title: '🎉 Welcome to Allnimall!',
            caption: '${_nameController.text.trim()} just joined the family',
            visibility: 'public',
            eventDate: DateTime.now(),
            createdAt: DateTime.now(),
          );
          await createTimelineUseCase(welcomeTimeline);
        } catch (e) {
          print('Error creating timeline entries: $e');
          // Don't fail the whole operation if timeline creation fails
        }

        // Assign QR code if provided
        if (widget.qrId != null) {
          try {
            // Update pet with QR ID
            final updatedPet = petToSave.copyWith(qrId: widget.qrId);
            await ref.read(updatePetUseCaseProvider)(updatedPet);
            print('✅ QR code ${widget.qrId} assigned to pet $petId');
          } catch (e) {
            print('❌ Error assigning QR code: $e');
            // Don't fail the whole operation if QR assignment fails
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Pet berhasil dibuat, tapi gagal assign QR code: ${e.toString()}',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }

        if (!mounted) return;

        // Navigate to pet profile
        context.go(AppRoutes.pet.replaceAll(':petId', petId));
      });
    } catch (e) {
      if (mounted) {
        ref.read(petRegistrationStateProvider.notifier).setLoading(false);
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
    final state = ref.watch(petRegistrationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Hewan Peliharaan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      body: LoadingOverlay(
        isLoading: state.isLoading,
        message: 'Menyimpan profil...',
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
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.greyLight,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXl,
                        ),
                        border: Border.all(color: AppColors.primary, width: 2),
                        image: _petPhotoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_petPhotoUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _petPhotoUrl == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(height: AppDimensions.spaceXs),
                                Text(
                                  'Tambah Foto',
                                  style: GoogleFonts.nunito(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceXl),

                // Name (Required)
                AppTextField(
                  controller: _nameController,
                  label: '${AppStrings.petName} *',
                  hint: 'Nama hewan peliharaan',
                  prefixIcon: Icons.pets,
                  textInputAction: TextInputAction.next,
                  validator: (value) => Validators.required(value, 'Nama'),
                ),

                const SizedBox(height: AppDimensions.spaceMd),

                // Breed
                AppTextField(
                  controller: _breedController,
                  label: AppStrings.breed,
                  hint: 'Contoh: Persian, Anggora, dll',
                  prefixIcon: Icons.category,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: AppDimensions.spaceMd),

                // Birth Date
                PetDatePickerField(
                  label: AppStrings.birthDate,
                  selectedDate: _selectedBirthDate,
                  hint: 'Pilih tanggal lahir',
                  onTap: _selectBirthDate,
                ),

                const SizedBox(height: AppDimensions.spaceMd),

                // Gender (Required)
                GenderSelector(
                  selectedGender: _selectedGender,
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),

                const SizedBox(height: AppDimensions.spaceMd),

                // Color
                AppTextField(
                  controller: _colorController,
                  label: AppStrings.color,
                  hint: 'Contoh: Putih, Belang, dll',
                  prefixIcon: Icons.palette,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: AppDimensions.spaceMd),

                // Weight
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

                // Microchip ID
                AppTextField(
                  controller: _microchipController,
                  label: AppStrings.microchipId,
                  hint: 'ID microchip (optional)',
                  prefixIcon: Icons.qr_code,
                  textInputAction: TextInputAction.next,
                ),

                const SizedBox(height: AppDimensions.spaceMd),

                // Notes
                AppTextField(
                  controller: _notesController,
                  label: AppStrings.notes,
                  hint: 'Catatan tambahan (optional)',
                  prefixIcon: Icons.notes,
                  maxLines: 4,
                  textInputAction: TextInputAction.done,
                ),

                const SizedBox(height: AppDimensions.spaceXl),

                // Submit Button
                AppButton.primary(
                  text: 'Simpan & Aktivasi Kalung',
                  onPressed: _handleSubmit,
                  isLoading: state.isLoading,
                  icon: Icons.check_circle,
                ),

                const SizedBox(height: AppDimensions.spaceMd),

                // Info
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingMd),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 20,
                      ),
                      const SizedBox(width: AppDimensions.spaceSm),
                      Expanded(
                        child: Text(
                          'Setelah disimpan, kalung QR Anda akan aktif dan profil dapat diakses publik',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
