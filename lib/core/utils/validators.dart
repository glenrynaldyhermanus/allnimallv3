class Validators {
  Validators._();

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d+]'), '');

    // Check if it's a valid Indonesian phone number
    // Formats: 08xx, +628xx, 628xx
    final RegExp phoneRegex = RegExp(r'^(\+62|62|0)[2-9][0-9]{7,11}$');

    if (!phoneRegex.hasMatch(digitsOnly)) {
      return 'Invalid phone number format';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }

    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP code is required';
    }

    if (value.length != 6) {
      return 'OTP code must be 6 digits';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP code must contain only numbers';
    }

    return null;
  }

  static String? minLength(String? value, int length, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} is required';
    }

    if (value.length < length) {
      return '${fieldName ?? 'Field'} must be at least $length characters';
    }

    return null;
  }

  static String? maxLength(String? value, int length, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    if (value.length > length) {
      return '${fieldName ?? 'Field'} must be at most $length characters';
    }

    return null;
  }

  static String? numeric(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '${fieldName ?? 'Field'} must contain only numbers';
    }

    return null;
  }

  static String? decimal(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      return '${fieldName ?? 'Field'} must be a valid number';
    }

    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final RegExp urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Invalid URL format';
    }

    return null;
  }

  static String? combine(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }
}
