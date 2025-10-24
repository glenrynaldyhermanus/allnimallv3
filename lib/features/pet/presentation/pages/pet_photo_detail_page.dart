import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/pet_photo_entity.dart';
import '../../domain/entities/photo_comment_entity.dart';
import '../providers/pet_providers.dart';
import '../widgets/comment_input_widget.dart';
import '../widgets/share_options_sheet.dart';

class PetPhotoDetailPage extends ConsumerStatefulWidget {
  final List<PetPhotoEntity> photos;
  final int initialIndex;
  final String petId;

  const PetPhotoDetailPage({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.petId,
  });

  @override
  ConsumerState<PetPhotoDetailPage> createState() => _PetPhotoDetailPageState();
}

class _PetPhotoDetailPageState extends ConsumerState<PetPhotoDetailPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showComments = false;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  Map<String, bool> _likedPhotos = {}; // Track liked state per photo ID

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeVideo();
    _checkLikedStatus();
  }

  void _checkLikedStatus() async {
    final useCase = ref.read(isPhotoLikedUseCaseProvider);
    final photosAsync = ref.read(petPhotosProvider(widget.petId));

    photosAsync.whenData((photos) {
      for (final photo in photos) {
        useCase(
          photoId: photo.id,
          ip: 'demo-ip', // Use same IP as like/unlike
        ).then((result) {
          result.fold((failure) => null, (isLiked) {
            if (mounted) {
              setState(() => _likedPhotos[photo.id] = isLiked);
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideo() async {
    final photosAsync = ref.read(petPhotosProvider(widget.petId));
    photosAsync.whenData((photos) {
      if (_currentIndex < photos.length) {
        final currentPhoto = photos[_currentIndex];
        if (currentPhoto.isVideo) {
          _videoController?.dispose();
          _videoController = VideoPlayerController.networkUrl(
            Uri.parse(currentPhoto.photoUrl),
          );
          _videoController!.initialize().then((_) {
            setState(() => _isVideoInitialized = true);
            _videoController!.play();
          });
        } else {
          _videoController?.dispose();
          _videoController = null;
          setState(() => _isVideoInitialized = false);
        }
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    _initializeVideo();
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(petPhotosProvider(widget.petId));

    return photosAsync.when(
      data: (photos) {
        if (photos.isEmpty || _currentIndex >= photos.length) {
          return const Scaffold(
            backgroundColor: AppColors.black,
            body: Center(
              child: Text(
                'No photos available',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final currentPhoto = photos[_currentIndex];
        return _buildPhotoView(currentPhoto);
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: Text(
            'Error loading photos: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoView(PetPhotoEntity currentPhoto) {
    final photosAsync = ref.watch(petPhotosProvider(widget.petId));

    return photosAsync.when(
      data: (photos) {
        return Scaffold(
          backgroundColor: AppColors.black,
          body: Stack(
            children: [
              // Photo/Video Viewer
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return _buildMediaView(photo);
                },
              ),

              // Top Bar
              Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

              // Bottom Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControls(currentPhoto),
              ),

              // Comments Sheet
              if (_showComments)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => setState(() => _showComments = false),
                    child: Container(
                      color: Colors.black54,
                      child: GestureDetector(
                        onTap: () {}, // Prevent closing when tapping sheet
                        child: _buildCommentsSheet(currentPhoto),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: AppColors.black,
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: Text(
            'Error loading photos: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaView(PetPhotoEntity photo) {
    if (photo.isVideo && _videoController != null && _isVideoInitialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoController!),
              // Play/pause overlay
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        LucideIcons.play,
                        size: 80,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: photo.photoUrl,
          fit: BoxFit.contain,
          placeholder: (context, url) => const LoadingIndicator(),
          errorWidget: (context, url, error) =>
              const Icon(LucideIcons.image, size: 80, color: AppColors.grey),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.black.withValues(alpha: 0.7), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(LucideIcons.x, color: AppColors.white),
          ),
          const Spacer(),
          Text(
            '${_currentIndex + 1} / ${widget.photos.length}',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(PetPhotoEntity photo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [AppColors.black.withValues(alpha: 0.8), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action buttons
          Row(
            children: [
              _buildActionButton(
                icon: (_likedPhotos[photo.id] ?? false)
                    ? Icons.favorite
                    : Icons.favorite_border,
                label: photo.likeCount.toString(),
                onTap: () => _handleLike(photo),
                color: (_likedPhotos[photo.id] ?? false)
                    ? Colors.red
                    : AppColors.white,
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: LucideIcons.messageCircle,
                label: photo.commentCount.toString(),
                onTap: () => setState(() => _showComments = !_showComments),
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                icon: LucideIcons.share2,
                label: photo.shareCount.toString(),
                onTap: () => _showShareSheet(photo),
              ),
            ],
          ),
          if (photo.caption != null) ...[
            const SizedBox(height: 16),
            Text(
              photo.caption!,
              style: GoogleFonts.nunito(color: AppColors.white, fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (photo.hashtagList.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: photo.hashtagList.map((tag) {
                return Text(
                  '#$tag',
                  style: GoogleFonts.nunito(
                    color: AppColors.tertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color ?? AppColors.white, size: 24),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSheet(PetPhotoEntity photo) {
    final commentsAsync = ref.watch(photoCommentsProvider(photo.id));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Comments',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => setState(() => _showComments = false),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Comments list
              Expanded(
                child: commentsAsync.when(
                  data: (comments) {
                    if (comments.isEmpty) {
                      return Center(
                        child: Text(
                          'No comments yet',
                          style: GoogleFonts.nunito(color: AppColors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return _buildCommentTile(comment);
                      },
                    );
                  },
                  loading: () => const Center(child: LoadingIndicator()),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading comments',
                      style: GoogleFonts.nunito(color: AppColors.error),
                    ),
                  ),
                ),
              ),
              // Comment input
              CommentInputWidget(
                photoId: photo.id,
                onCommentAdded: () {
                  ref.invalidate(photoCommentsProvider(photo.id));
                  ref.invalidate(petPhotosProvider(widget.petId));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentTile(PhotoCommentEntity comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              (comment.commenterName ?? 'A')[0].toUpperCase(),
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.commenterName ?? 'Anonymous',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.commentText,
                  style: GoogleFonts.nunito(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleLike(PetPhotoEntity photo) async {
    HapticFeedback.lightImpact();

    final isLiked = _likedPhotos[photo.id] ?? false;

    if (isLiked) {
      // Unlike
      final unlikeUseCase = ref.read(unlikePhotoUseCaseProvider);
      await unlikeUseCase(photoId: photo.id, ip: 'demo-ip');
      setState(() => _likedPhotos[photo.id] = false);
    } else {
      // Like
      final likeUseCase = ref.read(likePhotoUseCaseProvider);
      await likeUseCase(photoId: photo.id, ip: 'demo-ip');
      setState(() => _likedPhotos[photo.id] = true);
    }

    // Refresh photos to update count
    ref.invalidate(petPhotosProvider(widget.petId));
  }

  void _showShareSheet(PetPhotoEntity photo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ShareOptionsSheet(photoId: photo.id, photoUrl: photo.photoUrl),
    );
  }
}
