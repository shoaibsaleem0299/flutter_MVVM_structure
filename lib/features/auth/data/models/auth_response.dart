import '../../../../core/utils/typedefs.dart';
import 'user_model.dart';

/// Adjust keys to match your backend.
class AuthResponse {
  const AuthResponse({required this.token, required this.user});
  final String token;
  final UserModel user;

  factory AuthResponse.fromJson(Json json) => AuthResponse(
        token: json['token'] as String,
        user: UserModel.fromJson(json['user'] as Json),
      );
}
