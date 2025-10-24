import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/pet_providers.dart';

class GalleryTab extends ConsumerWidget {
  final String petId;

  const GalleryTab({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(petPhotosProvider(petId));

    return photosAsync.when(
      data: (photos) {
        if (photos.isEmpty) {
          return const EmptyState(
            icon: Icons.photo_library,
            title: 'Belum Ada Foto',
            message: 'Pemilik belum menambahkan foto',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.paddingMd),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppDimensions.spaceMd,
            mainAxisSpacing: AppDimensions.spaceMd,
            childAspectRatio: 1,
          ),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            final photo = photos[index];
            return GestureDetector(
              onTap: () {
                _showPhotoViewer(context, photos, index);
              },
              child: Hero(
                tag: 'photo-${photo.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: photo.photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.greyLight,
                          child: const Center(
                            child: LoadingIndicator(size: 30),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.greyLight,
                          child: const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                          ),
                        ),
                      ),

                      // Primary Badge
                      if (photo.isPrimary)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingSm,
                              vertical: AppDimensions.paddingXs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusSm,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 12,
                                  color: AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.refresh(petPhotosProvider(petId)),
      ),
    );
  }

  void _showPhotoViewer(BuildContext context, List photos, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            PageView.builder(
              itemCount: photos.length,
              controller: PageController(initialPage: initialIndex),
              itemBuilder: (context, index) {
                final photo = photos[index];
                return Center(
                  child: Hero(
                    tag: 'photo-${photo.id}',
                    child: CachedNetworkImage(
                      imageUrl: photo.photoUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: LoadingIndicator(color: AppColors.white),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error_outline,
                        color: AppColors.white,
                        size: 64,
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.white, size: 32),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
