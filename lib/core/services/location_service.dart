import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../error/exceptions.dart' as exceptions;
import '../utils/logger.dart';

class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e, stackTrace) {
      AppLogger.error('Error checking location service', e, stackTrace);
      return false;
    }
  }

  /// Check location permission
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e, stackTrace) {
      AppLogger.error('Error checking location permission', e, stackTrace);
      return LocationPermission.denied;
    }
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    try {
      AppLogger.info('Requesting location permission');
      return await Geolocator.requestPermission();
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting location permission', e, stackTrace);
      return LocationPermission.denied;
    }
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      AppLogger.info('Getting current position');

      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw exceptions.LocationPermissionException(
          'Location services are disabled',
        );
      }

      // Check permission
      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw exceptions.LocationPermissionException(
            'Location permission denied',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw exceptions.LocationPermissionException(
          'Location permission permanently denied',
        );
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      AppLogger.info(
        'Position obtained: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } on exceptions.LocationPermissionException {
      rethrow;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting current position', e, stackTrace);
      return null;
    }
  }

  /// Get location name from coordinates (reverse geocoding)
  Future<String?> getLocationName(double latitude, double longitude) async {
    try {
      AppLogger.info('Getting location name for: $latitude, $longitude');

      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;
      final parts = <String>[];

      if (place.street != null && place.street!.isNotEmpty) {
        parts.add(place.street!);
      }
      if (place.subLocality != null && place.subLocality!.isNotEmpty) {
        parts.add(place.subLocality!);
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        parts.add(place.locality!);
      }
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        parts.add(place.administrativeArea!);
      }

      final locationName = parts.join(', ');
      AppLogger.info('Location name: $locationName');
      return locationName;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting location name', e, stackTrace);
      return null;
    }
  }

  /// Get distance between two coordinates in meters
  double getDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Format distance to human readable string
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }
}
