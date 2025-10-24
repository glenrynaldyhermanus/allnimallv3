import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../customer/presentation/providers/customer_providers.dart';
import '../../../pet/domain/entities/pet_entity.dart';
import '../../../pet/domain/entities/pet_timeline_entity.dart';
import '../../../pet/presentation/providers/pet_providers.dart';
import 'package:intl/intl.dart';
import '../providers/auth_providers.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/local_storage_service.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Pet form controllers
  final _petNameController = TextEditingController();
  final _petGenderController = TextEditingController();
  final _petBirthDateController = TextEditingController();
  final _petHealthController = TextEditingController();
  final _petCategoryController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  String? _selectedPetCategory;
  String? _petPhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Pre-fill name from customer if available
    try {
      // Use authStateChangesProvider which already has the customer data
      final authState = ref.read(authStateChangesProvider);

      authState.when(
        data: (userEntity) {
          if (userEntity != null && userEntity.name != null && mounted) {
            print('Pre-filling name from auth state: ${userEntity.name}');
            setState(() {
              _nameController.text = userEntity.name!;
            });
          } else {
            print('No name available in auth state');
          }
        },
        loading: () {
          print('Auth state still loading...');
        },
        error: (error, stack) {
          print('Error in auth state: $error');
        },
      );
    } catch (e) {
      // Silently fail - user can still enter name manually
      print('Error loading user data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _petNameController.dispose();
    _petGenderController.dispose();
    _petBirthDateController.dispose();
    _petHealthController.dispose();
    _petCategoryController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Use authStateChangesProvider which is already loaded (not async like currentUserProvider)
    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser == null) {
      _showError('User not authenticated');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get phone number from local storage (fallback to current user)
      final storedPhone = await LocalStorageService.getPhoneNumber();
      final phoneNumber = storedPhone ?? currentUser.phone;

      // Normalize phone number format for database lookup (remove + prefix)
      String normalizedPhone = phoneNumber ?? '';
      if (normalizedPhone.startsWith('+62')) {
        normalizedPhone = normalizedPhone.substring(1); // Remove + prefix
      } else if (normalizedPhone.startsWith('62')) {
        normalizedPhone = normalizedPhone; // Keep as is
      } else if (normalizedPhone.startsWith('0')) {
        normalizedPhone =
            '62${normalizedPhone.substring(1)}'; // Replace 0 with 62
      }

      // Debug current user data
      print('Current user phone: ${currentUser.phone}');
      print('Stored phone: $storedPhone');
      print('Final phone: $phoneNumber');
      print('Current user email: ${currentUser.email}');
      print('Current user id: ${currentUser.id}');

      // Validate phone number
      if (phoneNumber == null || phoneNumber.isEmpty) {
        _showError('Phone number not found. Please login again.');
        return;
      }

      // Get existing customer by phone number
      print('Looking for customer with phone: $normalizedPhone');
      final getCustomerUseCase = ref.read(getCustomerByPhoneUseCaseProvider);

      // Try both formats: with and without + prefix
      var customerResult = await getCustomerUseCase(normalizedPhone);

      // If not found, try with + prefix
      if (customerResult.fold((l) => false, (r) => r == null)) {
        print(
          'Customer not found with format: $normalizedPhone, trying with + prefix',
        );
        final phoneWithPlus = '+$normalizedPhone';
        customerResult = await getCustomerUseCase(phoneWithPlus);
      }

      if (!mounted) return;

      // Handle customer result
      final existingCustomer = customerResult.fold((failure) {
        print('Failed to get customer: ${failure.message}');
        setState(() => _isLoading = false);
        _showError('Failed to get customer: ${failure.message}');
        return null;
      }, (customer) => customer);

      if (existingCustomer == null) {
        print('Customer is null - not found in database');
        setState(() => _isLoading = false);
        _showError('Customer not found. Please login again.');
        return;
      }

      print('Customer found: ${existingCustomer.id}');

      // Update customer name
      final updatedCustomer = existingCustomer.copyWith(
        name: _nameController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final updateCustomerUseCase = ref.read(updateCustomerUseCaseProvider);
      final updateResult = await updateCustomerUseCase(updatedCustomer);

      if (!mounted) return;

      // Handle update result
      final finalCustomer = updateResult.fold(
        (failure) {
          print('Failed to update customer: ${failure.message}');
          setState(() => _isLoading = false);
          _showError('Failed to update profile: ${failure.message}');
          return null;
        },
        (customer) {
          print('✅ Customer updated: ${customer.id}');
          // Invalidate auth providers to refresh with updated customer data
          ref.invalidate(authStateChangesProvider);
          ref.invalidate(currentUserProvider);
          return customer;
        },
      );

      if (finalCustomer == null) return;

      // Create pet
      final pet = PetEntity(
        id: const Uuid().v4(),
        ownerId: finalCustomer.id,
        name: _petNameController.text.trim(),
        petCategoryId:
            _selectedPetCategory ??
            'b30f979e-df0d-4151-ba0e-a958093f2ae3', // Default to Dog
        gender: _selectedGender ?? 'male', // Default to male
        birthDate: _selectedBirthDate,
        story: _petHealthController.text.trim(),
        pictureUrl: _petPhotoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('📝 About to create pet with ID: ${pet.id}');

      // Read providers BEFORE async operations to avoid disposed widget error
      final createPetUseCase = ref.read(createPetUseCaseProvider);
      final createTimelineUseCase = ref.read(
        createTimelineEntryUseCaseProvider,
      );

      final petResult = await createPetUseCase(pet);

      print('✅ createPetUseCase completed');
      print('🔍 Checking petResult...');
      print('🔍 petResult type: ${petResult.runtimeType}');
      print('🔍 mounted: $mounted');

      // Handle pet creation result (don't check mounted yet - pet might be created successfully)
      final createdPet = petResult.fold(
        (failure) {
          print('❌ Pet creation failed: ${failure.message}');
          if (mounted) {
            setState(() => _isLoading = false);
            _showError('Failed to create pet: ${failure.message}');
          }
          return null;
        },
        (pet) {
          print('✅ Pet from fold: ${pet.id}');
          return pet;
        },
      );

      print('🔍 createdPet result: ${createdPet?.id}');

      if (createdPet == null) {
        print('❌ createdPet is null, aborting');
        return;
      }

      print('🎉 Pet created successfully: ${createdPet.id}');
      print('📝 Starting timeline creation...');

      // Create timeline entries (do this even if widget unmounted - it's a background operation)
      try {
        // Create birthday entry if birthdate exists
        if (_selectedBirthDate != null) {
          print('🎂 Creating birthday timeline entry...');
          final birthdayTimeline = PetTimelineEntity(
            id: '',
            petId: createdPet.id,
            timelineType: 'birthday',
            title: '🎂 Birthday',
            caption:
                'Born on ${DateFormat('MMMM dd, yyyy').format(_selectedBirthDate!)}',
            visibility: 'public',
            eventDate: _selectedBirthDate!,
            createdAt: DateTime.now(),
          );
          final birthdayResult = await createTimelineUseCase(birthdayTimeline);
          birthdayResult.fold(
            (failure) =>
                print('❌ Birthday timeline failed: ${failure.message}'),
            (entry) => print('✅ Birthday timeline created: ${entry.id}'),
          );
        } else {
          print('⏭️ No birthdate, skipping birthday timeline');
        }

        // Create welcome entry
        print('🎉 Creating welcome timeline entry...');
        final welcomeTimeline = PetTimelineEntity(
          id: '',
          petId: createdPet.id,
          timelineType: 'welcome',
          title: '🎉 Welcome to Allnimall!',
          caption: '${createdPet.name} just joined the family',
          visibility: 'public',
          eventDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        final welcomeResult = await createTimelineUseCase(welcomeTimeline);
        welcomeResult.fold(
          (failure) => print('❌ Welcome timeline failed: ${failure.message}'),
          (entry) => print('✅ Welcome timeline created: ${entry.id}'),
        );
      } catch (e) {
        print('❌ Error creating timeline entries: $e');
        // Don't fail the whole operation if timeline creation fails
      }

      print('✅ Timeline creation completed');

      // CRITICAL: Wait for database replication & invalidate provider BEFORE navigation
      print('⏳ Waiting 2 seconds for database replication...');
      await Future.delayed(const Duration(seconds: 2));

      // Verify pet was actually saved by refetching with retry
      print('🔍 Verifying pet was saved to database...');
      final getPetsByOwnerUseCase = ref.read(getPetsByOwnerUseCaseProvider);

      bool petConfirmed = false;
      for (int attempt = 1; attempt <= 3; attempt++) {
        print('🔄 Verification attempt $attempt/3');
        final verifyResult = await getPetsByOwnerUseCase(finalCustomer.id);

        verifyResult.fold(
          (failure) {
            print('❌ Verification failed: ${failure.message}');
          },
          (pets) {
            print('✅ Found ${pets.length} pets for owner');
            petConfirmed = pets.any((p) => p.id == createdPet.id);
            if (petConfirmed) {
              print('✅ New pet CONFIRMED in database!');
            } else {
              print('⚠️ New pet NOT found in database yet (attempt $attempt)');
            }
          },
        );

        if (petConfirmed) break;
        if (attempt < 3) {
          print('⏳ Waiting 1 second before retry...');
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      if (!petConfirmed) {
        print(
          '⚠️ WARNING: Pet not found after 3 attempts! But will proceed...',
        );
      }

      // CRITICAL: Invalidate pets provider so dashboard gets fresh data
      print('🔄 Invalidating petsByOwnerProvider...');
      ref.invalidate(petsByOwnerProvider(finalCustomer.id));

      // Small delay to let Riverpod process invalidation
      await Future.delayed(const Duration(milliseconds: 500));

      // Stop loading
      if (mounted) {
        setState(() => _isLoading = false);
      }

      print('🚀 Navigating to dashboard');
      print('✅ Pet ID for reference: ${createdPet.id}');

      // Navigate to dashboard - should now see the pet!
      if (mounted) {
        context.go(AppRoutes.dashboard);
      } else {
        print('⚠️ Widget disposed, navigating anyway...');
        // Force navigation even if widget disposed
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go(AppRoutes.dashboard);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showError('Unexpected error: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return; // Don't show error if widget unmounted
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedBirthDate = date;
        _petBirthDateController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  Future<void> _pickPetPhoto() async {
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
      // Use authStateChangesProvider which is already loaded (not async like currentUserProvider)
      final currentUser = ref.read(authStateChangesProvider).value;
      if (currentUser == null) {
        _showError('User not authenticated');
        return;
      }

      final tempPetId = const Uuid().v4();
      print('Uploading photo to storage...');
      final photoUrl = await storageService.uploadPetPhoto(
        imageFile: imageFile,
        ownerId: currentUser.id, // Use auth user ID as owner ID temporarily
        petId: tempPetId,
      );
      print('Photo uploaded: $photoUrl');

      setState(() {
        _petPhotoUrl = photoUrl;
      });
    } catch (e) {
      print('Error in _pickPetPhoto: $e');
      _showError('Failed to upload photo: $e');
    }
  }

  void _selectGender() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Jenis Kelamin',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLg),
            ...['Jantan', 'Betina'].map(
              (gender) => ListTile(
                title: Text(gender),
                onTap: () {
                  setState(() {
                    // Map to database values
                    _selectedGender = gender == 'Jantan' ? 'male' : 'female';
                    _petGenderController.text = gender;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectPetCategory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Jenis Hewan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceLg),
            ...[
              {
                'name': 'Anjing',
                'uuid': 'b30f979e-df0d-4151-ba0e-a958093f2ae3',
              },
              {
                'name': 'Kucing',
                'uuid': 'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
              },
            ].map(
              (category) => ListTile(
                title: Text(category['name']!),
                onTap: () {
                  setState(() {
                    _selectedPetCategory = category['uuid']!;
                    _petCategoryController.text = category['name']!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setup Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Membuat profil dan timeline...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Info Section
                Text(
                  'Informasi Pemilik',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg),

                AppTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  prefixIcon: Icons.person,
                  validator: Validators.required,
                ),

                const SizedBox(height: AppDimensions.spaceXl),

                // Pet Info Section
                Text(
                  'Informasi Hewan Peliharaan',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg),

                // Pet Photo
                GestureDetector(
                  onTap: _pickPetPhoto,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: _petPhotoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            child: Image.network(
                              _petPhotoUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 48,
                                color: AppColors.primary,
                              ),
                              const SizedBox(height: AppDimensions.spaceSm),
                              Text(
                                'Tap untuk menambah foto',
                                style: GoogleFonts.nunito(
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceLg),

                AppTextField(
                  controller: _petNameController,
                  label: 'Nama Hewan',
                  hint: 'Masukkan nama hewan peliharaan',
                  prefixIcon: Icons.pets,
                  validator: Validators.required,
                ),

                const SizedBox(height: AppDimensions.spaceLg),

                // Pet Category Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Jenis Hewan',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),

                GestureDetector(
                  onTap: _selectPetCategory,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMd,
                      vertical: AppDimensions.paddingSm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.spaceSm),
                        Expanded(
                          child: Text(
                            _petCategoryController.text.isEmpty
                                ? 'Tap untuk pilih Anjing atau Kucing'
                                : _petCategoryController.text,
                            style: GoogleFonts.nunito(
                              color: _petCategoryController.text.isEmpty
                                  ? AppColors.grey
                                  : AppColors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceLg),

                // Pet Gender Label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Jenis Kelamin',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),

                GestureDetector(
                  onTap: _selectGender,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMd,
                      vertical: AppDimensions.paddingSm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.wc, color: AppColors.primary, size: 20),
                        const SizedBox(width: AppDimensions.spaceSm),
                        Expanded(
                          child: Text(
                            _petGenderController.text.isEmpty
                                ? 'Tap untuk pilih Jantan atau Betina'
                                : _petGenderController.text,
                            style: GoogleFonts.nunito(
                              color: _petGenderController.text.isEmpty
                                  ? AppColors.grey
                                  : AppColors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceLg),

                GestureDetector(
                  onTap: _selectBirthDate,
                  child: AppTextField(
                    controller: _petBirthDateController,
                    label: 'Tanggal Lahir',
                    hint: 'Pilih tanggal lahir',
                    prefixIcon: Icons.calendar_today,
                    validator: Validators.required,
                  ),
                ),

                const SizedBox(height: AppDimensions.spaceLg),

                AppTextField(
                  controller: _petHealthController,
                  label: 'Kondisi Kesehatan',
                  hint: 'Deskripsi kondisi kesehatan hewan',
                  prefixIcon: Icons.health_and_safety,
                  maxLines: 3,
                ),

                const SizedBox(height: AppDimensions.spaceXxl),

                AppButton.primary(
                  text: 'Buat Profile',
                  onPressed: _handleSubmit,
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
