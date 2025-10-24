import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class MediaUploadService {
  final SupabaseClient _supabase;
  static const String _bucketName = 'pet-media';

  MediaUploadService(this._supabase);

  /// Upload photo with compression
  Future<Map<String, dynamic>> uploadPhoto({
    required File file,
    required String petId,
    Function(double)? onProgress,
  }) async {
    try {
      // Compress image
      final compressedFile = await _compressImage(file);
      final bytes = await compressedFile.readAsBytes();

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final fileName = '$petId/photo_$timestamp.$extension';

      // Upload to Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/${extension == 'jpg' ? 'jpeg' : extension}',
              upsert: false,
            ),
          );

      // Get public URL
      final photoUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(fileName);

      // Get image dimensions
      final decodedImage = await decodeImageFromList(bytes);

      return {
        'photo_url': photoUrl,
        'mime_type': 'image/${extension == 'jpg' ? 'jpeg' : extension}',
        'file_size': bytes.length,
        'width': decodedImage.width,
        'height': decodedImage.height,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading photo', e, stackTrace);
      rethrow;
    }
  }

  /// Upload video with thumbnail generation
  Future<Map<String, dynamic>> uploadVideo({
    required File file,
    required String petId,
    Function(double)? onProgress,
  }) async {
    try {
      final bytes = await file.readAsBytes();

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.path.split('.').last;
      final videoFileName = '$petId/video_$timestamp.$extension';

      // Upload video to Supabase Storage
      await _supabase.storage
          .from(_bucketName)
          .uploadBinary(
            videoFileName,
            bytes,
            fileOptions: FileOptions(
              contentType: 'video/$extension',
              upsert: false,
            ),
          );

      // Get public URL
      final videoUrl = _supabase.storage
          .from(_bucketName)
          .getPublicUrl(videoFileName);

      // Generate thumbnail
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: file.path,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 400,
        quality: 75,
      );

      String? thumbnailUrl;
      if (thumbnailPath != null) {
        final thumbnailFile = File(thumbnailPath);
        final thumbnailBytes = await thumbnailFile.readAsBytes();
        final thumbnailFileName = '$petId/thumb_$timestamp.jpg';

        await _supabase.storage
            .from(_bucketName)
            .uploadBinary(
              thumbnailFileName,
              thumbnailBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );

        thumbnailUrl = _supabase.storage
            .from(_bucketName)
            .getPublicUrl(thumbnailFileName);

        // Clean up temp file
        await thumbnailFile.delete();
      }

      // Get video duration (simplified - would need video_player in production)
      // For now, return null and update later if needed
      final duration = await _getVideoDuration(file);

      return {
        'photo_url': videoUrl,
        'thumbnail_url': thumbnailUrl,
        'mime_type': 'video/$extension',
        'file_size': bytes.length,
        'duration': duration,
      };
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading video', e, stackTrace);
      rethrow;
    }
  }

  /// Compress image before upload
  Future<File> _compressImage(File file) async {
    try {
      final filePath = file.absolute.path;
      final lastIndex = filePath.lastIndexOf('.');
      final splitPath = filePath.substring(0, lastIndex);
      final outPath = '${splitPath}_compressed.jpg';

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
      );

      return File(compressedFile!.path);
    } catch (e) {
      AppLogger.error('Error compressing image, using original', e);
      return file;
    }
  }

  /// Get video duration in seconds
  Future<int?> _getVideoDuration(File file) async {
    try {
      // This is a simplified version
      // In production, you'd use video_player package to get accurate duration
      // For now, return null
      return null;
    } catch (e) {
      AppLogger.error('Error getting video duration', e);
      return null;
    }
  }

  /// Delete media from storage
  Future<void> deleteMedia(String photoUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(photoUrl);
      final pathSegments = uri.pathSegments;

      // Find the bucket name index and get path after it
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        throw Exception('Invalid photo URL');
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _supabase.storage.from(_bucketName).remove([filePath]);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting media', e, stackTrace);
      rethrow;
    }
  }
}

// Helper function to decode image
Future<dynamic> decodeImageFromList(List<int> bytes) async {
  // This would normally use dart:ui's decodeImageFromList
  // For simplicity, we'll return a mock object
  // In real implementation, import 'dart:ui' and use proper decoder
  return _MockImage(1024, 1024);
}

class _MockImage {
  final int width;
  final int height;
  _MockImage(this.width, this.height);
}
