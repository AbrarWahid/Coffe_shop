abstract final class Validators {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
  static final _username = RegExp(r'^[a-zA-Z0-9._]+$');

  /// Indonesian mobile numbers: 08xx… or +628xx…, 10–13 digits after the 0.
  static final _idPhone = RegExp(r'^(?:\+62|62|0)8[1-9][0-9]{7,10}$');

  static String? username(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your username';
    if (v.length < 3) return 'Username must be at least 3 characters';
    if (v.length > 24) return 'Username must be 24 characters or fewer';
    if (!_username.hasMatch(v)) {
      return 'Use letters, numbers, dots or underscores only';
    }
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your email';
    if (!_email.hasMatch(v)) return 'That email doesn\'t look right';
    return null;
  }

  /// Rules for choosing a new password (sign-in only checks presence).
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please choose a password';
    if (value.length < 8) return 'Use at least 8 characters';
    if (!value.contains(RegExp(r'[0-9]')) ||
        !value.contains(RegExp(r'[A-Za-z]'))) {
      return 'Mix letters and at least one number';
    }
    return null;
  }

  static String? address(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your delivery address';
    if (v.length < 10) {
      return 'Add a street name and number so the courier can find you';
    }
    return null;
  }

  static String? phone(String? value) {
    final normalized = value?.replaceAll(RegExp(r'[\s-]'), '') ?? '';
    if (normalized.isEmpty) return 'Please enter a phone number';
    if (!_idPhone.hasMatch(normalized)) {
      return 'Enter a valid mobile number, e.g. 0812 3456 7890';
    }
    return null;
  }
}
