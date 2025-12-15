import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/entities/pet_health_entity.dart';
import '../providers/pet_providers.dart';
import '../widgets/pet_form_widgets.dart';
import '../widgets/pet_calendar_widget.dart';
import '../widgets/schedule_list_tile.dart';
import '../widgets/upload_photo_sheet.dart';
import '../widgets/add_edit_schedule_sheet.dart';
import '../widgets/timeline_item_widget.dart';
import '../widgets/qr_scanner_sheet.dart';
import '../widgets/weight_input_sheet.dart';
import '../widgets/health_sheets/vaccination_status_sheet.dart';
import '../widgets/health_sheets/sterilization_status_sheet.dart';
import '../widgets/health_sheets/overall_health_check_sheet.dart';
import './pet_photo_detail_page.dart';

class PetProfilePage extends ConsumerStatefulWidget {
  final String petId;

  const PetProfilePage({super.key, required this.petId});

  @override
  ConsumerState<PetProfilePage> createState() => _PetProfilePageState();
}

class _PetProfilePageState extends ConsumerState<PetProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _bounceController;
  int _lastTappedIndex = -1;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Invalidate all pet-related data to fetch fresh data from database
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(petByIdProvider(widget.petId));
      ref.invalidate(petHealthProvider(widget.petId));
      ref.invalidate(petTimelinesProvider(widget.petId));
      ref.invalidate(schedulesProvider(widget.petId));
      ref.invalidate(petPhotosProvider(widget.petId));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Widget _buildCustomTabBar() {
    // Define tab colors: [purple, pink, blue, green]
    final tabColors = [
      AppColors.primary, // Timeline - Purple
      AppColors.secondary, // Info (Biodata + Health) - Pink
      AppColors.tertiary, // Calendar - Blue
      AppColors.quaternary, // Gallery - Pink
    ];

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        return Container(
          height: 48,
          child: Row(
            children: List.generate(4, (index) {
              final isSelected = _tabController.index == index;
              final baseColor = tabColors[index];
              final color = isSelected
                  ? baseColor
                  : baseColor.withValues(alpha: 0.4);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _lastTappedIndex = index;
                    _bounceController.forward(from: 0);
                    _tabController.animateTo(index);
                  },
                  child: Container(
                    height: 48,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with bounce animation
                        ScaleTransition(
                          scale: _lastTappedIndex == index
                              ? Tween<double>(begin: 1.0, end: 1.1).animate(
                                  CurvedAnimation(
                                    parent: _bounceController,
                                    curve: Curves.elasticOut,
                                  ),
                                )
                              : const AlwaysStoppedAnimation(1.0),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _getIconForTab(index, isSelected),
                              key: ValueKey('${index}_${isSelected}'),
                              size: 24,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Animated indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 24 : 0,
                          height: 2,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  IconData _getIconForTab(int index, bool isSelected) {
    // Return filled versions when selected, outline when not selected
    switch (index) {
      case 0: // Timeline - clock
        return isSelected ? LucideIcons.clock : LucideIcons.clock;
      case 1: // Info (Biodata + Health) - paw print
        return isSelected ? LucideIcons.pawPrint : LucideIcons.pawPrint;
      case 2: // Calendar - calendar
        return isSelected
            ? LucideIcons.calendarHeart
            : LucideIcons.calendarHeart;
      case 3: // Gallery - image
        return isSelected ? LucideIcons.image : LucideIcons.image;
      default:
        return LucideIcons.clock;
    }
  }

  List<Widget> _buildTabContentAsSlivers(PetEntity pet) {
    final currentIndex = _tabController.index;

    // Create a custom sliver that handles the animation
    return [
      SliverToBoxAdapter(
        child: AnimatedBuilder(
          animation: _tabController,
          builder: (context, child) {
            return TweenAnimationBuilder<double>(
              key: ValueKey('tab_content_$currentIndex'),
              duration: const Duration(milliseconds: 300),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildTabContentWidget(pet, currentIndex),
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildTabContentWidget(PetEntity pet, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return _buildTimelineContent(pet);
      case 1:
        return _buildInfoContent(pet);
      case 2:
        return _buildCalendarContent(pet);
      case 3:
        return _buildGalleryContent(pet);
      default:
        return _buildTimelineContent(pet);
    }
  }

  Widget _buildTimelineContent(PetEntity pet) {
    final timelinesAsync = ref.watch(petTimelinesProvider(pet.id));
    final healthAsync = ref.watch(petHealthProvider(pet.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Actions Section
        healthAsync.when(
          data: (health) => _buildQuickActions(pet, health),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // Timeline Section
        timelinesAsync.when(
          data: (timelines) {
            if (timelines.isEmpty) {
              return Column(
                children: [
                  SectionHeader(title: 'Timeline', color: AppColors.quaternary),
                  const SizedBox(height: 24),
                  EmptyState(
                    icon: LucideIcons.activity,
                    title: 'No Timeline Entries',
                    message: 'Your pet\'s activities will appear here',
                    actionText: null,
                  ),
                ],
              );
            }

            return Column(
              children: [
                ...timelines.map(
                  (timeline) => TimelineItemWidget(
                    timeline: timeline,
                    onTap: () {
                      // Handle timeline item tap
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stack) => EmptyState(
            icon: LucideIcons.info,
            title: 'Error Loading Timeline',
            message: error.toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(PetEntity pet, PetHealthEntity? health) {
    final actions = <Map<String, dynamic>>[];

    // Check if weight is not set
    if (health == null || health.weight == null) {
      actions.add({
        'title': 'Yuk monitor berat badan ${pet.name}',
        'icon': LucideIcons.weight,
        'buttonText': 'Set Berat Badan',
        'color': AppColors.secondary,
        'onTap': () => _showWeightInputSheet(pet, health),
      });
    }

    // Check if vaccination status is not set
    if (health == null || health.vaccinationStatus == null) {
      actions.add({
        'title': 'Apakah ${pet.name} udah divaksin?',
        'icon': LucideIcons.shield,
        'buttonText': 'Update Data Vaksin',
        'color': AppColors.tertiary,
        'onTap': () => _showVaccinationSheet(pet, health),
      });
    }

    // Check if sterilization status is not set (we can add this field later)
    // For now, check if medical conditions mention sterilization
    final isSterilizationMentioned =
        health?.medicalConditions?.any(
          (condition) => condition.toLowerCase().contains('steril'),
        ) ??
        false;

    if (health == null ||
        (!isSterilizationMentioned &&
            health.medicalConditions?.isEmpty != false)) {
      actions.add({
        'title': 'Apakah ${pet.name} udah disteril?',
        'icon': LucideIcons.stethoscope,
        'buttonText': 'Update Data Steril',
        'color': AppColors.quaternary,
        'onTap': () => _showSterilizationSheet(pet, health),
      });
    }

    // If no actions needed, don't show anything
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 4),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < actions.length - 1 ? 12 : 0,
                ),
                child: _buildQuickActionCard(
                  title: action['title'],
                  icon: action['icon'],
                  buttonText: action['buttonText'],
                  color: action['color'],
                  onTap: action['onTap'],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required String buttonText,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                onTap();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoContent(PetEntity pet) {
    final healthAsync = ref.watch(petHealthProvider(pet.id));

    return Column(
      children: [
        // Biodata Section
        SectionHeader(
          title: 'Informasi Dasar',
          color: AppColors.primary,
          onEdit: () => _showEditBiodataSheet(pet),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem(
                icon: LucideIcons.cake,
                label: 'Usia',
                value: pet.ageDisplay,
              ),
              _buildInfoItem(
                icon: pet.gender == 'male' ? Icons.male : Icons.female,
                label: 'Jenis Kelamin',
                value: pet.gender == 'male' ? 'Jantan' : 'Betina',
                iconColor: AppColors.primary,
              ),
              if (pet.breed != null)
                _buildInfoItem(
                  icon: LucideIcons.pawPrint,
                  label: 'Breed',
                  value: pet.breed!,
                ),
              if (pet.color != null)
                _buildInfoItem(
                  icon: LucideIcons.palette,
                  label: 'Color',
                  value: pet.color!,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionHeader(
          title: 'Catatan',
          color: AppColors.primary,
          onEdit: () => _showEditBiodataSheet(pet),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: SizedBox(
            width: double.infinity,
            child: pet.story != null && pet.story!.isNotEmpty
                ? Text(
                    pet.story!,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  )
                : Text(
                    'Tidak ada catatan',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // QR Collar Section
        SectionHeader(
          title: 'QR Collar',
          color: AppColors.primary,
          onEdit: () => _showQRManagementSheet(pet),
        ),
        const SizedBox(height: 12),
        _buildQRCollarCard(pet),
        const SizedBox(height: 24),

        // Health Section
        healthAsync.when(
          data: (health) {
            if (health == null) {
              return Column(
                children: [
                  SectionHeader(
                    title: 'Health Information',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  EmptyState(
                    icon: LucideIcons.heartPulse,
                    title: 'No Health Records',
                    message:
                        'Add health information to keep track of your pet\'s medical history',
                    actionText: 'Add Health Info',
                    onAction: () => _showHealthQuickActions(pet, null),
                  ),
                ],
              );
            }

            return Column(
              children: [
                SectionHeader(
                  title: 'Health Information',
                  color: AppColors.secondary,
                  onEdit: () => _showHealthQuickActions(pet, health),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.greyLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (health.weight != null)
                        _buildInfoItem(
                          icon: LucideIcons.weight,
                          label: 'Current Weight',
                          value: '${health.weight} kg',
                          iconColor: AppColors.secondary,
                        ),
                      if (health.vaccinationStatus != null)
                        _buildInfoItem(
                          icon: LucideIcons.shield,
                          label: 'Vaccination Status',
                          value: health.vaccinationStatus!,
                          iconColor: AppColors.secondary,
                        ),
                      if (health.lastVaccinationDate != null)
                        _buildInfoItem(
                          icon: LucideIcons.calendar,
                          label: 'Last Vaccination',
                          value: DateFormat(
                            'dd MMM yyyy',
                          ).format(health.lastVaccinationDate!),
                          iconColor: AppColors.secondary,
                        ),
                      if (health.nextVaccinationDate != null)
                        _buildInfoItem(
                          icon: LucideIcons.calendarCheck,
                          label: 'Next Vaccination',
                          value: DateFormat(
                            'dd MMM yyyy',
                          ).format(health.nextVaccinationDate!),
                          iconColor: AppColors.secondary,
                        ),
                      if (health.hasMedicalConditions)
                        _buildInfoItem(
                          icon: LucideIcons.stethoscope,
                          label: 'Medical Conditions',
                          value: health.medicalConditions!.join(', '),
                          iconColor: AppColors.secondary,
                        ),
                      if (health.hasAllergies)
                        _buildInfoItem(
                          icon: LucideIcons.triangleAlert,
                          label: 'Allergies',
                          value: health.allergies!.join(', '),
                          iconColor: AppColors.error,
                        ),
                      if (health.healthNotes != null &&
                          health.healthNotes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.fileText,
                                    color: AppColors.secondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Health Notes',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 32),
                                child: Text(
                                  health.healthNotes!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stack) => EmptyState(
            icon: LucideIcons.info,
            title: 'Error Loading Health Data',
            message: error.toString(),
            actionText: 'Add Health Info',
            onAction: () => _showHealthQuickActions(pet, null),
          ),
        ),

        const SizedBox(height: 24),

        // Contact Owner Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.phone,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Contact Owner',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Found this pet? Contact the owner immediately',
                style: GoogleFonts.nunito(fontSize: 14, color: AppColors.grey),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _showContactOptions(pet);
                  },
                  icon: const Icon(
                    LucideIcons.phone,
                    color: AppColors.white,
                    size: 18,
                  ),
                  label: Text(
                    'Contact Owner Now',
                    style: GoogleFonts.poppins(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarContent(PetEntity pet) {
    final schedulesAsync = ref.watch(schedulesProvider(pet.id));

    return schedulesAsync.when(
      data: (schedules) {
        // Get event dates for markers
        final eventDates = schedules.map((s) => s.scheduledAt).toList();

        // Filter schedules for selected day
        final selectedDaySchedules = schedules.where((schedule) {
          return schedule.scheduledAt.year == _selectedDay.year &&
              schedule.scheduledAt.month == _selectedDay.month &&
              schedule.scheduledAt.day == _selectedDay.day;
        }).toList();

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Calendar',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _showAddScheduleSheet(pet, null);
                  },
                  icon: const Icon(
                    LucideIcons.plus,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Calendar widget - compact mode
            PetCalendarWidget(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventDates: eventDates,
              isCompact: true,
            ),
            const SizedBox(height: 16),
            // Schedules for selected day
            if (selectedDaySchedules.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.calendarHeart,
                      size: 48,
                      color: AppColors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No schedules for ${DateFormat('MMM dd, yyyy').format(_selectedDay)}',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedules for ${DateFormat('EEEE, MMM dd').format(_selectedDay)}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...selectedDaySchedules.map(
                    (schedule) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ScheduleListTile(
                        schedule: schedule,
                        onTap: () => _showAddScheduleSheet(pet, schedule),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => EmptyState(
        icon: LucideIcons.calendarHeart,
        title: 'Error Loading Calendar',
        message: error.toString(),
        actionText: 'Add Schedule',
        onAction: () => _showAddScheduleSheet(pet, null),
      ),
    );
  }

  Widget _buildGalleryContent(PetEntity pet) {
    final photosAsync = ref.watch(petPhotosProvider(pet.id));

    return photosAsync.when(
      data: (photos) {
        if (photos.isEmpty) {
          return Column(
            children: [
              SectionHeader(title: 'Gallery', color: AppColors.primary),
              const SizedBox(height: 24),
              EmptyState(
                icon: LucideIcons.image,
                title: 'No Photos Yet',
                message:
                    'Add photos to create a beautiful gallery for your pet',
                actionText: 'Add Photo',
                onAction: () => _showAddPhotoSheet(pet),
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Gallery (${photos.length})',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _showAddPhotoSheet(pet);
                  },
                  icon: const Icon(
                    LucideIcons.plus,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetPhotoDetailPage(
                          photos: photos,
                          initialIndex: index,
                          petId: pet.id,
                        ),
                      ),
                    );
                  },
                  child: _buildPhotoTile(photo, pet),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => EmptyState(
        icon: LucideIcons.info,
        title: 'Error Loading Photos',
        message: error.toString(),
        actionText: 'Add Photo',
        onAction: () => _showAddPhotoSheet(pet),
      ),
    );
  }

  Widget _buildQRCollarCard(PetEntity pet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        children: [
          if (pet.qrId != null) ...[
            // Current QR Code Display
            Row(
              children: [
                const Icon(
                  LucideIcons.qrCode,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR Code',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                      Text(
                        pet.qrId!,
                        style: GoogleFonts.robotoMono(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showRemoveQRDialog(pet),
                  icon: const Icon(LucideIcons.x, color: Colors.red, size: 20),
                ),
              ],
            ),
          ] else ...[
            // No QR Code
            Row(
              children: [
                const Icon(LucideIcons.qrCode, color: AppColors.grey, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QR Collar',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                      Text(
                        'No QR collar assigned',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showQRManagementSheet(pet),
                  icon: const Icon(
                    LucideIcons.plus,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showQRManagementSheet(PetEntity pet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              pet.qrId != null ? 'Update QR Collar' : 'Assign QR Collar',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Scan QR code from your collar or enter manually',
              style: GoogleFonts.nunito(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // QR Scanner Button
            ElevatedButton.icon(
              onPressed: () => _showQRScanner(pet),
              icon: const Icon(LucideIcons.qrCode, size: 20),
              label: const Text('Scan QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Divider
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'or',
                    style: GoogleFonts.nunito(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            // Manual Input Button
            OutlinedButton.icon(
              onPressed: () => _showManualQRInput(pet),
              icon: const Icon(LucideIcons.keyboard, size: 20),
              label: const Text('Enter Manually'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel Button
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQRScanner(PetEntity pet) {
    Navigator.pop(context); // Close management sheet first

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => QRScannerSheet(
        onQRScanned: (qrId) => _performQRAssignment(
          context,
          (setState) {}, // Dummy setState
          pet,
          qrId,
          () {}, // Dummy setLoading
          () {}, // Dummy clearLoading
        ),
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showManualQRInput(PetEntity pet) {
    Navigator.pop(context); // Close management sheet first

    final qrIdController = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Enter QR Code Manually',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-character QR code from your collar',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: qrIdController,
                decoration: InputDecoration(
                  labelText: 'QR Code',
                  hintText: 'ABC123',
                  prefixIcon: const Icon(LucideIcons.qrCode),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: '',
                ),
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                onChanged: (value) {
                  setState(() {
                    qrIdController.text = value.toUpperCase();
                    qrIdController.selection = TextSelection.fromPosition(
                      TextPosition(offset: qrIdController.text.length),
                    );
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'QR code is required';
                  }
                  if (value.length != 6) {
                    return 'QR code must be 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _performQRAssignment(
                              context,
                              setState,
                              pet,
                              qrIdController.text,
                              () => setState(() => isLoading = true),
                              () => setState(() => isLoading = false),
                            ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(pet.qrId != null ? 'Update' : 'Assign'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performQRAssignment(
    BuildContext context,
    StateSetter setState,
    PetEntity pet,
    String qrId,
    VoidCallback setLoading,
    VoidCallback clearLoading,
  ) async {
    if (qrId.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code must be 6 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setLoading();

    try {
      // Update pet with QR ID
      final updatedPet = pet.copyWith(qrId: qrId);
      await ref.read(updatePetUseCaseProvider)(updatedPet);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code $qrId berhasil di-assign ke ${pet.name}!'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh pet data
        ref.invalidate(petByIdProvider(pet.id));
      }
    } catch (e) {
      clearLoading();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal assign QR code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRemoveQRDialog(PetEntity pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove QR Collar'),
        content: Text(
          'Are you sure you want to remove QR code ${pet.qrId} from ${pet.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performQRRemoval(pet);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _performQRRemoval(PetEntity pet) async {
    try {
      // Remove QR ID from pet
      final updatedPet = pet.copyWith(qrId: null);
      await ref.read(updatePetUseCaseProvider)(updatedPet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR code berhasil di-remove dari ${pet.name}'),
            backgroundColor: Colors.orange,
          ),
        );

        // Refresh pet data
        ref.invalidate(petByIdProvider(pet.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal remove QR code: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Modal sheet for editing biodata
  void _showEditBiodataSheet(PetEntity pet) {
    final nameController = TextEditingController(text: pet.name);
    final breedController = TextEditingController(text: pet.breed);
    final colorController = TextEditingController(text: pet.color);
    final notesController = TextEditingController(text: pet.story);
    final emergencyController = TextEditingController(
      text: pet.emergencyContact,
    );

    DateTime? selectedBirthDate = pet.birthDate;
    String? selectedGender = pet.gender;
    XFile? selectedPhoto;
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: PetFormBottomSheet(
            title: 'Edit Biodata',
            isLoading: isLoading,
            onSave: () async {
              setState(() => isLoading = true);

              try {
                final updateUseCase = ref.read(updatePetUseCaseProvider);
                final updatedPet = pet.copyWith(
                  name: nameController.text.trim(),
                  breed: breedController.text.trim().isEmpty
                      ? null
                      : breedController.text.trim(),
                  color: colorController.text.trim().isEmpty
                      ? null
                      : colorController.text.trim(),
                  story: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                  emergencyContact: emergencyController.text.trim().isEmpty
                      ? null
                      : emergencyController.text.trim(),
                  birthDate: selectedBirthDate,
                  gender: selectedGender,
                );

                final result = await updateUseCase(updatedPet);

                result.fold(
                  (failure) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${failure.message}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  (success) {
                    if (context.mounted) {
                      ref.invalidate(petByIdProvider(pet.id));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Biodata updated successfully'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } finally {
                if (context.mounted) {
                  setState(() => isLoading = false);
                }
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profile Photo',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        HapticFeedback.selectionClick();
                        final picker = ImagePicker();
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 1024,
                          maxHeight: 1024,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          setState(() => selectedPhoto = image);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.greyLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: selectedPhoto != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? FutureBuilder<Uint8List>(
                                        future: selectedPhoto!.readAsBytes(),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            );
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      )
                                    : Image.file(
                                        File(selectedPhoto!.path),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                              )
                            : pet.pictureUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: pet.pictureUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.camera,
                                    color: AppColors.grey,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap to select photo',
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: nameController,
                  label: 'Nama Pet',
                  hint: 'Enter pet name',
                  prefixIcon: LucideIcons.pawPrint,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: breedController,
                  label: 'Breed',
                  hint: 'Enter breed',
                  prefixIcon: LucideIcons.pawPrint,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: colorController,
                  label: 'Color',
                  hint: 'Enter color',
                  prefixIcon: LucideIcons.palette,
                ),
                const SizedBox(height: 16),
                PetDatePickerField(
                  label: 'Birth Date',
                  selectedDate: selectedBirthDate,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedBirthDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedBirthDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                GenderSelector(
                  selectedGender: selectedGender,
                  onChanged: (value) => setState(() => selectedGender = value),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: emergencyController,
                  label: 'Emergency Contact',
                  hint: 'Enter emergency contact',
                  prefixIcon: LucideIcons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: notesController,
                  label: 'Notes',
                  hint: 'Add notes about your pet',
                  prefixIcon: LucideIcons.fileText,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Modal sheet for health quick actions
  void _showHealthQuickActions(PetEntity pet, PetHealthEntity? health) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
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
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Update Health Info',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih data kesehatan yang ingin diupdate:',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: AppColors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildHealthActionTile(
                      icon: LucideIcons.weight,
                      title: 'Berat Badan',
                      subtitle: 'Update berat badan ${pet.name}',
                      color: AppColors.secondary,
                      onTap: () {
                        Navigator.pop(context);
                        _showWeightInputSheet(pet, health);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildHealthActionTile(
                      icon: LucideIcons.syringe,
                      title: 'Status Vaksinasi',
                      subtitle: 'Update status vaksinasi',
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.pop(context);
                        _showVaccinationSheet(pet, health);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildHealthActionTile(
                      icon: LucideIcons.shield,
                      title: 'Status Sterilisasi',
                      subtitle: 'Update status sterilisasi/kastrasi',
                      color: AppColors.success,
                      onTap: () {
                        Navigator.pop(context);
                        _showSterilizationSheet(pet, health);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildHealthActionTile(
                      icon: LucideIcons.clipboardCheck,
                      title: 'Cek Kesehatan',
                      subtitle: 'Cek parasit & kualitas kotoran',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.pop(context);
                        _showOverallHealthCheckSheet(pet, health);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: AppColors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Modal sheet for weight input
  void _showWeightInputSheet(PetEntity pet, PetHealthEntity? health) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => WeightInputSheet(pet: pet, health: health),
    );
  }

  // Modal sheet for vaccination status
  void _showVaccinationSheet(PetEntity pet, PetHealthEntity? health) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => VaccinationStatusSheet(pet: pet, health: health),
    );
  }

  // Modal sheet for sterilization status
  void _showSterilizationSheet(PetEntity pet, PetHealthEntity? health) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SterilizationStatusSheet(pet: pet, health: health),
    );
  }

  // Modal sheet for overall health check
  void _showOverallHealthCheckSheet(PetEntity pet, PetHealthEntity? health) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => OverallHealthCheckSheet(pet: pet, health: health),
    );
  }

  // Modal sheet for add/edit schedule
  void _showAddScheduleSheet(PetEntity pet, dynamic schedule) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddEditScheduleSheet(
        petId: pet.id,
        schedule: schedule,
        onSuccess: () {
          // Refresh schedules list
          ref.invalidate(schedulesProvider(pet.id));
        },
      ),
    );
  }

  // Modal sheet for adding photo
  void _showAddPhotoSheet(PetEntity pet) {
    AppLogger.info('📷 _showAddPhotoSheet called for pet: ${pet.id}');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        AppLogger.info('📷 UploadPhotoSheet builder called');
        return UploadPhotoSheet(
          petId: pet.id,
          onSuccess: () {
            AppLogger.info(
              '📷 onSuccess callback - invalidating photos and timeline',
            );
            ref.invalidate(petPhotosProvider(pet.id));
            ref.invalidate(petTimelinesProvider(pet.id));
          },
        );
      },
    );
    AppLogger.info('📷 showModalBottomSheet called');
  }

  // Helper method for photo tile
  Widget _buildPhotoTile(dynamic photo, PetEntity pet) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image or video thumbnail
          CachedNetworkImage(
            imageUrl: photo.isVideo && photo.thumbnailUrl != null
                ? photo.thumbnailUrl!
                : photo.photoUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColors.greyLight,
              child: const Center(child: LoadingIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.greyLight,
              child: const Icon(
                LucideIcons.image,
                size: 32,
                color: AppColors.grey,
              ),
            ),
          ),
          // Video indicator
          if (photo.isVideo)
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.play,
                      size: 12,
                      color: AppColors.white,
                    ),
                    if (photo.formattedDuration.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Text(
                        photo.formattedDuration,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          // Like count
          if (photo.likeCount > 0)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.heart,
                      size: 12,
                      color: AppColors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      photo.likeCount.toString(),
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Primary indicator
          if (photo.isPrimary == true)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  LucideIcons.star,
                  size: 12,
                  color: AppColors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showContactOptions(PetEntity pet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Pet Owner',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you\'d like to contact ${pet.name}\'s owner:',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.phone,
                        color: AppColors.success,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Call Owner',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Call directly',
                      style: GoogleFonts.nunito(color: AppColors.grey),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showNotImplemented('Phone call');
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.messageSquare,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      'Send SMS',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Text message',
                      style: GoogleFonts.nunito(color: AppColors.grey),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showNotImplemented('SMS');
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotImplemented(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$feature feature coming soon!',
          style: GoogleFonts.nunito(color: AppColors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(petByIdProvider(widget.petId));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: petAsync.when(
        data: (pet) {
          // Note: Removed isNewCollar redirect logic
          // Pet creation is now handled in user/new flow

          return CustomScrollView(
            slivers: [
              // SliverAppBar - Header dengan Home Icon
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.white,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.go(AppRoutes.dashboard);
                  },
                  icon: const Icon(
                    LucideIcons.house,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
                expandedHeight: 240,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.only(top: 80, bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Circle Avatar
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primary,
                          backgroundImage: pet.pictureUrl != null
                              ? CachedNetworkImageProvider(pet.pictureUrl!)
                              : null,
                          child: pet.pictureUrl == null
                              ? const Icon(
                                  LucideIcons.pawPrint,
                                  size: 44,
                                  color: AppColors.white,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        // Name and Gender Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                pet.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              pet.gender == 'male' ? Icons.male : Icons.female,
                              size: 24,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Breed/Type
                        Flexible(
                          child: Text(
                            pet.breed ?? 'Unknown Breed',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // SliverPersistentHeader - Custom Colored Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  Container(
                    color: AppColors.white,
                    child: _buildCustomTabBar(),
                  ),
                ),
              ),

              // Tab Content as Slivers
              ..._buildTabContentAsSlivers(pet),
            ],
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.refresh(petByIdProvider(widget.petId)),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
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

// Custom SliverPersistentHeaderDelegate untuk TabBar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return tabBar;
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
