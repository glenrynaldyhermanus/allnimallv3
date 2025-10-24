import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../error/exceptions.dart' as exceptions;
import '../utils/logger.dart';

class StorageService {
  final SupabaseClient _supabase;
  static const String bucketName = 'allnimall-pet';

  StorageService({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseConfig.instance;

  /// Upload pet photo to Supabase Storage
  /// Path format: allnimall-pet/{ownerId}/{petId}/timestamp.png
  Future<String> uploadPetPhoto({
    required String ownerId,
    required String petId,
    required XFile imageFile,
  }) async {
    try {
      AppLogger.info('Uploading pet photo for pet: $petId');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last;
      final fileName = '$timestamp.$extension';
      final path = '$ownerId/$petId/$fileName';

      // Read file bytes
      final bytes = await imageFile.readAsBytes();

      // Upload to Supabase Storage
      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(extension),
              upsert: false,
            ),
          );

      // Get public URL
      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(path);

      AppLogger.info('Photo uploaded successfully: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      AppLogger.error('Storage error uploading photo', e);
      throw exceptions.UploadException('Failed to upload photo: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error uploading photo', e, stackTrace);
      throw exceptions.UploadException(
        'Failed to upload photo: ${e.toString()}',
      );
    }
  }

  /// Upload multiple pet photos
  Future<List<String>> uploadMultiplePetPhotos({
    required String ownerId,
    required String petId,
    required List<XFile> imageFiles,
  }) async {
    final urls = <String>[];

    for (final imageFile in imageFiles) {
      try {
        final url = await uploadPetPhoto(
          ownerId: ownerId,
          petId: petId,
          imageFile: imageFile,
        );
        urls.add(url);
      } catch (e) {
        AppLogger.error('Error uploading photo in batch', e);
        // Continue with next photo
      }
    }

    return urls;
  }

  /// Delete pet photo from Supabase Storage
  Future<void> deletePetPhoto(String photoUrl) async {
    try {
      AppLogger.info('Deleting pet photo: $photoUrl');

      // Extract path from public URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;

      // Find bucket index and construct path
      final bucketIndex = pathSegments.indexOf(bucketName);
      if (bucketIndex == -1) {
        throw exceptions.StorageException('Invalid photo URL');
      }

      final path = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage.from(bucketName).remove([path]);

      AppLogger.info('Photo deleted successfully');
    } on StorageException catch (e) {
      AppLogger.error('Storage error deleting photo', e);
      throw exceptions.StorageException('Failed to delete photo: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting photo', e, stackTrace);
      throw exceptions.StorageException(
        'Failed to delete photo: ${e.toString()}',
      );
    }
  }

  /// Delete all photos for a pet
  Future<void> deleteAllPetPhotos({
    required String ownerId,
    required String petId,
  }) async {
    try {
      AppLogger.info('Deleting all photos for pet: $petId');

      final path = '$ownerId/$petId';
      final files = await _supabase.storage.from(bucketName).list(path: path);

      if (files.isEmpty) {
        AppLogger.info('No photos to delete');
        return;
      }

      final filePaths = files.map((file) => '$path/${file.name}').toList();
      await _supabase.storage.from(bucketName).remove(filePaths);

      AppLogger.info('All photos deleted successfully');
    } on StorageException catch (e) {
      AppLogger.error('Storage error deleting photos', e);
      throw exceptions.StorageException(
        'Failed to delete photos: ${e.message}',
      );
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting photos', e, stackTrace);
      throw exceptions.StorageException(
        'Failed to delete photos: ${e.toString()}',
      );
    }
  }

  /// Get content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  /// Create storage bucket (run this once in setup)
  static Future<void> createBucket() async {
    try {
      AppLogger.info('Creating storage bucket: $bucketName');

      await SupabaseConfig.instance.storage.createBucket(
        bucketName,
        const BucketOptions(
          public: true,
          fileSizeLimit: '5242880', // 5MB
          allowedMimeTypes: [
            'image/jpeg',
            'image/png',
            'image/gif',
            'image/webp',
            'image/heic',
          ],
        ),
      );

      AppLogger.info('Bucket created successfully');
    } on StorageException catch (e) {
      if (e.message.contains('already exists')) {
        AppLogger.info('Bucket already exists');
      } else {
        AppLogger.error('Error creating bucket', e);
        rethrow;
      }
    }
  }
}
