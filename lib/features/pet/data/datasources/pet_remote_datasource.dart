import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/error/exceptions.dart' as exceptions;
import '../../../../core/utils/logger.dart';
import '../../../../core/services/media_upload_service.dart';
import '../models/pet_model.dart';
import '../models/pet_health_model.dart';
import '../models/pet_photo_model.dart';
import '../models/photo_comment_model.dart';
import '../models/scan_log_model.dart';
import '../models/pet_schedule_model.dart';
import '../models/schedule_type_model.dart';
import '../models/recurring_pattern_model.dart';
import '../models/pet_timeline_model.dart';
import '../models/pet_category_model.dart';
import '../models/character_model.dart';
import '../models/health_parameter_definition_model.dart';
import '../models/pet_health_history_model.dart';

abstract class PetRemoteDataSource {
  Future<PetModel> getPetById(String petId);
  Future<List<PetModel>> getPetsByOwner(String ownerId);
  Future<PetModel> createPet(Map<String, dynamic> petData);
  Future<PetModel> updatePet(String petId, Map<String, dynamic> petData);
  Future<void> deletePet(String petId);
  Future<PetHealthModel?> getPetHealth(String petId);
  Future<PetHealthModel> updatePetHealth(Map<String, dynamic> healthData);
  Future<List<PetPhotoModel>> getPetPhotos(String petId);
  Future<PetPhotoModel> addPetPhoto(Map<String, dynamic> photoData);
  Future<void> deletePetPhoto(String photoId);
  Future<void> setPrimaryPhoto(String photoId, String petId);

  // Social features
  Future<PetPhotoModel> uploadPhoto(
    File file,
    String petId,
    String? caption,
    List<String>? hashtags,
  );
  Future<void> likePhoto(String photoId, String? userId, String? ip);
  Future<void> unlikePhoto(String photoId, String? userId, String? ip);
  Future<bool> isPhotoLiked(String photoId, String? userId, String? ip);
  Future<List<PhotoCommentModel>> getPhotoComments(String photoId);
  Future<PhotoCommentModel> addComment(Map<String, dynamic> commentData);
  Future<void> deleteComment(String commentId);
  Future<void> recordShare(Map<String, dynamic> shareData);

  Future<List<ScanLogModel>> getScanLogs(String petId);
  Future<ScanLogModel> createScanLog(Map<String, dynamic> scanData);
  Future<List<PetScheduleModel>> getSchedulesByPetId(String petId);
  Future<PetScheduleModel> createSchedule(Map<String, dynamic> scheduleData);
  Future<PetScheduleModel> updateSchedule(
    String scheduleId,
    Map<String, dynamic> scheduleData,
  );
  Future<void> deleteSchedule(String scheduleId);
  Future<List<ScheduleTypeModel>> getScheduleTypes();
  Future<List<PetCategoryModel>> getPetCategories();
  Future<RecurringPatternModel> createRecurringPattern(
    Map<String, dynamic> patternData,
  );
  Future<RecurringPatternModel?> getRecurringPattern(String patternId);

  // Timeline methods
  Future<List<PetTimelineModel>> getPetTimelines(String petId);
  Future<PetTimelineModel> createTimelineEntry(
    Map<String, dynamic> timelineData,
  );
  Future<void> deleteTimelineEntry(String timelineId);

  // Character methods
  Future<List<CharacterModel>> getCharacters();
  Future<void> assignCharactersToPet(String petId, List<String> characterIds);

  // Dynamic health system methods
  Future<List<HealthParameterDefinitionModel>> getHealthParametersForCategory(
    String petCategoryId,
  );
  Future<List<PetHealthHistoryModel>> getHealthHistory(
    String petId, {
    String? parameterKey,
    int? limit,
  });
  Future<PetHealthHistoryModel> createHealthHistory(
    Map<String, dynamic> historyData,
  );
}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final SupabaseClient _supabase;

  PetRemoteDataSourceImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseConfig.instance;

  @override
  Future<PetModel> getPetById(String petId) async {
    try {
      AppLogger.info('Fetching pet by ID: $petId');

      final response = await _supabase
          .schema('pet')
          .from('pets')
          .select()
          .eq('id', petId)
          .maybeSingle();

      if (response == null) {
        throw exceptions.NotFoundException('Pet not found');
      }

      return PetModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching pet', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching pet', e, stackTrace);
      throw exceptions.ServerException('Failed to fetch pet: ${e.toString()}');
    }
  }

  @override
  Future<List<PetModel>> getPetsByOwner(String ownerId) async {
    try {
      AppLogger.info('Fetching pets for owner: $ownerId');

      final response = await _supabase
          .schema('pet')
          .from('pets')
          .select()
          .eq('owner_id', ownerId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PetModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching pets', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching pets', e, stackTrace);
      throw exceptions.ServerException('Failed to fetch pets: ${e.toString()}');
    }
  }

  @override
  Future<PetModel> createPet(Map<String, dynamic> petData) async {
    try {
      AppLogger.info('Creating new pet');

      final response = await _supabase
          .schema('pet')
          .from('pets')
          .insert(petData)
          .select()
          .single();

      return PetModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error creating pet', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error creating pet', e, stackTrace);
      throw exceptions.ServerException('Failed to create pet: ${e.toString()}');
    }
  }

  @override
  Future<PetModel> updatePet(String petId, Map<String, dynamic> petData) async {
    try {
      AppLogger.info('Updating pet: $petId');

      petData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .schema('pet')
          .from('pets')
          .update(petData)
          .eq('id', petId)
          .select()
          .single();

      return PetModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error updating pet', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error updating pet', e, stackTrace);
      throw exceptions.ServerException('Failed to update pet: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePet(String petId) async {
    try {
      AppLogger.info('Deleting pet: $petId');

      await _supabase
          .from('pet.pets')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', petId);

      AppLogger.info('Pet deleted successfully');
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error deleting pet', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting pet', e, stackTrace);
      throw exceptions.ServerException('Failed to delete pet: ${e.toString()}');
    }
  }

  @override
  Future<PetHealthModel?> getPetHealth(String petId) async {
    try {
      AppLogger.info('Fetching pet health for: $petId');

      final response = await _supabase
          .schema('pet')
          .from('pet_healths')
          .select()
          .eq('pet_id', petId)
          .maybeSingle();

      if (response == null) return null;

      return PetHealthModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching pet health', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching pet health', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch pet health: ${e.toString()}',
      );
    }
  }

  @override
  Future<PetHealthModel> updatePetHealth(
    Map<String, dynamic> healthData,
  ) async {
    try {
      AppLogger.info('Updating pet health');

      healthData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .schema('pet')
          .from('pet_healths')
          .upsert(healthData, onConflict: 'pet_id')
          .select()
          .single();

      return PetHealthModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error updating pet health', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error updating pet health', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to update pet health: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PetPhotoModel>> getPetPhotos(String petId) async {
    try {
      AppLogger.info('Fetching pet photos for: $petId');

      final response = await _supabase
          .schema('pet')
          .from('pet_photos')
          .select()
          .eq('pet_id', petId)
          .isFilter('deleted_at', null)
          .order('sort_order', ascending: true);

      final photos = (response as List)
          .map((json) => json as Map<String, dynamic>)
          .toList();

      // Fetch counts for each photo
      final photosWithCounts = await Future.wait(
        photos.map((photoJson) async {
          final photoId = photoJson['id'] as String;

          // Get like count
          final likesResponse = await _supabase
              .schema('pet')
              .from('photo_likes')
              .select()
              .eq('photo_id', photoId);
          final likeCount = (likesResponse as List).length;

          // Get comment count
          final commentsResponse = await _supabase
              .schema('pet')
              .from('photo_comments')
              .select()
              .eq('photo_id', photoId)
              .isFilter('deleted_at', null);
          final commentCount = (commentsResponse as List).length;

          // Get share count
          final sharesResponse = await _supabase
              .schema('pet')
              .from('photo_shares')
              .select()
              .eq('photo_id', photoId);
          final shareCount = (sharesResponse as List).length;

          return {
            ...photoJson,
            'like_count': likeCount,
            'comment_count': commentCount,
            'share_count': shareCount,
          };
        }),
      );

      return photosWithCounts
          .map((json) => PetPhotoModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching pet photos', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching pet photos', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch pet photos: ${e.toString()}',
      );
    }
  }

  @override
  Future<PetPhotoModel> addPetPhoto(Map<String, dynamic> photoData) async {
    try {
      AppLogger.info('Adding pet photo');

      final response = await _supabase
          .schema('pet')
          .from('pet_photos')
          .insert(photoData)
          .select()
          .single();

      return PetPhotoModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error adding pet photo', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error adding pet photo', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to add pet photo: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deletePetPhoto(String photoId) async {
    try {
      AppLogger.info('Deleting pet photo: $photoId');

      await _supabase
          .from('pet.pet_photos')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', photoId);

      AppLogger.info('Pet photo deleted successfully');
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error deleting pet photo', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting pet photo', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to delete pet photo: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> setPrimaryPhoto(String photoId, String petId) async {
    try {
      AppLogger.info('Setting primary photo: $photoId');

      // First, unset all primary photos for this pet
      await _supabase
          .from('pet.pet_photos')
          .update({
            'is_primary': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('pet_id', petId);

      // Then set the new primary photo
      await _supabase
          .from('pet.pet_photos')
          .update({
            'is_primary': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', photoId);

      AppLogger.info('Primary photo set successfully');
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error setting primary photo', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error setting primary photo', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to set primary photo: ${e.toString()}',
      );
    }
  }

  // Social features implementation
  @override
  Future<PetPhotoModel> uploadPhoto(
    File file,
    String petId,
    String? caption,
    List<String>? hashtags,
  ) async {
    try {
      AppLogger.info('Uploading photo for pet: $petId');

      final uploadService = MediaUploadService(_supabase);

      // Check if it's a video or image
      final mimeType =
          file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov')
          ? 'video'
          : 'image';

      late Map<String, dynamic> uploadResult;

      if (mimeType == 'video') {
        uploadResult = await uploadService.uploadVideo(
          file: file,
          petId: petId,
        );
      } else {
        uploadResult = await uploadService.uploadPhoto(
          file: file,
          petId: petId,
        );
      }

      // Create photo record in database
      final photoData = {
        'pet_id': petId,
        'photo_url': uploadResult['photo_url'],
        'mime_type': uploadResult['mime_type'],
        'file_size': uploadResult['file_size'],
        'width': uploadResult['width'],
        'height': uploadResult['height'],
        'duration': uploadResult['duration'],
        'thumbnail_url': uploadResult['thumbnail_url'],
        'caption': caption,
        'hashtags': hashtags,
        'is_primary': false,
        'sort_order': 0,
      };

      final response = await _supabase
          .schema('pet')
          .from('pet_photos')
          .insert(photoData)
          .select()
          .single();

      return PetPhotoModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error uploading photo', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error uploading photo', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to upload photo: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> likePhoto(String photoId, String? userId, String? ip) async {
    try {
      AppLogger.info('Liking photo: $photoId');

      await _supabase.schema('pet').from('photo_likes').insert({
        'photo_id': photoId,
        'user_id': userId,
        'liked_by_ip': ip,
      });

      AppLogger.info('Photo liked successfully');
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error liking photo', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error liking photo', e, stackTrace);
      throw exceptions.ServerException('Failed to like photo: ${e.toString()}');
    }
  }

  @override
  Future<void> unlikePhoto(String photoId, String? userId, String? ip) async {
    try {
      AppLogger.info('Unliking photo: $photoId');

      var query = _supabase
          .schema('pet')
          .from('photo_likes')
          .delete()
          .eq('photo_id', photoId);

      if (userId != null) {
        query = query.eq('user_id', userId);
      } else if (ip != null) {
        query = query.eq('liked_by_ip', ip);
      }

      await query;

      AppLogger.info('Photo unliked successfully');
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error unliking photo', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error unliking photo', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to unlike photo: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isPhotoLiked(String photoId, String? userId, String? ip) async {
    try {
      var query = _supabase
          .schema('pet')
          .from('photo_likes')
          .select()
          .eq('photo_id', photoId);

      if (userId != null) {
        query = query.eq('user_id', userId);
      } else if (ip != null) {
        query = query.eq('liked_by_ip', ip);
      }

      final response = await query;
      return (response as List).isNotEmpty;
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error checking like status', e);
      return false;
    } catch (e) {
      AppLogger.error('Error checking like status', e);
      return false;
    }
  }

  @override
  Future<List<PhotoCommentModel>> getPhotoComments(String photoId) async {
    try {
      AppLogger.info('Fetching comments for photo: $photoId');

      final response = await _supabase
          .schema('pet')
          .from('photo_comments')
          .select()
          .eq('photo_id', photoId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: true);

      return (response as List)
          .map(
            (json) => PhotoCommentModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching comments', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching comments', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch comments: ${e.toString()}',
      );
    }
  }

  @override
  Future<PhotoCommentModel> addComment(Map<String, dynamic> commentData) async {
    try {
      AppLogger.info('Adding comment');

      final response = await _supabase
          .schema('pet')
          .from('photo_comments')
          .insert(commentData)
          .select()
          .single();

      return PhotoCommentModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error adding comment', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error adding comment', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to add comment: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      AppLogger.info('Deleting comment: $commentId');

      // Soft delete
      await _supabase
          .schema('pet')
          .from('photo_comments')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', commentId);

      AppLogger.info('Comment deleted successfully');
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error deleting comment', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting comment', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to delete comment: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> recordShare(Map<String, dynamic> shareData) async {
    try {
      AppLogger.info('Recording share');

      await _supabase.schema('pet').from('photo_shares').insert(shareData);

      AppLogger.info('Share recorded successfully');
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error recording share', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error recording share', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to record share: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ScanLogModel>> getScanLogs(String petId) async {
    try {
      AppLogger.info('Fetching scan logs for pet: $petId');

      final response = await _supabase
          .schema('pet')
          .from('pet_scan_logs')
          .select()
          .eq('pet_id', petId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ScanLogModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching scan logs', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching scan logs', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch scan logs: ${e.toString()}',
      );
    }
  }

  @override
  Future<ScanLogModel> createScanLog(Map<String, dynamic> scanData) async {
    try {
      AppLogger.info('Creating scan log');

      final response = await _supabase
          .schema('pet')
          .from('pet_scan_logs')
          .insert(scanData)
          .select()
          .single();

      return ScanLogModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error creating scan log', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error creating scan log', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to create scan log: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PetScheduleModel>> getSchedulesByPetId(String petId) async {
    try {
      AppLogger.info('Fetching schedules for pet: $petId');

      final response = await _supabase
          .schema('pet')
          .from('pet_schedules')
          .select('''
            *,
            schedule_types:schedule_type_id (
              name,
              icon,
              color
            )
          ''')
          .eq('pet_id', petId)
          .isFilter('deleted_at', null)
          .order('scheduled_at', ascending: true);

      return (response as List).map((json) {
        final scheduleJson = json as Map<String, dynamic>;
        // Flatten the joined schedule type data
        if (scheduleJson['schedule_types'] != null) {
          final scheduleType = scheduleJson['schedule_types'];
          scheduleJson['schedule_type_name'] = scheduleType['name'];
          scheduleJson['schedule_type_icon'] = scheduleType['icon'];
          scheduleJson['schedule_type_color'] = scheduleType['color'];
        }
        return PetScheduleModel.fromJson(scheduleJson);
      }).toList();
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching schedules', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching schedules', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch schedules: ${e.toString()}',
      );
    }
  }

  @override
  Future<PetScheduleModel> createSchedule(
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      AppLogger.info('Creating schedule');

      final response = await _supabase
          .schema('pet')
          .from('pet_schedules')
          .insert(scheduleData)
          .select('''
            *,
            schedule_types:schedule_type_id (
              name,
              icon,
              color
            )
          ''')
          .single();

      // Flatten the joined schedule type data
      if (response['schedule_types'] != null) {
        final scheduleType = response['schedule_types'];
        response['schedule_type_name'] = scheduleType['name'];
        response['schedule_type_icon'] = scheduleType['icon'];
        response['schedule_type_color'] = scheduleType['color'];
      }

      return PetScheduleModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error creating schedule', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error creating schedule', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to create schedule: ${e.toString()}',
      );
    }
  }

  @override
  Future<PetScheduleModel> updateSchedule(
    String scheduleId,
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      AppLogger.info('Updating schedule: $scheduleId');

      scheduleData['updated_at'] = DateTime.now().toIso8601String();

      final response = await _supabase
          .schema('pet')
          .from('pet_schedules')
          .update(scheduleData)
          .eq('id', scheduleId)
          .select('''
            *,
            schedule_types:schedule_type_id (
              name,
              icon,
              color
            )
          ''')
          .single();

      // Flatten the joined schedule type data
      if (response['schedule_types'] != null) {
        final scheduleType = response['schedule_types'];
        response['schedule_type_name'] = scheduleType['name'];
        response['schedule_type_icon'] = scheduleType['icon'];
        response['schedule_type_color'] = scheduleType['color'];
      }

      return PetScheduleModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error updating schedule', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error updating schedule', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to update schedule: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    try {
      AppLogger.info('Deleting schedule: $scheduleId');

      await _supabase
          .from('pet.pet_schedules')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', scheduleId);

      AppLogger.info('Schedule deleted successfully');
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error deleting schedule', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting schedule', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to delete schedule: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<ScheduleTypeModel>> getScheduleTypes() async {
    try {
      AppLogger.info('Fetching schedule types');

      final response = await _supabase
          .schema('pet')
          .from('schedule_types')
          .select()
          .isFilter('deleted_at', null)
          .order('name', ascending: true);

      return (response as List)
          .map(
            (json) => ScheduleTypeModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching schedule types', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching schedule types', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch schedule types: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PetCategoryModel>> getPetCategories() async {
    try {
      AppLogger.info('Fetching pet categories');

      final response = await _supabase
          .schema('pet')
          .from('pet_categories')
          .select()
          .order('name_id', ascending: true);

      return (response as List)
          .map(
            (json) => PetCategoryModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching pet categories', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching pet categories', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch pet categories: ${e.toString()}',
      );
    }
  }

  @override
  Future<RecurringPatternModel> createRecurringPattern(
    Map<String, dynamic> patternData,
  ) async {
    try {
      AppLogger.info('Creating recurring pattern');

      final response = await _supabase
          .schema('pet')
          .from('schedule_recurring_patterns')
          .insert(patternData)
          .select()
          .single();

      return RecurringPatternModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error creating recurring pattern', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error creating recurring pattern', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to create recurring pattern: ${e.toString()}',
      );
    }
  }

  @override
  Future<RecurringPatternModel?> getRecurringPattern(String patternId) async {
    try {
      AppLogger.info('Fetching recurring pattern: $patternId');

      final response = await _supabase
          .schema('pet')
          .from('schedule_recurring_patterns')
          .select()
          .eq('id', patternId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return RecurringPatternModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching recurring pattern', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching recurring pattern', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch recurring pattern: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PetTimelineModel>> getPetTimelines(String petId) async {
    try {
      AppLogger.info('Fetching timelines for pet: $petId');

      final response = await _supabase
          .schema('pet')
          .from('pet_timelines')
          .select()
          .eq('pet_id', petId)
          .order('event_date', ascending: false);

      return (response as List)
          .map(
            (json) => PetTimelineModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching timelines', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching timelines', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch timelines: ${e.toString()}',
      );
    }
  }

  @override
  Future<PetTimelineModel> createTimelineEntry(
    Map<String, dynamic> timelineData,
  ) async {
    try {
      AppLogger.info('Creating timeline entry');

      final response = await _supabase
          .schema('pet')
          .from('pet_timelines')
          .insert(timelineData)
          .select()
          .single();

      return PetTimelineModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error creating timeline entry', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error creating timeline entry', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to create timeline entry: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteTimelineEntry(String timelineId) async {
    try {
      AppLogger.info('Deleting timeline entry: $timelineId');

      await _supabase
          .schema('pet')
          .from('pet_timelines')
          .delete()
          .eq('id', timelineId);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error deleting timeline entry', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting timeline entry', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to delete timeline entry: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<CharacterModel>> getCharacters() async {
    try {
      AppLogger.info('Fetching characters');

      final response = await _supabase
          .schema('pet')
          .from('characters')
          .select()
          .order('character_id', ascending: true);

      return (response as List)
          .map((json) => CharacterModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching characters', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching characters', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch characters: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> assignCharactersToPet(
    String petId,
    List<String> characterIds,
  ) async {
    try {
      AppLogger.info('Assigning characters to pet: $petId');

      // Delete existing characters for this pet
      await _supabase
          .schema('pet')
          .from('pet_characters')
          .delete()
          .eq('pet_id', petId);

      // Insert new characters
      if (characterIds.isNotEmpty) {
        final data = characterIds
            .map((charId) => {'pet_id': petId, 'character_id': charId})
            .toList();

        await _supabase.schema('pet').from('pet_characters').insert(data);
      }
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error assigning characters', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error assigning characters', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to assign characters: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<HealthParameterDefinitionModel>> getHealthParametersForCategory(
    String petCategoryId,
  ) async {
    try {
      AppLogger.info(
        'Fetching health parameter definitions for category: $petCategoryId',
      );

      final response = await _supabase
          .schema('pet')
          .from('health_parameter_definitions')
          .select()
          .eq('pet_category_id', petCategoryId)
          .isFilter('deleted_at', null)
          .order('display_order', ascending: true);

      final List<HealthParameterDefinitionModel> parameters = [];
      for (final item in response as List) {
        parameters.add(
          HealthParameterDefinitionModel.fromJson(item as Map<String, dynamic>),
        );
      }

      return parameters;
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching health parameters', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching health parameters', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch health parameters: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PetHealthHistoryModel>> getHealthHistory(
    String petId, {
    String? parameterKey,
    int? limit,
  }) async {
    try {
      AppLogger.info('Fetching health history for pet: $petId');

      dynamic query = _supabase
          .schema('pet')
          .from('pet_health_history')
          .select()
          .eq('pet_id', petId);

      if (parameterKey != null) {
        query = query.eq('parameter_key', parameterKey);
      }

      query = query.order('changed_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      final List<PetHealthHistoryModel> history = [];
      for (final item in response as List) {
        history.add(
          PetHealthHistoryModel.fromJson(item as Map<String, dynamic>),
        );
      }

      return history;
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error fetching health history', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error fetching health history', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to fetch health history: ${e.toString()}',
      );
    }
  }

  @override
  Future<PetHealthHistoryModel> createHealthHistory(
    Map<String, dynamic> historyData,
  ) async {
    try {
      AppLogger.info('Creating health history entry');

      final response = await _supabase
          .schema('pet')
          .from('pet_health_history')
          .insert(historyData)
          .select()
          .single();

      return PetHealthHistoryModel.fromJson(response);
    } on PostgrestException catch (e) {
      AppLogger.error('Postgrest error creating health history', e);
      throw exceptions.ServerException(e.message, e.code);
    } catch (e, stackTrace) {
      AppLogger.error('Error creating health history', e, stackTrace);
      throw exceptions.ServerException(
        'Failed to create health history: ${e.toString()}',
      );
    }
  }
}
