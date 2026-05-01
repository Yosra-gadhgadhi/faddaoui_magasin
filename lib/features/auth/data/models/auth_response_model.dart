class AuthResponseModel {
  final String token;
  AuthResponseModel({required this.token});

  factory AuthResponseModel.fromJson(
    Map<String, dynamic> json, {
    bool allowMessageFallback = false,
  }) {
    final token = _extractToken(
      json,
      allowMessageFallback: allowMessageFallback,
    );
    if (token.isEmpty) {
      throw const FormatException("Aucun token reçu depuis le serveur.");
    }
    return AuthResponseModel(token: token);
  }

  static String _extractToken(
    Map<String, dynamic> json, {
    required bool allowMessageFallback,
  }) {
    final direct = json["token"];
    if (direct is String && direct.isNotEmpty) return direct;

    final snakeAccessToken = json["access_token"];
    if (snakeAccessToken is String && snakeAccessToken.isNotEmpty) {
      return snakeAccessToken;
    }

    final accessToken = json["accessToken"];
    if (accessToken is String && accessToken.isNotEmpty) return accessToken;

    final message = json["message"];
    if (allowMessageFallback && message is String && message.isNotEmpty) {
      // Some signup APIs return only a success message.
      return "__signup_ok__";
    }

    final data = json["data"];
    if (data is Map) {
      final nested = data["token"];
      if (nested is String && nested.isNotEmpty) return nested;
      final nestedSnake = data["access_token"];
      if (nestedSnake is String && nestedSnake.isNotEmpty) return nestedSnake;
      final nestedAccess = data["accessToken"];
      if (nestedAccess is String && nestedAccess.isNotEmpty) {
        return nestedAccess;
      }
    }

    return "";
  }
}
