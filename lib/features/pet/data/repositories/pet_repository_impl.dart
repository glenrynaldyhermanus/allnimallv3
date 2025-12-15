import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart' as exceptions;
import '../../../../core/error/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/entities/pet_health_entity.dart';
import '../../domain/entities/pet_photo_entity.dart';
import '../../domain/entities/photo_comment_entity.dart';
import '../../domain/entities/scan_log_entity.dart';
import '../../domain/entities/pet_schedule_entity.dart';
import '../../domain/entities/schedule_type_entity.dart';
import '../../domain/entities/recurring_pattern_entity.dart';
import '../../domain/entities/pet_timeline_entity.dart';
import '../../domain/entities/pet_category_entity.dart';
import '../../domain/entities/character_entity.dart';
import '../../domain/repositories/pet_repository.dart';
import '../datasources/pet_remote_datasource.dart';
import '../../domain/entities/health_parameter_definition_entity.dart';
import '../../domain/entities/pet_health_history_entity.dart';
import '../../../../core/config/supabase_config.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource remoteDataSource;

  PetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PetEntity>> getPetById(String petId) async {
    try {
      final pet = await remoteDataSource.getPetById(petId);
      return Right(pet.toEntity());
    } on exceptions.NotFoundException catch (e) {
      AppLogger.error('Pet not found', e);
      return Left(NotFoundFailure(e.message));
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting pet', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting pet', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PetEntity>>> getPetsByOwner(
    String ownerId,
  ) async {
    try {
      final pets = await remoteDataSource.getPetsByOwner(ownerId);
      return Right(pets.map((pet) => pet.toEntity()).toList());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting pets', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting pets', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> createPet(PetEntity pet) async {
    try {
      final petData = {
        'owner_id': pet.ownerId,
        'name': pet.name,
        'pet_category_id': pet.petCategoryId,
        'breed': pet.breed,
        'birth_date': pet.birthDate?.toIso8601String(),
        'gender': pet.gender,
        'color': pet.color,
        'weight': pet.weight,
        'microchip_id': pet.microchipId,
        'picture_url': pet.pictureUrl,
        'story': pet.story,
        'activated_at': DateTime.now().toIso8601String(),
      };

      final createdPet = await remoteDataSource.createPet(petData);
      return Right(createdPet.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception creating pet', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating pet', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> updatePet(PetEntity pet) async {
    try {
      final petData = {
        'name': pet.name,
        'breed': pet.breed,
        'birth_date': pet.birthDate?.toIso8601String(),
        'gender': pet.gender,
        'color': pet.color,
        'weight': pet.weight,
        'microchip_id': pet.microchipId,
        'picture_url': pet.pictureUrl,
        'story': pet.story,
      };

      final updatedPet = await remoteDataSource.updatePet(pet.id, petData);
      return Right(updatedPet.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception updating pet', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating pet', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePet(String petId) async {
    try {
      await remoteDataSource.deletePet(petId);
      return const Right(null);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception deleting pet', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting pet', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> reportLost(
    String petId,
    String? lostMessage,
    String? emergencyContact,
  ) async {
    try {
      final petData = {
        'is_lost': true,
        'lost_at': DateTime.now().toIso8601String(),
        'lost_message': lostMessage,
        'emergency_contact': emergencyContact,
      };

      final updatedPet = await remoteDataSource.updatePet(petId, petData);
      return Right(updatedPet.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception reporting lost pet', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error reporting lost pet', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> markAsFound(String petId) async {
    try {
      final petData = {
        'is_lost': false,
        'lost_at': null,
        'lost_message': null,
        'emergency_contact': null,
      };

      final updatedPet = await remoteDataSource.updatePet(petId, petData);
      return Right(updatedPet.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception marking pet as found', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error marking pet as found', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetHealthEntity?>> getPetHealth(String petId) async {
    try {
      final health = await remoteDataSource.getPetHealth(petId);
      return Right(health?.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting pet health', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting pet health', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetHealthEntity>> updatePetHealth(
    PetHealthEntity health,
  ) async {
    try {
      final healthData = {
        'pet_id': health.petId,
        'weight': health.weight,
        'weight_history': health.weightHistory,
        'vaccination_status': health.vaccinationStatus,
        'last_vaccination_date': health.lastVaccinationDate?.toIso8601String(),
        'next_vaccination_date': health.nextVaccinationDate?.toIso8601String(),
        'health_notes': health.healthNotes,
        'medical_conditions': health.medicalConditions,
        'allergies': health.allergies,
      };

      final updatedHealth = await remoteDataSource.updatePetHealth(healthData);
      return Right(updatedHealth.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception updating pet health', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating pet health', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PetPhotoEntity>>> getPetPhotos(
    String petId,
  ) async {
    try {
      final photos = await remoteDataSource.getPetPhotos(petId);
      return Right(photos.map((photo) => photo.toEntity()).toList());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting pet photos', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting pet photos', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetPhotoEntity>> addPetPhoto(
    String petId,
    String photoUrl,
    bool isPrimary,
  ) async {
    try {
      final photoData = {
        'pet_id': petId,
        'photo_url': photoUrl,
        'is_primary': isPrimary,
        'sort_order': 0,
      };

      final photo = await remoteDataSource.addPetPhoto(photoData);
      return Right(photo.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception adding pet photo', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error adding pet photo', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePetPhoto(String photoId) async {
    try {
      await remoteDataSource.deletePetPhoto(photoId);
      return const Right(null);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception deleting pet photo', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting pet photo', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setPrimaryPhoto(String photoId) async {
    try {
      // Note: petId will be fetched from photo in datasource
      await remoteDataSource.setPrimaryPhoto(photoId, '');
      return const Right(null);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception setting primary photo', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error setting primary photo', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  // Social features implementation
  @override
  Future<Either<Failure, PetPhotoEntity>> uploadPetPhoto(
    String petId,
    File file,
    String? caption,
    List<String>? hashtags,
  ) async {
    try {
      final photo = await remoteDataSource.uploadPhoto(
        file,
        petId,
        caption,
        hashtags,
      );
      return Right(photo.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception uploading photo', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error uploading photo', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likePhoto(
    String photoId,
    String? userId,
    String? ip,
  ) async {
    try {
      await remoteDataSource.likePhoto(photoId, userId, ip);
      return const Right(null);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception liking photo', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error liking photo', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlikePhoto(
    String photoId,
    String? userId,
    String? ip,
  ) async {
    try {
      await remoteDataSource.unlikePhoto(photoId, userId, ip);
      return const Right(null);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception unliking photo', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error unliking photo', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isPhotoLiked(
    String photoId,
    String? userId,
    String? ip,
  ) async {
    try {
      final isLiked = await remoteDataSource.isPhotoLiked(photoId, userId, ip);
      return Right(isLiked);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception checking like status', e);
      return const Right(false);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error checking like status', e, stackTrace);
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, List<PhotoCommentEntity>>> getPhotoComments(
    String photoId,
  ) async {
    try {
      final comments = await remoteDataSource.getPhotoComments(photoId);
      return Right(comments.map((c) => c.toEntity()).toList());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting comments', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting comments', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PhotoCommentEntity>> addComment(
    String photoId,
    String commentText,
    String? userId,
    String? name,
    String? ip,
  ) async {
    try {
      final commentData = {
        'photo_id': photoId,
        'comment_text': commentText,
        'user_id': userId,
        'commenter_name': name,
        'commenter_ip': ip,
      };

      final comment = await remoteDataSource.addComment(commentData);
      return Right(comment.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception adding comment', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error adding comment', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment(String commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception deleting comment', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting comment', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sharePhoto(
    String photoId,
    String platform,
    String? userId,
    String? ip,
  ) async {
    try {
      final shareData = {
        'photo_id': photoId,
        'shared_to_platform': platform,
        'shared_by_user_id': userId,
        'shared_by_ip': ip,
      };

      await remoteDataSource.recordShare(shareData);
      return const Right(null);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception recording share', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error recording share', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ScanLogEntity>>> getScanLogs(String petId) async {
    try {
      final logs = await remoteDataSource.getScanLogs(petId);
      return Right(logs.map((log) => log.toEntity()).toList());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting scan logs', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting scan logs', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ScanLogEntity>> createScanLog({
    required String petId,
    String? qrId, // NEW: QR ID for tracking
    double? latitude,
    double? longitude,
    String? scannedByIp,
    String? userAgent,
    Map<String, dynamic>? deviceInfo,
    double? locationAccuracy,
    String? locationName,
  }) async {
    try {
      final scanData = {
        'pet_id': petId,
        'qr_id': qrId, // NEW: Include QR ID in scan log
        'latitude': latitude,
        'longitude': longitude,
        'scanned_by_ip': scannedByIp,
        'user_agent': userAgent,
        'device_info': deviceInfo,
        'location_accuracy': locationAccuracy,
        'location_name': locationName,
      };

      final log = await remoteDataSource.createScanLog(scanData);
      return Right(log.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception creating scan log', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating scan log', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PetScheduleEntity>>> getSchedulesByPetId(
    String petId,
  ) async {
    try {
      final schedules = await remoteDataSource.getSchedulesByPetId(petId);
      return Right(schedules.map((schedule) => schedule.toEntity()).toList());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting pet schedules', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting pet schedules', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetScheduleEntity>> createSchedule(
    PetScheduleEntity schedule,
  ) async {
    try {
      final scheduleData = {
        'pet_id': schedule.petId,
        'schedule_type_id': schedule.scheduleTypeId,
        'scheduled_at': schedule.scheduledAt.toIso8601String(),
        'notes': schedule.notes,
        'status': schedule.status,
        'recurring_pattern_id': schedule.recurringPatternId,
      };

      final createdSchedule = await remoteDataSource.createSchedule(
        scheduleData,
      );
      return Right(createdSchedule.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception creating schedule', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error creating schedule', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetScheduleEntity>> updateSchedule(
    PetScheduleEntity schedule,
  ) async {
    try {
      final scheduleData = {
        'schedule_type_id': schedule.scheduleTypeId,
        'scheduled_at': schedule.scheduledAt.toIso8601String(),
        'completed_at': schedule.completedAt?.toIso8601String(),
        'notes': schedule.notes,
        'status': schedule.status,
        'recurring_pattern_id': schedule.recurringPatternId,
      };

      final updatedSchedule = await remoteDataSource.updateSchedule(
        schedule.id,
        scheduleData,
      );
      return Right(updatedSchedule.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception updating schedule', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error updating schedule', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSchedule(String scheduleId) async {
    try {
      await remoteDataSource.deleteSchedule(scheduleId);
      return const Right(null);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception deleting schedule', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error deleting schedule', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ScheduleTypeEntity>>> getScheduleTypes() async {
    try {
      final types = await remoteDataSource.getScheduleTypes();
      return Right(types.map((type) => type.toEntity()).toList());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting schedule types', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting schedule types', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PetCategoryEntity>>> getPetCategories() async {
    try {
      final categories = await remoteDataSource.getPetCategories();
      return Right(categories);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting pet categories', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting pet categories', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecurringPatternEntity>> createRecurringPattern(
    RecurringPatternEntity pattern,
  ) async {
    try {
      final patternData = {
        'pattern_type': pattern.patternType,
        'interval_value': pattern.intervalValue,
        'end_date': pattern.endDate?.toIso8601String(),
        'is_active': pattern.isActive,
      };

      final createdPattern = await remoteDataSource.createRecurringPattern(
        patternData,
      );
      return Right(createdPattern.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception creating recurring pattern', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error creating recurring pattern',
        e,
        stackTrace,
      );
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RecurringPatternEntity?>> getRecurringPattern(
    String patternId,
  ) async {
    try {
      final pattern = await remoteDataSource.getRecurringPattern(patternId);
      return Right(pattern?.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting recurring pattern', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error getting recurring pattern',
        e,
        stackTrace,
      );
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PetTimelineEntity>>> getPetTimelines(
    String petId,
  ) async {
    try {
      final timelines = await remoteDataSource.getPetTimelines(petId);
      return Right(timelines.map((t) => t.toEntity()).toList());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting pet timelines', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting pet timelines', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetTimelineEntity>> createTimelineEntry(
    PetTimelineEntity timeline,
  ) async {
    try {
      final timelineData = {
        'pet_id': timeline.petId,
        'timeline_type': timeline.timelineType,
        'title': timeline.title,
        'caption': timeline.caption,
        'media_url': timeline.mediaUrl,
        'media_type': timeline.mediaType,
        'visibility': timeline.visibility,
        'event_date': timeline.eventDate.toIso8601String(),
        'metadata': timeline.metadata,
      };

      final createdTimeline = await remoteDataSource.createTimelineEntry(
        timelineData,
      );
      return Right(createdTimeline.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception creating timeline entry', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error creating timeline entry',
        e,
        stackTrace,
      );
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTimelineEntry(String timelineId) async {
    try {
      await remoteDataSource.deleteTimelineEntry(timelineId);
      return const Right(null);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception deleting timeline entry', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error deleting timeline entry',
        e,
        stackTrace,
      );
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CharacterEntity>>> getCharacters() async {
    try {
      final characters = await remoteDataSource.getCharacters();
      return Right(characters.map((c) => c as CharacterEntity).toList());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting characters', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting characters', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> assignCharactersToPet(
    String petId,
    List<String> characterIds,
  ) async {
    try {
      await remoteDataSource.assignCharactersToPet(petId, characterIds);
      return const Right(null);
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception assigning characters', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error assigning characters', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HealthParameterDefinitionEntity>>>
  getHealthParametersForCategory(String petCategoryId) async {
    try {
      AppLogger.info('Getting health parameters for category: $petCategoryId');
      final parameters = await remoteDataSource.getHealthParametersForCategory(
        petCategoryId,
      );
      return Right(parameters.map((model) => model.toEntity()).toList());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting health parameters', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error getting health parameters',
        e,
        stackTrace,
      );
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PetHealthHistoryEntity>>> getHealthHistory(
    String petId, {
    String? parameterKey,
    int? limit,
  }) async {
    try {
      AppLogger.info('Getting health history for pet: $petId');
      final history = await remoteDataSource.getHealthHistory(
        petId,
        parameterKey: parameterKey,
        limit: limit,
      );
      return Right(history.map((model) => model.toEntity()).toList());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception getting health history', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error getting health history', e, stackTrace);
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetHealthHistoryEntity>> createHealthHistory({
    required String petId,
    required String parameterKey,
    dynamic oldValue,
    dynamic newValue,
    String? notes,
  }) async {
    try {
      AppLogger.info('Creating health history entry');

      final currentUser = SupabaseConfig.instance.auth.currentUser;

      final historyData = {
        'pet_id': petId,
        'parameter_key': parameterKey,
        'old_value': oldValue,
        'new_value': newValue,
        'changed_by': currentUser?.id,
        'notes': notes,
      };

      final history = await remoteDataSource.createHealthHistory(historyData);
      return Right(history.toEntity());
    } on exceptions.ServerException catch (e) {
      AppLogger.error('Server exception creating health history', e);
      return Left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error creating health history',
        e,
        stackTrace,
      );
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PetEntity>> getPet(String petId) async {
    // Reuse getPetById for internal use
    return getPetById(petId);
  }
}
