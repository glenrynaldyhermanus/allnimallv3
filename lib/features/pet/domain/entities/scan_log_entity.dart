import 'package:equatable/equatable.dart';

class ScanLogEntity extends Equatable {
  final String id;
  final String petId;
  final double? latitude;
  final double? longitude;
  final String? scannedByIp;
  final String? userAgent;
  final Map<String, dynamic>? deviceInfo;
  final double? locationAccuracy;
  final String? locationName;
  final DateTime createdAt;

  const ScanLogEntity({
    required this.id,
    required this.petId,
    this.latitude,
    this.longitude,
    this.scannedByIp,
    this.userAgent,
    this.deviceInfo,
    this.locationAccuracy,
    this.locationName,
    required this.createdAt,
  });

  bool get hasLocation => latitude != null && longitude != null;

  String get locationDisplay {
    if (!hasLocation) return 'Unknown location';
    if (locationName != null) return locationName!;
    return 'Lat: ${latitude!.toStringAsFixed(6)}, Lng: ${longitude!.toStringAsFixed(6)}';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  List<Object?> get props => [
    id,
    petId,
    latitude,
    longitude,
    scannedByIp,
    userAgent,
    deviceInfo,
    locationAccuracy,
    locationName,
    createdAt,
  ];
}
