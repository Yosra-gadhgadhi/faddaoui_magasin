class ResetPasswordRequestModel {
  final String resetToken;
  final String newPassword;

  ResetPasswordRequestModel({
    required this.resetToken,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        "resetToken": resetToken,
        "newPassword": newPassword,
      };
}