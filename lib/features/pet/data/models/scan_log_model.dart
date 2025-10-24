import '../../domain/entities/scan_log_entity.dart';

class ScanLogModel extends ScanLogEntity {
  const ScanLogModel({
    required super.id,
    required super.petId,
    super.latitude,
    super.longitude,
    super.scannedByIp,
    super.userAgent,
    super.deviceInfo,
    super.locationAccuracy,
    super.locationName,
    required super.createdAt,
  });

  factory ScanLogModel.fromJson(Map<String, dynamic> json) {
    return ScanLogModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      scannedByIp: json['scanned_by_ip'] as String?,
      userAgent: json['user_agent'] as String?,
      deviceInfo: json['device_info'] as Map<String, dynamic>?,
      locationAccuracy: json['location_accuracy'] != null
          ? (json['location_accuracy'] as num).toDouble()
          : null,
      locationName: json['location_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pet_id': petId,
      'latitude': latitude,
      'longitude': longitude,
      'scanned_by_ip': scannedByIp,
      'user_agent': userAgent,
      'device_info': deviceInfo,
      'location_accuracy': locationAccuracy,
      'location_name': locationName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ScanLogEntity toEntity() {
    return ScanLogEntity(
      id: id,
      petId: petId,
      latitude: latitude,
      longitude: longitude,
      scannedByIp: scannedByIp,
      userAgent: userAgent,
      deviceInfo: deviceInfo,
      locationAccuracy: locationAccuracy,
      locationName: locationName,
      createdAt: createdAt,
    );
  }
}
