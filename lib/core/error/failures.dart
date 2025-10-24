import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Unauthorized access']);
}

class SessionExpiredFailure extends Failure {
  const SessionExpiredFailure([super.message = 'Session expired']);
}

class InvalidOTPFailure extends Failure {
  const InvalidOTPFailure([super.message = 'Invalid OTP code']);
}

class OTPExpiredFailure extends Failure {
  const OTPExpiredFailure([super.message = 'OTP code expired']);
}

// Data failures
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation error']);
}

class DuplicateFailure extends Failure {
  const DuplicateFailure([super.message = 'Resource already exists']);
}

// Permission failures
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure([super.message = 'Permission denied']);
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure([
    super.message = 'Location permission denied',
  ]);
}

// Storage failures
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Storage error occurred']);
}

class UploadFailure extends Failure {
  const UploadFailure([super.message = 'Upload failed']);
}

class DownloadFailure extends Failure {
  const DownloadFailure([super.message = 'Download failed']);
}

// Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Unknown error occurred']);
}
