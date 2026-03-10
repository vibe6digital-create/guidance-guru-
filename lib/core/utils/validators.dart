class Validators {
  Validators._();

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 10) return 'Enter a valid 10-digit phone number';
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) return 'OTP is required';
    if (value.length != 6) return 'Enter a valid 6-digit OTP';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  static String? marks(String? value, {double max = 100}) {
    if (value == null || value.isEmpty) return 'Marks are required';
    final marks = double.tryParse(value);
    if (marks == null) return 'Enter a valid number';
    if (marks < 0 || marks > max) return 'Marks must be between 0 and $max';
    return null;
  }

  static String? percentage(String? value) {
    if (value == null || value.isEmpty) return 'Percentage is required';
    final pct = double.tryParse(value);
    if (pct == null) return 'Enter a valid number';
    if (pct < 0 || pct > 100) return 'Must be between 0 and 100';
    return null;
  }

  static String? studentCode(String? value) {
    if (value == null || value.trim().isEmpty) return 'Student code is required';
    if (value.trim().length < 6) return 'Enter a valid student code';
    return null;
  }
}
