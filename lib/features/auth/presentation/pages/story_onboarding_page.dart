import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../customer/presentation/providers/customer_providers.dart';
import '../../../pet/domain/entities/pet_entity.dart';
import '../../../pet/domain/entities/pet_timeline_entity.dart';
import '../../../pet/presentation/providers/pet_providers.dart';
import '../providers/auth_providers.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/local_storage_service.dart';
import '../widgets/underline_textfield.dart';
import '../widgets/story_step.dart';
import '../widgets/story_builder.dart';
import '../widgets/typewriter_text.dart';

class StoryOnboardingPage extends ConsumerStatefulWidget {
  const StoryOnboardingPage({super.key});

  @override
  ConsumerState<StoryOnboardingPage> createState() =>
      _StoryOnboardingPageState();
}

class _StoryOnboardingPageState extends ConsumerState<StoryOnboardingPage> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final _nameController = TextEditingController();
  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();
  final _notesController = TextEditingController();

  // Pet data
  String? _selectedCategoryId; // Store the actual UUID
  String? _selectedCategory; // Store 'cat' or 'dog' for story building
  String? _selectedCategoryName; // Store the display name for "Lainnya"
  String? _selectedGender;
  bool _genderConfirmed = false; // Track if user confirmed gender selection
  String? _selectedBreed;
  DateTime? _selectedBirthDate;
  List<String> _selectedCharacters = []; // Selected character IDs
  List<String> _selectedCharacterNames = []; // For story display
  bool _charactersConfirmed =
      false; // Track if user confirmed character selection
  String? _petPhotoUrl;

  // Story building
  String _currentStory = '';
  bool _storyComplete = false;

  // Confetti
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _petNameController.dispose();
    _breedController.dispose();
    _notesController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    try {
      final authState = ref.read(authStateChangesProvider);
      authState.when(
        data: (userEntity) {
          if (userEntity != null && userEntity.name != null && mounted) {
            setState(() {
              _nameController.text = userEntity.name!;
            });
          }
        },
        loading: () {},
        error: (error, stack) {},
      );
    } catch (e) {
      // Silently fail
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
        // Reset Story 2 substeps when entering Story 2
        if (_currentStep == 1) {
          _selectedCategoryId = null;
          _selectedCategory = null;
          _selectedCategoryName = null;
          _petNameController.clear();
          _selectedGender = null;
          _genderConfirmed = false;
          _selectedBreed = null;
          _selectedBirthDate = null;
          _selectedCharacters = [];
          _selectedCharacterNames = [];
          _charactersConfirmed = false;
          _notesController.clear();
          _petPhotoUrl = null;
          _currentStory = '';
          _storyComplete = false;
        }
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _updateStory() {
    print('📖 _updateStory called');
    print('   _selectedCategory: $_selectedCategory');
    print('   _petNameController.text: ${_petNameController.text}');
    print('   _selectedGender: $_selectedGender');

    setState(() {
      // Build story progressively based on what data we have
      final categoryIndo = _selectedCategory == 'cat'
          ? 'kucing'
          : _selectedCategory == 'dog'
          ? 'anjing'
          : _selectedCategory;

      if (_selectedCategory != null && _petNameController.text.isEmpty) {
        // Just category selected
        _currentStory = 'Ada seekor $categoryIndo dateng, nih!';
        _storyComplete = false;
      } else if (_selectedCategory != null &&
          _petNameController.text.isNotEmpty &&
          _selectedGender == null) {
        // Category + name
        _currentStory =
            'Ada seekor $categoryIndo bernama ${_petNameController.text.trim()}, nih!';
        _storyComplete = false;
      } else if (_selectedCategory != null &&
          _petNameController.text.isNotEmpty &&
          _selectedGender != null) {
        // Build full story with current data (Indonesian)
        _currentStory = StoryBuilder.buildStory(
          category: _selectedCategory!,
          name: _petNameController.text.trim(),
          gender: _selectedGender!,
          breed: _selectedBreed,
          birthDate: _selectedBirthDate,
          characters: _selectedCharacterNames.isNotEmpty
              ? _selectedCharacterNames
              : null,
          story: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );
        // Don't auto-complete, let user proceed manually
        // This allows photo upload to show after notes
        _storyComplete = false;
      }
      print('   ✅ Story updated: $_currentStory');
      print('   _storyComplete: $_storyComplete');
    });
  }

  Future<void> _handleSubmit() async {
    if (!_storyComplete) return;

    final currentUser = ref.read(authStateChangesProvider).value;
    if (currentUser == null) {
      _showError('User not authenticated');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get phone number from local storage
      final storedPhone = await LocalStorageService.getPhoneNumber();
      final phoneNumber = storedPhone ?? currentUser.phone;

      // Normalize phone number
      String normalizedPhone = phoneNumber ?? '';
      if (normalizedPhone.startsWith('+62')) {
        normalizedPhone = normalizedPhone.substring(1);
      } else if (normalizedPhone.startsWith('0')) {
        normalizedPhone = '62${normalizedPhone.substring(1)}';
      }

      if (phoneNumber == null || phoneNumber.isEmpty) {
        _showError('Phone number not found. Please login again.');
        return;
      }

      // Get existing customer
      final getCustomerUseCase = ref.read(getCustomerByPhoneUseCaseProvider);
      var customerResult = await getCustomerUseCase(normalizedPhone);

      if (customerResult.fold((l) => false, (r) => r == null)) {
        final phoneWithPlus = '+$normalizedPhone';
        customerResult = await getCustomerUseCase(phoneWithPlus);
      }

      if (!mounted) return;

      final existingCustomer = customerResult.fold((failure) {
        setState(() => _isLoading = false);
        _showError('Failed to get customer: ${failure.message}');
        return null;
      }, (customer) => customer);

      if (existingCustomer == null) {
        setState(() => _isLoading = false);
        _showError('Customer not found. Please login again.');
        return;
      }

      // Update customer name
      final updatedCustomer = existingCustomer.copyWith(
        name: _nameController.text.trim(),
        updatedAt: DateTime.now(),
      );

      final updateCustomerUseCase = ref.read(updateCustomerUseCaseProvider);
      final updateResult = await updateCustomerUseCase(updatedCustomer);

      if (!mounted) return;

      final finalCustomer = updateResult.fold(
        (failure) {
          setState(() => _isLoading = false);
          _showError('Failed to update profile: ${failure.message}');
          return null;
        },
        (customer) {
          ref.invalidate(authStateChangesProvider);
          ref.invalidate(currentUserProvider);
          return customer;
        },
      );

      if (finalCustomer == null) return;

      // Create pet with full story (minus first sentence)
      final pet = PetEntity(
        id: const Uuid().v4(),
        ownerId: finalCustomer.id,
        name: _petNameController.text.trim(),
        petCategoryId:
            _selectedCategoryId ??
            'e76601d1-eaf1-42fc-ad9c-d49821518e4a', // Use stored UUID
        gender: _selectedGender ?? 'male',
        breed:
            _selectedBreed ??
            (_breedController.text.trim().isEmpty
                ? null
                : _breedController.text
                      .trim()), // Save breed from state or controller
        birthDate: _selectedBirthDate,
        story: _getPreviewStory(), // Save full story without first sentence
        pictureUrl: _petPhotoUrl,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createPetUseCase = ref.read(createPetUseCaseProvider);
      final createTimelineUseCase = ref.read(
        createTimelineEntryUseCaseProvider,
      );
      final assignCharactersUseCase = ref.read(assignCharactersUseCaseProvider);

      final petResult = await createPetUseCase(pet);

      final createdPet = petResult.fold((failure) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('Failed to create pet: ${failure.message}');
        }
        return null;
      }, (pet) => pet);

      if (createdPet == null) return;

      // Assign characters to pet
      print('🔍 Character assignment check:');
      print('   _selectedCharacters.isEmpty: ${_selectedCharacters.isEmpty}');
      print('   _selectedCharacters.length: ${_selectedCharacters.length}');
      print('   _selectedCharacters: $_selectedCharacters');
      print('   _selectedCharacterNames: $_selectedCharacterNames');

      if (_selectedCharacters.isNotEmpty) {
        try {
          print(
            '🔧 Assigning ${_selectedCharacters.length} characters to pet ${createdPet.id}',
          );
          print('   Pet ID: ${createdPet.id}');
          print('   Character IDs to assign: $_selectedCharacters');

          print('   📞 Calling assignCharactersUseCase...');
          final assignResult = await assignCharactersUseCase(
            createdPet.id,
            _selectedCharacters,
          );

          print('   📥 Got result from assignCharactersUseCase');
          assignResult.fold(
            (failure) {
              print('❌ Failed to assign characters: ${failure.message}');
              print('   Failure type: ${failure.runtimeType}');
            },
            (_) {
              print('✅ Characters assigned successfully to database');
            },
          );
        } catch (e, stackTrace) {
          print('❌ Exception assigning characters: $e');
          print('   Exception type: ${e.runtimeType}');
          print('   Stack trace: $stackTrace');
        }
      } else {
        print('⚠️ No characters selected to assign (list is empty)');
      }

      // Create timeline entries
      try {
        // 1. Birthday entry (if birthdate provided)
        if (_selectedBirthDate != null) {
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
          await createTimelineUseCase(birthdayTimeline);
        }

        // 2. Welcome entry with story and photo
        final welcomeTimeline = PetTimelineEntity(
          id: '',
          petId: createdPet.id,
          timelineType: 'welcome',
          title: '🎉 Welcome to Allnimall!',
          caption: _getPreviewStory(), // Use the story (minus first sentence)
          mediaUrl: _petPhotoUrl, // Use pet photo if uploaded
          mediaType: _petPhotoUrl != null
              ? 'image'
              : null, // Set type if photo exists
          visibility: 'public',
          eventDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await createTimelineUseCase(welcomeTimeline);
      } catch (e) {
        print('Error creating timeline entries: $e');
      }

      // Wait for database replication
      await Future.delayed(const Duration(seconds: 2));

      // Invalidate pets provider
      ref.invalidate(petsByOwnerProvider(finalCustomer.id));
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => _isLoading = false);
        _nextStep(); // Go to success screen
        _confettiController.play(); // Start confetti
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showError('Unexpected error: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
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
        _updateStory();
      });
    }
  }

  Future<void> _pickPetPhoto() async {
    try {
      final imagePickerService = ref.read(imagePickerServiceProvider);
      final storageService = ref.read(storageServiceProvider);

      final imageFile = await imagePickerService.showImagePickerBottomSheet(
        context,
      );
      if (imageFile == null) return;

      final currentUser = ref.read(authStateChangesProvider).value;
      if (currentUser == null) {
        _showError('User not authenticated');
        return;
      }

      final tempPetId = const Uuid().v4();
      final photoUrl = await storageService.uploadPetPhoto(
        imageFile: imageFile,
        ownerId: currentUser.id,
        petId: tempPetId,
      );

      setState(() {
        _petPhotoUrl = photoUrl;
      });
    } catch (e) {
      _showError('Failed to upload photo: $e');
    }
  }

  String _getFirstName() {
    final fullName = _nameController.text.trim();
    if (fullName.isEmpty) return '';
    return fullName.split(' ').first;
  }

  String _getPreviewStory() {
    // Remove first sentence (Ada seekor ... bernama ...)
    // Keep only from second sentence onwards
    final sentences = _currentStory.split('. ');
    if (sentences.length > 1) {
      // Skip first sentence, join the rest
      return sentences.skip(1).join('. ');
    }
    return _currentStory;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0, // Only allow pop on first step
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep > 0) {
          // If not on first step, go to previous step instead of popping
          _previousStep();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: LoadingOverlay(
          isLoading: _isLoading,
          message: 'Creating your pet\'s story...',
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              // Swipe right to go back (previous step)
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 300) {
                _previousStep();
              }
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              reverseDuration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _getCurrentStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCurrentStep() {
    switch (_currentStep) {
      case 0:
        return KeyedSubtree(
          key: const ValueKey(0),
          child: _buildOwnerNameStep(),
        );
      case 1:
        return KeyedSubtree(
          key: const ValueKey(1),
          child: _buildPetDetailsStep(),
        );
      case 2:
        return KeyedSubtree(key: const ValueKey(2), child: _buildPreviewStep());
      case 3:
        return KeyedSubtree(key: const ValueKey(3), child: _buildSuccessStep());
      default:
        return KeyedSubtree(
          key: const ValueKey(0),
          child: _buildOwnerNameStep(),
        );
    }
  }

  Widget _buildOwnerNameStep() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spaceXl),
                Text(
                  'Selamat datang di Allnimall',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                Text(
                  'Boleh tau ngga nama kamu siapa?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXl),
                UnderlineTextField(
                  controller: _nameController,
                  autofocus: true,
                  validator: Validators.required,
                ),
              ],
            ),
          ),
        ),
        // Floating button at bottom (above keyboard)
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0
                ? 16 // Small margin when keyboard is open
                : 0,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: MediaQuery.of(context).viewInsets.bottom > 0
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
          ),
          child: SafeArea(
            child: AppButton.primary(
              text: 'Next',
              onPressed: _nameController.text.trim().isNotEmpty
                  ? _nextStep
                  : null,
              icon: Icons.arrow_forward,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetDetailsStep() {
    final categories = ref.watch(petCategoriesProvider);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spaceXl),

                // AnimatedSwitcher for smooth transition between category selection and story
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _currentStory.isEmpty
                      ? Column(
                          key: const ValueKey('category-selection'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo ${_getFirstName()}, selamat bergabung!',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceLg),
                            Text(
                              'Sekarang coba ceritakan sedikit tentang anabul kamu, apakah dia kucing atau anjing?',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceXl),

                            // Category selection cards (hide after Next is pressed)
                            categories.when(
                              data: (cats) {
                                // Hardcode common categories with custom cards
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildCategoryCardWithIcon(
                                            'Kucing',
                                            'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
                                            LucideIcons.cat,
                                            cats,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: AppDimensions.spaceMd,
                                        ),
                                        Expanded(
                                          child: _buildCategoryCardWithIcon(
                                            'Anjing',
                                            'b30f979e-df0d-4151-ba0e-a958093f2ae3',
                                            LucideIcons.dog,
                                            cats,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: AppDimensions.spaceMd,
                                    ),
                                    _buildCategoryCardWithIcon(
                                      'Lainnya',
                                      'other',
                                      LucideIcons.pawPrint,
                                      cats,
                                    ),
                                  ],
                                );
                              },
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (_, __) => _buildDefaultCategoryCards(),
                            ),
                          ],
                        )
                      : Column(
                          key: const ValueKey('story-section'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back button
                            TextButton.icon(
                              onPressed: _handleStoryBack,
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: Text(
                                'Kembali',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.grey,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceMd),

                            // Show current story with typewriter effect
                            TypewriterText(
                              text: _currentStory,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.spaceXl),
                          ],
                        ),
                ),

                // Input fields (show after story appears)
                if (_currentStory.isNotEmpty) ...[
                  if (_petNameController.text.isEmpty) ...[
                    Text(
                      'Siapa nama ${_selectedCategory == 'cat'
                          ? 'kucing'
                          : _selectedCategory == 'dog'
                          ? 'anjing'
                          : _selectedCategory} kamu?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceMd),
                    UnderlineTextField(
                      controller: _petNameController,
                      hintText: 'Tommen Ragmanus',
                      autofocus: true,
                      validator: Validators.required,
                      onTap: () => _updateStory(),
                    ),
                  ] else if (_selectedGender == null || !_genderConfirmed) ...[
                    // Gender selection question
                    Text(
                      '${_petNameController.text} itu ${_selectedCategory == 'cat'
                          ? 'kucing'
                          : _selectedCategory == 'dog'
                          ? 'anjing'
                          : _selectedCategory} jantan atau betina?',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spaceMd),
                    // Gender selection cards (horizontal layout, vertical content)
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderCard('Jantan', 'male', Icons.male),
                        ),
                        const SizedBox(width: AppDimensions.spaceMd),
                        Expanded(
                          child: _buildGenderCard(
                            'Betina',
                            'female',
                            Icons.female,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Optional fields (breed)
                    if (_selectedBreed == null &&
                        _breedController.text.isEmpty) ...[
                      Text(
                        'Apa jenis breed / ras / morph dari ${_petNameController.text}?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      UnderlineTextField(
                        controller: _breedController,
                        hintText: 'Local breed, atau lainnya',
                        autofocus: true,
                      ),
                    ] else if (_selectedBirthDate == null) ...[
                      GestureDetector(
                        onTap: _selectBirthDate,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            'Kapan tanggal lahir ${_petNameController.text}?',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ),
                    ] else if (!_charactersConfirmed) ...[
                      // Character selection
                      Text(
                        'Karakter ${_petNameController.text} seperti apa sih?',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      _buildCharacterSelection(),
                    ] else if (_notesController.text.isEmpty) ...[
                      Text(
                        'Ceritakan lebih banyak tentang ${_petNameController.text}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spaceMd),
                      UnderlineTextField(
                        controller: _notesController,
                        hintText:
                            '${_petNameController.text} itu loyal banget, selalu ikutin aku kemanapun aku pergi....',
                        autofocus: true,
                        maxLines: null,
                        onTap: () => _updateStory(),
                      ),
                    ] else ...[
                      // Photo upload
                      Center(
                        child: GestureDetector(
                          onTap: _pickPetPhoto,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 80,
                                backgroundColor: AppColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                backgroundImage: _petPhotoUrl != null
                                    ? NetworkImage(_petPhotoUrl!)
                                    : null,
                                child: _petPhotoUrl == null
                                    ? Icon(
                                        Icons.pets,
                                        size: 60,
                                        color: AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      )
                                    : null,
                              ),
                              if (_petPhotoUrl == null)
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo,
                                          size: 16,
                                          color: AppColors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Upload foto',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ],
            ),
          ),

          // Floating Next button at bottom
        ),
        Container(
          padding: const EdgeInsets.all(AppDimensions.paddingLg),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 0,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: MediaQuery.of(context).viewInsets.bottom > 0
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
          ),
          child: SafeArea(
            child: _shouldShowSkipButton()
                ? Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _handleSkipOptionalFields,
                          child: Text(
                            'Skip dulu',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.grey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spaceMd),
                      Expanded(
                        flex: 2,
                        child: AppButton.primary(
                          text: 'Next',
                          onPressed: _canProceedFromCurrentSection()
                              ? _handleSectionNext
                              : null,
                          icon: Icons.arrow_forward,
                        ),
                      ),
                    ],
                  )
                : AppButton.primary(
                    text: 'Next',
                    onPressed: _canProceedFromCurrentSection()
                        ? _handleSectionNext
                        : null,
                    icon: Icons.arrow_forward,
                  ),
          ),
        ),
      ],
    );
  }

  bool _canProceedFromCurrentSection() {
    print('🔍 _canProceedFromCurrentSection check:');
    print('   _selectedCategoryId: $_selectedCategoryId');
    print('   _selectedCategory: $_selectedCategory');
    print('   _petNameController.text: ${_petNameController.text}');
    print('   _selectedGender: $_selectedGender');
    print('   _genderConfirmed: $_genderConfirmed');
    print('   _selectedBirthDate: $_selectedBirthDate');
    print('   _charactersConfirmed: $_charactersConfirmed');

    // Category selection - must select a category first
    if (_selectedCategoryId == null) {
      print('   ❌ No category selected');
      return false;
    }

    // If just selected category, can proceed
    if (_petNameController.text.isEmpty) {
      print('   ✅ Can proceed (category selected, no pet name yet)');
      return true;
    }

    // If entered pet name but no gender, can't proceed yet
    if (_selectedGender == null) {
      print('   ❌ Pet name filled but no gender selected');
      return false;
    }

    // If gender selected but not confirmed, can proceed (to confirm it)
    if (!_genderConfirmed) {
      print('   ✅ Can proceed (gender selected, ready to confirm)');
      return true;
    }

    // If at character selection, can proceed (to confirm character selection)
    if (_selectedBirthDate != null && !_charactersConfirmed) {
      print('   ✅ Can proceed (at character selection)');
      return true;
    }

    // All required fields filled, can proceed to preview
    print('   ✅ All required fields filled');
    return true;
  }

  bool _shouldShowSkipButton() {
    // Show skip only when we're in optional fields section
    return _selectedCategory != null &&
        _petNameController.text.isNotEmpty &&
        _selectedGender != null &&
        _genderConfirmed &&
        !_storyComplete;
  }

  void _handleSectionNext() {
    print('🚀 _handleSectionNext called');
    print('   _currentStory: $_currentStory');
    print('   _storyComplete: $_storyComplete');

    // If just selected category, build initial story
    if (_petNameController.text.isEmpty && _selectedCategory != null) {
      final categoryIndo = _selectedCategory == 'cat'
          ? 'kucing'
          : _selectedCategory == 'dog'
          ? 'anjing'
          : _selectedCategory;
      setState(() {
        _currentStory = 'Ada seekor $categoryIndo dateng, nih!';
      });
      print('   ✅ Initial story created: $_currentStory');
      return; // Stay on same section, now pet name field will show
    }

    // If gender selected but not confirmed, confirm it now
    if (_selectedGender != null && !_genderConfirmed) {
      setState(() {
        _genderConfirmed = true;
        _updateStory(); // Update story with gender
      });
      print('   ✅ Gender confirmed, story updated');
      return; // Stay on same section, now optional fields will show
    }

    // If at character selection, confirm it
    if (_selectedBirthDate != null && !_charactersConfirmed) {
      setState(() {
        _charactersConfirmed = true;
        _updateStory(); // Update story with characters
      });
      print('   ✅ Characters confirmed, story updated');
      return; // Stay on same section, now notes will show
    }

    // Check if breed field has content but not saved yet
    if (_breedController.text.isNotEmpty && _selectedBreed == null) {
      setState(() {
        _selectedBreed = _breedController.text.trim();
      });
      print('   ✅ Breed saved from controller: $_selectedBreed');
    }

    // Update story with current data
    _updateStory();

    print('   After _updateStory:');
    print('   _currentStory: $_currentStory');
    print(
      '   All fields: breed=$_selectedBreed, birthDate=$_selectedBirthDate, notes=${_notesController.text}, photo=$_petPhotoUrl',
    );

    // Check if we should go to preview
    // Only go if notes filled AND photo shown (even if not uploaded)
    final allRequiredFilled =
        _selectedBreed != null &&
        _selectedBirthDate != null &&
        _notesController.text.isNotEmpty;

    // Check if we're at the photo upload stage
    final photoStageReached =
        allRequiredFilled && _notesController.text.isNotEmpty;

    if (photoStageReached && _petPhotoUrl == null) {
      // Notes filled but no photo yet - stay to show photo upload
      print('   ℹ️ Notes filled, showing photo upload');
      return;
    }

    if (allRequiredFilled && photoStageReached) {
      // Everything done, go to preview
      setState(() => _storyComplete = true);
      print('   ✅ Going to preview (Story 3)');
      _nextStep(); // Go to Story 3 (Preview)
    } else {
      print('   ℹ️ Staying on current section (showing next field)');
    }
    // Otherwise stay on current section and show next field
  }

  void _handleSkipOptionalFields() {
    setState(() {
      _selectedBreed = _selectedBreed ?? 'mixed';
      _selectedBirthDate =
          _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365));
      _charactersConfirmed = true; // Also confirm characters when skipping
      _notesController.text = _notesController.text.isEmpty
          ? 'A lovely pet'
          : _notesController.text;
      _updateStory();
    });
    _nextStep();
  }

  void _handleStoryBack() {
    setState(() {
      // Check current state and go back to previous step
      if (_petPhotoUrl != null ||
          (_notesController.text.isNotEmpty &&
              _selectedBirthDate != null &&
              _selectedBreed != null)) {
        // At photo upload or notes filled -> go back to notes/birthdate
        _petPhotoUrl = null;
        if (_notesController.text.isNotEmpty) {
          _notesController.clear();
        } else if (_selectedBirthDate != null) {
          _selectedBirthDate = null;
        } else if (_selectedBreed != null) {
          _selectedBreed = null;
          _breedController.clear();
        }
      } else if (_charactersConfirmed || _selectedCharacters.isNotEmpty) {
        // At characters -> go back to birthdate
        _selectedCharacters.clear();
        _selectedCharacterNames.clear();
        _charactersConfirmed = false;
      } else if (_selectedBirthDate != null) {
        // At birthdate -> go back to breed
        _selectedBirthDate = null;
      } else if (_selectedBreed != null || _breedController.text.isNotEmpty) {
        // At breed -> go back to gender
        _selectedBreed = null;
        _breedController.clear();
        _genderConfirmed = false;
      } else if (_genderConfirmed) {
        // Gender confirmed -> go back to gender selection
        _genderConfirmed = false;
        _updateStory();
      } else if (_selectedGender != null) {
        // At gender selection -> go back to pet name
        _selectedGender = null;
        _updateStory();
      } else if (_petNameController.text.isNotEmpty) {
        // At pet name -> go back to category selection
        _petNameController.clear();
        _currentStory = '';
      } else {
        // At initial story -> go back to category selection
        _selectedCategoryId = null;
        _selectedCategory = null;
        _selectedCategoryName = null;
        _currentStory = '';
      }
    });
  }

  Widget _buildGenderCard(String label, String value, IconData icon) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
          // Don't update story yet, wait for Next button
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: AppDimensions.spaceSm),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCardWithIcon(
    String name,
    String id,
    IconData icon,
    List<dynamic>? cats,
  ) {
    // Check if this card is selected
    final isSelected =
        _selectedCategoryId == id ||
        (id == 'other' && _selectedCategoryName != null);

    return GestureDetector(
      onTap: () {
        if (id == 'other') {
          // Show bottom sheet for other categories
          if (cats != null) _showOtherCategoriesSheet(cats);
        } else {
          // Just select the card, don't build story yet
          setState(() {
            _selectedCategoryId = id;
            _selectedCategory = id == 'e76601d1-eaf1-42fc-ad9c-d49821518e4a'
                ? 'cat'
                : id == 'b30f979e-df0d-4151-ba0e-a958093f2ae3'
                ? 'dog'
                : name.toLowerCase();
            _selectedCategoryName = null; // Clear "Lainnya" selection
          });
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppDimensions.paddingLg),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: AppDimensions.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  // Show selected category name for "Lainnya"
                  if (id == 'other' && _selectedCategoryName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selectedCategoryName!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: isSelected
                            ? AppColors.white.withValues(alpha: 0.9)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOtherCategoriesSheet(List<dynamic> categories) {
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
            ...categories
                .where(
                  (c) =>
                      c.id != 'e76601d1-eaf1-42fc-ad9c-d49821518e4a' &&
                      c.id != 'b30f979e-df0d-4151-ba0e-a958093f2ae3',
                )
                .map(
                  (category) => ListTile(
                    leading: Icon(
                      LucideIcons.pawPrint,
                      color: AppColors.primary,
                    ),
                    title: Text(category.nameId),
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = category.id;
                        _selectedCategory = category.nameId.toLowerCase();
                        _selectedCategoryName =
                            category.nameId; // Store display name
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

  Widget _buildCharacterSelection() {
    final characters = ref.watch(charactersProvider);

    return characters.when(
      data: (charList) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: charList.map((character) {
            final isSelected = _selectedCharacters.contains(character.id);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedCharacters.remove(character.id);
                    _selectedCharacterNames.remove(character.characterId);
                  } else {
                    _selectedCharacters.add(character.id);
                    _selectedCharacterNames.add(character.characterId);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  character.characterId,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDefaultCategoryCards() {
    // Fallback if categories fail to load
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCategoryCardWithIcon(
                'Kucing',
                'e76601d1-eaf1-42fc-ad9c-d49821518e4a',
                LucideIcons.cat,
                null,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMd),
            Expanded(
              child: _buildCategoryCardWithIcon(
                'Anjing',
                'b30f979e-df0d-4151-ba0e-a958093f2ae3',
                LucideIcons.dog,
                null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        _buildCategoryCardWithIcon(
          'Lainnya',
          'other',
          LucideIcons.pawPrint,
          null,
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    return StoryStep(
      title: '',
      subtitle: null,
      content: Column(
        children: [
          // Pet avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: _petPhotoUrl != null
                ? NetworkImage(_petPhotoUrl!)
                : null,
            child: _petPhotoUrl == null
                ? Icon(
                    _selectedCategory == 'dog' ? Icons.pets : Icons.pets,
                    size: 60,
                    color: AppColors.primary,
                  )
                : null,
          ),
          const SizedBox(height: AppDimensions.spaceLg),

          // Pet info
          Text(
            _petNameController.text,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSm),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _selectedGender == 'male' ? Icons.male : Icons.female,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Text(
                _selectedBreed ?? 'Mixed breed',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceLg),

          // Story
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.paddingLg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Text(
              _getPreviewStory(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
      action: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Apa masih ada yang perlu diubah?',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          Row(
            children: [
              Expanded(
                child: AppButton.secondary(
                  text: 'Edit',
                  onPressed: _previousStep,
                  icon: Icons.edit,
                ),
              ),
              const SizedBox(width: AppDimensions.spaceLg),
              Expanded(
                child: AppButton.primary(
                  text: 'Save',
                  onPressed: _handleSubmit,
                  icon: Icons.check,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Stack(
      children: [
        StoryStep(
          title: 'All Done! 🎉',
          subtitle: 'Your pet\'s story has been created successfully!',
          content: Column(
            children: [
              Icon(Icons.check_circle, size: 80, color: AppColors.success),
              const SizedBox(height: AppDimensions.spaceLg),
              Text(
                'Welcome to Allnimall!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          action: AppButton.primary(
            text: 'Let\'s Explore',
            onPressed: () {
              // Navigate to pet profile or dashboard
              context.go(AppRoutes.dashboard);
            },
            icon: Icons.explore,
          ),
        ),
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 1.5708, // Downward
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              AppColors.primary,
              AppColors.success,
              Colors.orange,
              Colors.pink,
            ],
          ),
        ),
      ],
    );
  }
}
