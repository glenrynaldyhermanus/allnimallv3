class ServerException implements Exception {
  final String message;
  final String? code;

  ServerException([this.message = 'Server error occurred', this.code]);

  @override
  String toString() =>
      'ServerException: $message${code != null ? ' ($code)' : ''}';
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'Network connection failed']);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;

  CacheException([this.message = 'Cache error occurred']);

  @override
  String toString() => 'CacheException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException([this.message = 'Authentication failed', this.code]);

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' ($code)' : ''}';
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'Unauthorized access']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class SessionExpiredException implements Exception {
  final String message;

  SessionExpiredException([this.message = 'Session expired']);

  @override
  String toString() => 'SessionExpiredException: $message';
}

class InvalidOTPException implements Exception {
  final String message;

  InvalidOTPException([this.message = 'Invalid OTP code']);

  @override
  String toString() => 'InvalidOTPException: $message';
}

class OTPExpiredException implements Exception {
  final String message;

  OTPExpiredException([this.message = 'OTP code expired']);

  @override
  String toString() => 'OTPExpiredException: $message';
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException([this.message = 'Resource not found']);

  @override
  String toString() => 'NotFoundException: $message';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  ValidationException([this.message = 'Validation error', this.errors]);

  @override
  String toString() => 'ValidationException: $message';
}

class DuplicateException implements Exception {
  final String message;

  DuplicateException([this.message = 'Resource already exists']);

  @override
  String toString() => 'DuplicateException: $message';
}

class PermissionDeniedException implements Exception {
  final String message;

  PermissionDeniedException([this.message = 'Permission denied']);

  @override
  String toString() => 'PermissionDeniedException: $message';
}

class LocationPermissionException implements Exception {
  final String message;

  LocationPermissionException([this.message = 'Location permission denied']);

  @override
  String toString() => 'LocationPermissionException: $message';
}

class StorageException implements Exception {
  final String message;

  StorageException([this.message = 'Storage error occurred']);

  @override
  String toString() => 'StorageException: $message';
}

class UploadException implements Exception {
  final String message;

  UploadException([this.message = 'Upload failed']);

  @override
  String toString() => 'UploadException: $message';
}

class DownloadException implements Exception {
  final String message;

  DownloadException([this.message = 'Download failed']);

  @override
  String toString() => 'DownloadException: $message';
}
