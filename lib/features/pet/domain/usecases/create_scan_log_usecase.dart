import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/scan_log_entity.dart';
import '../repositories/pet_repository.dart';

class CreateScanLogUseCase {
  final PetRepository repository;

  CreateScanLogUseCase(this.repository);

  Future<Either<Failure, ScanLogEntity>> call({
    required String petId,
    double? latitude,
    double? longitude,
    String? scannedByIp,
    String? userAgent,
    Map<String, dynamic>? deviceInfo,
    double? locationAccuracy,
    String? locationName,
  }) async {
    if (petId.isEmpty) {
      return const Left(ValidationFailure('Pet ID cannot be empty'));
    }

    return await repository.createScanLog(
      petId: petId,
      latitude: latitude,
      longitude: longitude,
      scannedByIp: scannedByIp,
      userAgent: userAgent,
      deviceInfo: deviceInfo,
      locationAccuracy: locationAccuracy,
      locationName: locationName,
    );
  }
}
