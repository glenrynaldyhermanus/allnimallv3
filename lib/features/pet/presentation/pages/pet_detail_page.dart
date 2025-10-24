import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/pet_providers.dart';

class PetDetailPage extends ConsumerStatefulWidget {
  final String petId;

  const PetDetailPage({super.key, required this.petId});

  @override
  ConsumerState<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends ConsumerState<PetDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petAsync = ref.watch(petByIdProvider(widget.petId));

    return Scaffold(
      body: petAsync.when(
        data: (pet) => _buildPetProfile(pet),
        loading: () => const Scaffold(body: Center(child: LoadingIndicator())),
        error: (error, stack) => Scaffold(
          body: ErrorState(
            message: error.toString(),
            onRetry: () => ref.refresh(petByIdProvider(widget.petId)),
          ),
        ),
      ),
    );
  }

  Widget _buildPetProfile(pet) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        // Hero Section
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Pet Photo
                pet.pictureUrl != null
                    ? CachedNetworkImage(
                        imageUrl: pet.pictureUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: AppColors.heroGradient,
                          ),
                        ),
                        child: const Icon(
                          Icons.pets,
                          size: 80,
                          color: AppColors.white,
                        ),
                      ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
                // Pet info overlay
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet.breed ?? 'Pet'} • ${pet.ageDisplay} • ${pet.gender == 'male' ? 'Jantan' : 'Betina'}',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Profil'),
                    ],
                  ),
                  onTap: () {
                    if (context.mounted) {
                      Future.delayed(Duration.zero, () {
                        if (context.mounted) {
                          context.push(
                            AppRoutes.petEdit.replaceAll(
                              ':petId',
                              widget.petId,
                            ),
                          );
                        }
                      });
                    }
                  },
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.location_on, size: 20),
                      SizedBox(width: 8),
                      Text('Riwayat Pindaian'),
                    ],
                  ),
                  onTap: () {
                    if (context.mounted) {
                      Future.delayed(Duration.zero, () {
                        if (context.mounted) {
                          context.push(
                            AppRoutes.scanHistory.replaceAll(
                              ':petId',
                              widget.petId,
                            ),
                          );
                        }
                      });
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      body: Column(
        children: [
          // Quick Actions
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLg,
              vertical: AppDimensions.paddingMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton('Call', Icons.phone, () {
                    // TODO: Implement call functionality
                  }),
                ),
                const SizedBox(width: AppDimensions.spaceMd),
                Expanded(
                  child: _buildQuickActionButton('Map', Icons.location_on, () {
                    // TODO: Implement location functionality
                  }),
                ),
                const SizedBox(width: AppDimensions.spaceMd),
                Expanded(
                  child: _buildQuickActionButton('Share', Icons.share, () {
                    // TODO: Implement share functionality
                  }),
                ),
              ],
            ),
          ),
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.grey.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              labelStyle: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'Info'),
                Tab(text: 'Kesehatan'),
                Tab(text: 'Galeri'),
                Tab(text: 'QR'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(pet),
                _buildHealthTab(pet),
                _buildGalleryTab(pet),
                _buildQRTab(pet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String text,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingSm,
          vertical: AppDimensions.paddingSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(pet) {
    final hasBasicInfo =
        pet.color != null || pet.weight != null || pet.microchipId != null;
    final hasContact = pet.emergencyContact != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Informasi Dasar',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(
                          AppRoutes.petEdit.replaceAll(':petId', widget.petId),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasBasicInfo ? Icons.edit : Icons.add,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasBasicInfo ? 'Edit' : 'Tambah',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                if (!hasBasicInfo)
                  _buildEmptyState(
                    'Belum ada informasi dasar',
                    'Tap "Tambah" untuk menambahkan warna, berat, atau microchip ID',
                    Icons.info_outline,
                  )
                else ...[
                  if (pet.color != null)
                    _buildInfoRow('Warna', pet.color!, Icons.palette),

                  if (pet.weight != null)
                    _buildInfoRow(
                      'Berat',
                      '${pet.weight} kg',
                      Icons.monitor_weight,
                    ),

                  if (pet.microchipId != null)
                    _buildInfoRow(
                      'Microchip ID',
                      pet.microchipId!,
                      Icons.credit_card,
                    ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLg),

          // Owner Contact Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kontak Darurat',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(
                          AppRoutes.petEdit.replaceAll(':petId', widget.petId),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasContact ? Icons.edit : Icons.add,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasContact ? 'Edit' : 'Tambah',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                if (!hasContact)
                  _buildEmptyState(
                    'Belum ada kontak darurat',
                    'Tap "Tambah" untuk menambahkan nomor telepon darurat',
                    Icons.phone_disabled,
                  )
                else
                  _buildInfoRow('Telepon', pet.emergencyContact!, Icons.phone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      decoration: BoxDecoration(
        color: AppColors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(
          color: AppColors.grey.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppColors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: AppDimensions.spaceSm),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.spaceXs),
          Text(
            subtitle,
            style: GoogleFonts.nunito(fontSize: 12, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthTab(pet) {
    final hasHealthNotes = pet.notes != null && pet.notes!.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Status Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Catatan Kesehatan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(
                          AppRoutes.petEdit.replaceAll(':petId', widget.petId),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasHealthNotes ? Icons.edit : Icons.add,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasHealthNotes ? 'Edit' : 'Tambah',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                if (!hasHealthNotes)
                  _buildEmptyState(
                    'Belum ada catatan kesehatan',
                    'Tap "Tambah" untuk menambahkan catatan vaksin, alergi, atau kondisi medis',
                    Icons.medical_information_outlined,
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note, size: 20, color: AppColors.primary),
                          const SizedBox(width: AppDimensions.spaceSm),
                          Text(
                            'Catatan',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spaceXs),
                      Text(
                        pet.notes!,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryTab(pet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Galeri Foto',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMd),

          // Photo Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.spaceMd,
              mainAxisSpacing: AppDimensions.spaceMd,
              childAspectRatio: 1,
            ),
            itemCount: 6, // Mock data
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(Icons.image, size: 48, color: AppColors.grey),
              );
            },
          ),

          const SizedBox(height: AppDimensions.spaceMd),
          Text(
            'Foto terbaru • 3 hari lalu',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRTab(pet) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.paddingLg),
      child: Column(
        children: [
          // QR Code Card
          AppCard(
            child: Column(
              children: [
                const Icon(Icons.qr_code, size: 120, color: AppColors.primary),
                const SizedBox(height: AppDimensions.spaceMd),
                Text(
                  'QR Code Pet',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceXs),
                Text(
                  'ID: ${pet.id.substring(0, 8)}...',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMd),
                Text(
                  'Tap untuk share atau scan',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppDimensions.spaceLg),

          // Statistics Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistik',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceMd),

                _buildInfoRow('Dilihat', '24 kali', Icons.visibility),
                _buildInfoRow('Terakhir', '2 jam lalu', Icons.schedule),
                _buildInfoRow('Lokasi', 'Jakarta Selatan', Icons.location_on),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
