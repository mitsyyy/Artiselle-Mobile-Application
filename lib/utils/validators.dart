final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email is required.';
  if (!_emailRegex.hasMatch(value.trim())) return 'Please enter a valid email address.';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required.';
  if (value.length < 8) return 'Password must be at least 8 characters.';
  return null;
}

String? validateRequired(String? value, {String fieldName = 'This field'}) {
  if (value == null || value.trim().isEmpty) return '$fieldName is required.';
  return null;
}
