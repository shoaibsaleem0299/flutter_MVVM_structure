class Validators {
  const Validators._();

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    return ok ? null : 'Invalid email';
  }

  static String? password(String? v) =>
      (v == null || v.length < 6) ? 'Min 6 characters' : null;
}
