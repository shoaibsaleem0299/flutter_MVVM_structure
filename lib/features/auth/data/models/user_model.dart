import '../../../../core/utils/typedefs.dart';

class UserModel {
  const UserModel({required this.id, required this.email, this.name});
  final String id;
  final String email;
  final String? name;

  factory UserModel.fromJson(Json json) => UserModel(
        id: json['id'].toString(),
        email: json['email'] as String,
        name: json['name'] as String?,
      );
}
