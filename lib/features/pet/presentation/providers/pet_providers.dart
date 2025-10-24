import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../data/datasources/pet_remote_datasource.dart';
import '../../data/repositories/pet_repository_impl.dart';
import '../../domain/entities/pet_entity.dart';
import '../../domain/entities/pet_health_entity.dart';
import '../../domain/entities/pet_photo_entity.dart';
import '../../domain/entities/photo_comment_entity.dart';
import '../../domain/entities/scan_log_entity.dart';
import '../../domain/entities/pet_schedule_entity.dart';
import '../../domain/entities/schedule_type_entity.dart';
import '../../domain/entities/pet_timeline_entity.dart';
import '../../domain/entities/pet_category_entity.dart';
import '../../domain/entities/character_entity.dart';
import '../../domain/repositories/pet_repository.dart';
import '../../domain/usecases/create_pet_usecase.dart';
import '../../domain/usecases/create_scan_log_usecase.dart';
import '../../domain/usecases/get_pet_by_id_usecase.dart';
import '../../domain/usecases/get_pets_by_owner_usecase.dart';
import '../../domain/usecases/mark_pet_found_usecase.dart';
import '../../domain/usecases/report_lost_pet_usecase.dart';
import '../../domain/usecases/update_pet_usecase.dart';
import '../../domain/usecases/get_pet_schedules_usecase.dart';
import '../../domain/usecases/create_schedule_usecase.dart';
import '../../domain/usecases/update_schedule_usecase.dart';
import '../../domain/usecases/delete_schedule_usecase.dart';
import '../../domain/usecases/upload_pet_photo_usecase.dart';
import '../../domain/usecases/like_photo_usecase.dart';
import '../../domain/usecases/unlike_photo_usecase.dart';
import '../../domain/usecases/is_photo_liked_usecase.dart';
import '../../domain/usecases/get_photo_comments_usecase.dart';
import '../../domain/usecases/add_photo_comment_usecase.dart';
import '../../domain/usecases/delete_photo_comment_usecase.dart';
import '../../domain/usecases/share_photo_usecase.dart';
import '../../domain/usecases/get_pet_timelines_usecase.dart';
import '../../domain/usecases/create_timeline_entry_usecase.dart';
import '../../domain/usecases/delete_timeline_entry_usecase.dart';
import '../../domain/usecases/get_characters_usecase.dart';
import '../../domain/usecases/assign_characters_usecase.dart';
import '../../domain/usecases/get_health_parameters_for_category.dart';
import '../../domain/usecases/calculate_health_score.dart';
import '../../domain/usecases/update_health_parameter.dart';
import '../../domain/usecases/get_health_history.dart';
import '../../domain/entities/health_parameter_definition_entity.dart';
import '../../domain/entities/pet_health_history_entity.dart';

// Data Sources
final petRemoteDataSourceProvider = Provider<PetRemoteDataSource>((ref) {
  return PetRemoteDataSourceImpl(supabase: SupabaseConfig.instance);
});

// Repositories
final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepositoryImpl(
    remoteDataSource: ref.watch(petRemoteDataSourceProvider),
  );
});

// Use Cases
final getPetByIdUseCaseProvider = Provider<GetPetByIdUseCase>((ref) {
  return GetPetByIdUseCase(ref.watch(petRepositoryProvider));
});

final getPetsByOwnerUseCaseProvider = Provider<GetPetsByOwnerUseCase>((ref) {
  return GetPetsByOwnerUseCase(ref.watch(petRepositoryProvider));
});

final createPetUseCaseProvider = Provider<CreatePetUseCase>((ref) {
  return CreatePetUseCase(ref.watch(petRepositoryProvider));
});

final updatePetUseCaseProvider = Provider<UpdatePetUseCase>((ref) {
  return UpdatePetUseCase(ref.watch(petRepositoryProvider));
});

final reportLostPetUseCaseProvider = Provider<ReportLostPetUseCase>((ref) {
  return ReportLostPetUseCase(ref.watch(petRepositoryProvider));
});

final markPetFoundUseCaseProvider = Provider<MarkPetFoundUseCase>((ref) {
  return MarkPetFoundUseCase(ref.watch(petRepositoryProvider));
});

final createScanLogUseCaseProvider = Provider<CreateScanLogUseCase>((ref) {
  return CreateScanLogUseCase(ref.watch(petRepositoryProvider));
});

final getPetSchedulesUseCaseProvider = Provider<GetPetSchedulesUseCase>((ref) {
  return GetPetSchedulesUseCase(ref.watch(petRepositoryProvider));
});

final createScheduleUseCaseProvider = Provider<CreateScheduleUseCase>((ref) {
  return CreateScheduleUseCase(ref.watch(petRepositoryProvider));
});

final updateScheduleUseCaseProvider = Provider<UpdateScheduleUseCase>((ref) {
  return UpdateScheduleUseCase(ref.watch(petRepositoryProvider));
});

final deleteScheduleUseCaseProvider = Provider<DeleteScheduleUseCase>((ref) {
  return DeleteScheduleUseCase(ref.watch(petRepositoryProvider));
});

// Social Features Use Cases
final uploadPetPhotoUseCaseProvider = Provider<UploadPetPhotoUseCase>((ref) {
  return UploadPetPhotoUseCase(ref.watch(petRepositoryProvider));
});

final likePhotoUseCaseProvider = Provider<LikePhotoUseCase>((ref) {
  return LikePhotoUseCase(ref.watch(petRepositoryProvider));
});

final unlikePhotoUseCaseProvider = Provider<UnlikePhotoUseCase>((ref) {
  return UnlikePhotoUseCase(ref.watch(petRepositoryProvider));
});

final isPhotoLikedUseCaseProvider = Provider<IsPhotoLikedUseCase>((ref) {
  return IsPhotoLikedUseCase(ref.watch(petRepositoryProvider));
});

final getPhotoCommentsUseCaseProvider = Provider<GetPhotoCommentsUseCase>((
  ref,
) {
  return GetPhotoCommentsUseCase(ref.watch(petRepositoryProvider));
});

final addPhotoCommentUseCaseProvider = Provider<AddPhotoCommentUseCase>((ref) {
  return AddPhotoCommentUseCase(ref.watch(petRepositoryProvider));
});

final deletePhotoCommentUseCaseProvider = Provider<DeletePhotoCommentUseCase>((
  ref,
) {
  return DeletePhotoCommentUseCase(ref.watch(petRepositoryProvider));
});

final sharePhotoUseCaseProvider = Provider<SharePhotoUseCase>((ref) {
  return SharePhotoUseCase(ref.watch(petRepositoryProvider));
});

// Timeline Use Cases
final getPetTimelinesUseCaseProvider = Provider<GetPetTimelinesUseCase>((ref) {
  return GetPetTimelinesUseCase(ref.watch(petRepositoryProvider));
});

final createTimelineEntryUseCaseProvider = Provider<CreateTimelineEntryUseCase>(
  (ref) {
    return CreateTimelineEntryUseCase(ref.watch(petRepositoryProvider));
  },
);

final deleteTimelineEntryUseCaseProvider = Provider<DeleteTimelineEntryUseCase>(
  (ref) {
    return DeleteTimelineEntryUseCase(ref.watch(petRepositoryProvider));
  },
);

// Character Use Cases
final getCharactersUseCaseProvider = Provider<GetCharactersUseCase>((ref) {
  return GetCharactersUseCase(ref.watch(petRepositoryProvider));
});

final assignCharactersUseCaseProvider = Provider<AssignCharactersUseCase>((
  ref,
) {
  return AssignCharactersUseCase(ref.watch(petRepositoryProvider));
});

// Pet State Providers
final petByIdProvider = FutureProvider.family<PetEntity, String>((
  ref,
  petId,
) async {
  final useCase = ref.watch(getPetByIdUseCaseProvider);
  final result = await useCase(petId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (pet) => pet,
  );
});

final petsByOwnerProvider = FutureProvider.family<List<PetEntity>, String>((
  ref,
  ownerId,
) async {
  final useCase = ref.watch(getPetsByOwnerUseCaseProvider);
  final result = await useCase(ownerId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (pets) => pets,
  );
});

final petHealthProvider = FutureProvider.family<PetHealthEntity?, String>((
  ref,
  petId,
) async {
  final repository = ref.watch(petRepositoryProvider);
  final result = await repository.getPetHealth(petId);

  return result.fold((failure) => null, (health) => health);
});

final petPhotosProvider = FutureProvider.family<List<PetPhotoEntity>, String>((
  ref,
  petId,
) async {
  final repository = ref.watch(petRepositoryProvider);
  final result = await repository.getPetPhotos(petId);

  return result.fold((failure) => <PetPhotoEntity>[], (photos) => photos);
});

final scanLogsProvider = FutureProvider.family<List<ScanLogEntity>, String>((
  ref,
  petId,
) async {
  final repository = ref.watch(petRepositoryProvider);
  final result = await repository.getScanLogs(petId);

  return result.fold((failure) => <ScanLogEntity>[], (logs) => logs);
});

final schedulesProvider =
    FutureProvider.family<List<PetScheduleEntity>, String>((ref, petId) async {
      final useCase = ref.watch(getPetSchedulesUseCaseProvider);
      final result = await useCase(petId);

      return result.fold(
        (failure) => <PetScheduleEntity>[],
        (schedules) => schedules,
      );
    });

final scheduleTypesProvider = FutureProvider<List<ScheduleTypeEntity>>((
  ref,
) async {
  final repository = ref.watch(petRepositoryProvider);
  final result = await repository.getScheduleTypes();

  return result.fold((failure) => <ScheduleTypeEntity>[], (types) => types);
});

final petCategoriesProvider = FutureProvider<List<PetCategoryEntity>>((
  ref,
) async {
  final repository = ref.watch(petRepositoryProvider);
  final result = await repository.getPetCategories();

  return result.fold(
    (failure) => <PetCategoryEntity>[],
    (categories) => categories,
  );
});

// Social Features State Providers
final photoCommentsProvider =
    FutureProvider.family<List<PhotoCommentEntity>, String>((
      ref,
      photoId,
    ) async {
      final useCase = ref.watch(getPhotoCommentsUseCaseProvider);
      final result = await useCase(photoId);

      return result.fold(
        (failure) => <PhotoCommentEntity>[],
        (comments) => comments,
      );
    });

// Timeline State Providers
final petTimelinesProvider =
    FutureProvider.family<List<PetTimelineEntity>, String>((ref, petId) async {
      final useCase = ref.watch(getPetTimelinesUseCaseProvider);
      final result = await useCase(petId);

      return result.fold(
        (failure) => <PetTimelineEntity>[],
        (timelines) => timelines,
      );
    });

// Character State Providers
final charactersProvider = FutureProvider<List<CharacterEntity>>((ref) async {
  final useCase = ref.watch(getCharactersUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => <CharacterEntity>[],
    (characters) => characters,
  );
});

// Dynamic Health System Use Cases
final getHealthParametersForCategoryUseCaseProvider =
    Provider<GetHealthParametersForCategory>((ref) {
      return GetHealthParametersForCategory(ref.watch(petRepositoryProvider));
    });

final calculateHealthScoreUseCaseProvider = Provider<CalculateHealthScore>((
  ref,
) {
  return CalculateHealthScore();
});

final updateHealthParameterUseCaseProvider = Provider<UpdateHealthParameter>((
  ref,
) {
  return UpdateHealthParameter(
    ref.watch(petRepositoryProvider),
    ref.watch(calculateHealthScoreUseCaseProvider),
  );
});

final getHealthHistoryUseCaseProvider = Provider<GetHealthHistory>((ref) {
  return GetHealthHistory(ref.watch(petRepositoryProvider));
});

// Dynamic Health System State Providers
final healthParametersForCategoryProvider =
    FutureProvider.family<List<HealthParameterDefinitionEntity>, String>((
      ref,
      petCategoryId,
    ) async {
      final useCase = ref.watch(getHealthParametersForCategoryUseCaseProvider);
      final result = await useCase(petCategoryId);

      return result.fold(
        (failure) => <HealthParameterDefinitionEntity>[],
        (parameters) => parameters,
      );
    });

final healthHistoryProvider =
    FutureProvider.family<List<PetHealthHistoryEntity>, String>((
      ref,
      petId,
    ) async {
      final useCase = ref.watch(getHealthHistoryUseCaseProvider);
      final result = await useCase(petId);

      return result.fold(
        (failure) => <PetHealthHistoryEntity>[],
        (history) => history,
      );
    });
