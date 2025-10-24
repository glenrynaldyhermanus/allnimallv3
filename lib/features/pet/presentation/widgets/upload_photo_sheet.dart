import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/pet_timeline_entity.dart';
import '../providers/pet_providers.dart';

class UploadPhotoSheet extends ConsumerStatefulWidget {
  final String petId;
  final VoidCallback onSuccess;

  const UploadPhotoSheet({
    super.key,
    required this.petId,
    required this.onSuccess,
  });

  @override
  ConsumerState<UploadPhotoSheet> createState() => _UploadPhotoSheetState();
}

class _UploadPhotoSheetState extends ConsumerState<UploadPhotoSheet> {
  XFile? _selectedFile;
  String? _uploadedUrl; // URL hasil upload
  Map<String, dynamic>? _uploadedMetadata; // Metadata hasil upload
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _hashtagController = TextEditingController();
  final List<String> _hashtags = [];
  bool _isUploading = false;
  bool _isSaving = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _captionController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      AppLogger.info('📸 Starting image picker with source: $source');

      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      AppLogger.info(
        '📸 Image picker returned: ${file != null ? file.path : 'null'}',
      );

      if (file != null) {
        AppLogger.info('📸 File selected, starting upload process...');

        setState(() {
          _selectedFile = file;
          _isUploading = true;
          _uploadProgress = 0.0;
        });

        AppLogger.info('📸 State updated, calling _uploadToStorage');

        // Langsung upload ke Supabase Storage
        await _uploadToStorage(file);

        AppLogger.info('📸 _uploadToStorage completed');
      } else {
        AppLogger.warning('📸 No file selected (user cancelled?)');
      }
    } catch (e, stackTrace) {
      AppLogger.error('📸 Error in _pickMedia', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking media: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _uploadToStorage(XFile file) async {
    try {
      AppLogger.info('🚀 Starting upload to storage');
      AppLogger.info('🚀 File path: ${file.path}');
      AppLogger.info('🚀 Pet ID: ${widget.petId}');

      setState(() => _uploadProgress = 0.3);
      AppLogger.info('🚀 Progress set to 30%');

      // Upload langsung dari XFile (web-compatible)
      AppLogger.info('🚀 Reading file bytes...');
      final bytes = await file.readAsBytes();
      AppLogger.info('🚀 File size: ${bytes.length} bytes');

      // Pakai file.name untuk dapat extension yang benar (web-compatible)
      final fileName = file.name;
      final extension = fileName.split('.').last.toLowerCase();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uploadFileName = '${widget.petId}/photo_$timestamp.$extension';

      AppLogger.info('🚀 Original filename: $fileName');
      AppLogger.info('🚀 Extension: $extension');
      AppLogger.info('🚀 Upload filename: $uploadFileName');

      // Determine correct MIME type
      String mimeType;
      if (extension == 'jpg' || extension == 'jpeg') {
        mimeType = 'image/jpeg';
      } else if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'gif') {
        mimeType = 'image/gif';
      } else if (extension == 'webp') {
        mimeType = 'image/webp';
      } else {
        mimeType = 'image/jpeg'; // default
      }

      AppLogger.info('🚀 MIME type: $mimeType');

      // Upload ke Supabase Storage
      AppLogger.info('🚀 Uploading to Supabase Storage bucket: pet-media');
      await SupabaseConfig.instance.storage
          .from('pet-media')
          .uploadBinary(
            uploadFileName,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );

      AppLogger.info('🚀 Upload to storage successful!');
      setState(() => _uploadProgress = 0.9);

      // Get public URL
      final photoUrl = SupabaseConfig.instance.storage
          .from('pet-media')
          .getPublicUrl(uploadFileName);
      AppLogger.info('🚀 Public URL: $photoUrl');

      final uploadedMetadata = {
        'photo_url': photoUrl,
        'mime_type': mimeType,
        'file_size': bytes.length,
      };

      if (mounted) {
        setState(() {
          _uploadProgress = 1.0;
          _uploadedUrl = photoUrl;
          _uploadedMetadata = uploadedMetadata;
        });
      }

      AppLogger.info('🚀 Upload complete! URL stored in state');
      AppLogger.info('🚀 _uploadedUrl: $_uploadedUrl');
      AppLogger.info('🚀 _uploadedMetadata: $_uploadedMetadata');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo uploaded to storage!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        AppLogger.info('🚀 Success snackbar shown');
      }
    } catch (e, stackTrace) {
      AppLogger.error('🚀 ERROR in _uploadToStorage', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 5),
          ),
        );
        // Jangan reset _selectedFile, biar preview tetap ada
        setState(() {
          _uploadedUrl = null;
          _uploadedMetadata = null;
        });
      }
    } finally {
      if (mounted) {
        AppLogger.info(
          '🚀 Upload process finished, setting _isUploading = false',
        );
        setState(() => _isUploading = false);
      }
    }
  }

  void _addHashtag() {
    final tag = _hashtagController.text.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_hashtags.contains(tag)) {
      setState(() {
        _hashtags.add(tag);
        _hashtagController.clear();
      });
    }
  }

  void _removeHashtag(String tag) {
    setState(() => _hashtags.remove(tag));
  }

  Future<void> _saveToDatabase() async {
    AppLogger.info('💾 Save button clicked');

    if (_uploadedUrl == null || _uploadedMetadata == null) {
      AppLogger.warning('💾 Cannot save: URL or metadata is null');
      AppLogger.warning('💾 _uploadedUrl: $_uploadedUrl');
      AppLogger.warning('💾 _uploadedMetadata: $_uploadedMetadata');
      return;
    }

    setState(() => _isSaving = true);
    AppLogger.info('💾 _isSaving = true');

    try {
      // Insert ke database dengan semua metadata
      final dataSource = ref.read(petRemoteDataSourceProvider);
      AppLogger.info('💾 Got dataSource');

      final photoData = {
        'pet_id': widget.petId,
        ..._uploadedMetadata!,
        'caption': _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
        'hashtags': _hashtags.isEmpty ? null : _hashtags,
        'is_primary': false,
        'sort_order': 0,
      };

      AppLogger.info('💾 Photo data prepared: $photoData');
      AppLogger.info('💾 Calling addPetPhoto...');

      await dataSource.addPetPhoto(photoData);

      AppLogger.info('💾 Photo saved to database successfully!');

      // Create timeline entry for media upload
      try {
        final createTimelineUseCase = ref.read(
          createTimelineEntryUseCaseProvider,
        );
        final isVideo = _uploadedMetadata!['media_type'] == 'video';
        final mediaTimeline = PetTimelineEntity(
          id: '',
          petId: widget.petId,
          timelineType: 'media',
          title: isVideo ? '🎬 New Video' : '📸 New Photo',
          caption: _captionController.text.trim().isEmpty
              ? null
              : _captionController.text.trim(),
          mediaUrl: _uploadedUrl,
          mediaType: isVideo ? 'video' : 'image',
          visibility: 'public',
          eventDate: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await createTimelineUseCase(mediaTimeline);
        AppLogger.info('💾 Timeline entry created successfully!');
      } catch (e) {
        AppLogger.error('💾 Error creating timeline entry', e);
        // Don't fail the whole operation if timeline creation fails
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        AppLogger.info('💾 Navigation and snackbar done');
      }
    } catch (e, stackTrace) {
      AppLogger.error('💾 ERROR in _saveToDatabase', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        AppLogger.info('💾 Setting _isSaving = false');
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(LucideIcons.x),
                ),
                const Spacer(),
                Text(
                  'Upload Photo',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    AppLogger.info('💾 Save button tapped!');
                    AppLogger.info('💾 _isSaving: $_isSaving');
                    AppLogger.info('💾 _uploadedUrl: $_uploadedUrl');
                    AppLogger.info(
                      '💾 Button enabled: ${!_isSaving && _uploadedUrl != null}',
                    );

                    if (_isSaving || _uploadedUrl == null) {
                      AppLogger.warning(
                        '💾 Button disabled, not calling _saveToDatabase',
                      );
                      return;
                    }
                    _saveToDatabase();
                  },
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: _uploadedUrl == null
                                ? AppColors.grey
                                : AppColors.quaternary,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Media preview or picker
                  if (_selectedFile == null)
                    _buildMediaPicker()
                  else
                    _buildMediaPreview(),
                  const SizedBox(height: 24),
                  // Caption
                  Text(
                    'Caption',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      hintText: 'Write a caption...',
                      hintStyle: GoogleFonts.nunito(color: AppColors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.greyLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.greyLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.quaternary),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: GoogleFonts.nunito(fontSize: 14),
                    maxLines: 4,
                    enabled: !_isUploading && !_isSaving,
                  ),
                  const SizedBox(height: 24),
                  // Hashtags
                  Text(
                    'Hashtags',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _hashtagController,
                          decoration: InputDecoration(
                            hintText: 'Add hashtag',
                            hintStyle: GoogleFonts.nunito(
                              color: AppColors.grey,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.greyLight,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.greyLight,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.quaternary,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          style: GoogleFonts.nunito(fontSize: 14),
                          onSubmitted: (_) => _addHashtag(),
                          enabled: !_isUploading && !_isSaving,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isUploading || _isSaving
                            ? null
                            : _addHashtag,
                        icon: const Icon(LucideIcons.plus),
                        color: AppColors.quaternary,
                      ),
                    ],
                  ),
                  if (_hashtags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _hashtags.map((tag) {
                        return Chip(
                          label: Text('#$tag'),
                          onDeleted: _isUploading || _isSaving
                              ? null
                              : () => _removeHashtag(tag),
                          backgroundColor: AppColors.quaternary.withValues(
                            alpha: 0.1,
                          ),
                          labelStyle: GoogleFonts.nunito(
                            color: AppColors.quaternary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  // Upload progress
                  if (_isUploading) ...[
                    const SizedBox(height: 24),
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: AppColors.greyLight,
                      color: AppColors.quaternary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Uploading to storage... ${(_uploadProgress * 100).toInt()}%',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                  if (_uploadedUrl != null && !_isUploading) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.circleCheck,
                          color: AppColors.success,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Photo uploaded! Add caption and save.',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPicker() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            AppLogger.info('🎯 Gallery button tapped');
            _pickMedia(ImageSource.gallery);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.grey,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.image,
                    size: 48,
                    color: AppColors.quaternary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to select photo',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.quaternary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'or',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            AppLogger.info('🎯 Camera button tapped');
            _pickMedia(ImageSource.camera);
          },
          icon: const Icon(LucideIcons.camera, size: 20),
          label: Text(
            'Take Photo',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.quaternary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: kIsWeb
              ? FutureBuilder<Uint8List>(
                  future: _selectedFile!.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        height: 300,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    }
                    return const SizedBox(
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                )
              : Image.file(
                  File(_selectedFile!.path),
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            onPressed: _isUploading || _isSaving
                ? null
                : () => setState(() {
                    _selectedFile = null;
                    _uploadedUrl = null;
                    _uploadedMetadata = null;
                  }),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.x,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
