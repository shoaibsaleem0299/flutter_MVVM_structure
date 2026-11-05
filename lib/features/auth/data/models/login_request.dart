import '../../../../core/utils/typedefs.dart';

class LoginRequest {
  const LoginRequest({required this.email, required this.password});
  final String email;
  final String password;

  Json toJson() => {'email': email, 'password': password};
}
