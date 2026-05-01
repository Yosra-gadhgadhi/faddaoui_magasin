class RegisterRequestModel {
  final String fullName;
  final String email;
  final String password;

  RegisterRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toLegacyJson() => {
        "fullName": fullName,
        "email": email,
        "password": password,
      };

  Map<String, dynamic> toAuthJson() => {
        "fullName": fullName,
        "email": email,
        "password": password,
      };
}
