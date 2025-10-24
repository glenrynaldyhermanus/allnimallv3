import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/pet_entity.dart';
import '../entities/pet_health_entity.dart';
import '../entities/pet_photo_entity.dart';
import '../entities/photo_like_entity.dart';
import '../entities/photo_comment_entity.dart';
import '../entities/photo_share_entity.dart';
import '../entities/scan_log_entity.dart';
import '../entities/pet_schedule_entity.dart';
import '../entities/schedule_type_entity.dart';
import '../entities/recurring_pattern_entity.dart';
import '../entities/pet_timeline_entity.dart';
import '../entities/pet_category_entity.dart';
import '../entities/character_entity.dart';
import '../entities/health_parameter_definition_entity.dart';
import '../entities/pet_health_history_entity.dart';

abstract class PetRepository {
  /// Get pet by ID (public access)
  Future<Either<Failure, PetEntity>> getPetById(String petId);

  /// Get pets by owner
  Future<Either<Failure, List<PetEntity>>> getPetsByOwner(String ownerId);

  /// Create new pet
  Future<Either<Failure, PetEntity>> createPet(PetEntity pet);

  /// Update pet
  Future<Either<Failure, PetEntity>> updatePet(PetEntity pet);

  /// Delete pet
  Future<Either<Failure, void>> deletePet(String petId);

  /// Report pet as lost
  Future<Either<Failure, PetEntity>> reportLost(
    String petId,
    String? lostMessage,
    String? emergencyContact,
  );

  /// Mark pet as found
  Future<Either<Failure, PetEntity>> markAsFound(String petId);

  /// Get pet health
  Future<Either<Failure, PetHealthEntity?>> getPetHealth(String petId);

  /// Update pet health
  Future<Either<Failure, PetHealthEntity>> updatePetHealth(
    PetHealthEntity health,
  );

  /// Get pet photos
  Future<Either<Failure, List<PetPhotoEntity>>> getPetPhotos(String petId);

  /// Add pet photo
  Future<Either<Failure, PetPhotoEntity>> addPetPhoto(
    String petId,
    String photoUrl,
    bool isPrimary,
  );

  /// Delete pet photo
  Future<Either<Failure, void>> deletePetPhoto(String photoId);

  /// Set primary photo
  Future<Either<Failure, void>> setPrimaryPhoto(String photoId);

  /// Upload pet photo/video with caption and hashtags
  Future<Either<Failure, PetPhotoEntity>> uploadPetPhoto(
    String petId,
    File file,
    String? caption,
    List<String>? hashtags,
  );

  /// Like a photo
  Future<Either<Failure, void>> likePhoto(
    String photoId,
    String? userId,
    String? ip,
  );

  /// Unlike a photo
  Future<Either<Failure, void>> unlikePhoto(
    String photoId,
    String? userId,
    String? ip,
  );

  /// Check if photo is liked by user/ip
  Future<Either<Failure, bool>> isPhotoLiked(
    String photoId,
    String? userId,
    String? ip,
  );

  /// Get photo comments
  Future<Either<Failure, List<PhotoCommentEntity>>> getPhotoComments(
    String photoId,
  );

  /// Add comment to photo
  Future<Either<Failure, PhotoCommentEntity>> addComment(
    String photoId,
    String commentText,
    String? userId,
    String? name,
    String? ip,
  );

  /// Delete comment
  Future<Either<Failure, void>> deleteComment(String commentId);

  /// Share photo
  Future<Either<Failure, void>> sharePhoto(
    String photoId,
    String platform,
    String? userId,
    String? ip,
  );

  /// Get scan logs
  Future<Either<Failure, List<ScanLogEntity>>> getScanLogs(String petId);

  /// Create scan log
  Future<Either<Failure, ScanLogEntity>> createScanLog({
    required String petId,
    double? latitude,
    double? longitude,
    String? scannedByIp,
    String? userAgent,
    Map<String, dynamic>? deviceInfo,
    double? locationAccuracy,
    String? locationName,
  });

  /// Get pet schedules
  Future<Either<Failure, List<PetScheduleEntity>>> getSchedulesByPetId(
    String petId,
  );

  /// Create pet schedule
  Future<Either<Failure, PetScheduleEntity>> createSchedule(
    PetScheduleEntity schedule,
  );

  /// Update pet schedule
  Future<Either<Failure, PetScheduleEntity>> updateSchedule(
    PetScheduleEntity schedule,
  );

  /// Delete pet schedule
  Future<Either<Failure, void>> deleteSchedule(String scheduleId);

  /// Get all schedule types
  Future<Either<Failure, List<ScheduleTypeEntity>>> getScheduleTypes();

  /// Get all pet categories
  Future<Either<Failure, List<PetCategoryEntity>>> getPetCategories();

  /// Create recurring pattern
  Future<Either<Failure, RecurringPatternEntity>> createRecurringPattern(
    RecurringPatternEntity pattern,
  );

  /// Get recurring pattern by ID
  Future<Either<Failure, RecurringPatternEntity?>> getRecurringPattern(
    String patternId,
  );

  /// Get pet timelines
  Future<Either<Failure, List<PetTimelineEntity>>> getPetTimelines(
    String petId,
  );

  /// Create timeline entry
  Future<Either<Failure, PetTimelineEntity>> createTimelineEntry(
    PetTimelineEntity timeline,
  );

  /// Delete timeline entry
  Future<Either<Failure, void>> deleteTimelineEntry(String timelineId);

  /// Get all characters
  Future<Either<Failure, List<CharacterEntity>>> getCharacters();

  /// Assign characters to pet
  Future<Either<Failure, void>> assignCharactersToPet(
    String petId,
    List<String> characterIds,
  );

  /// Get health parameter definitions for a pet category
  Future<Either<Failure, List<HealthParameterDefinitionEntity>>>
  getHealthParametersForCategory(String petCategoryId);

  /// Get pet health history
  Future<Either<Failure, List<PetHealthHistoryEntity>>> getHealthHistory(
    String petId, {
    String? parameterKey,
    int? limit,
  });

  /// Create health history entry
  Future<Either<Failure, PetHealthHistoryEntity>> createHealthHistory({
    required String petId,
    required String parameterKey,
    dynamic oldValue,
    dynamic newValue,
    String? notes,
  });

  /// Get pet by ID (for internal use)
  Future<Either<Failure, PetEntity>> getPet(String petId);
}
