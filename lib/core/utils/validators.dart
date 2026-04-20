class Validators {
  static final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$');
  static final RegExp passwordRegex = RegExp(r'^.{8,}$');

  static bool isValidEmail(String v) => v.isNotEmpty && emailRegex.hasMatch(v);
  static bool isValidPassword(String v) => v.isNotEmpty && passwordRegex.hasMatch(v);
}
